#!/usr/bin/env bash
set -euo pipefail

# Usage: sudo ./scripts/setup-linux.sh [CONFIG_DIR]
CONFIG_DIR=${1:-/root/solarman/homeassistant_config}
TMPDIR=${TMPDIR:-/tmp}
REPO="https://github.com/davidrapan/ha-solarman.git"
SUNSYNK_URL="https://raw.githubusercontent.com/slipx06/sunsynk-power-flow-card/v7.0.0/dist/sunsynk-power-flow-card.js"

# Determine repo root (script is in scripts/)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/docker-compose.yml"

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root (sudo)"
    echo "Example: sudo $0"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 SRNE Solarman Home Assistant Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Install prerequisites
echo "📦 Installing prerequisites..."
if command -v apt-get &>/dev/null; then
    # Debian/Ubuntu
    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        gnupg \
        lsb-release

    # Install Docker if not present
    if ! command -v docker &>/dev/null; then
        echo "🐳 Installing Docker..."
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        # Add Docker repository
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker Engine
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

        # Start and enable Docker service
        systemctl enable --now docker
    fi
elif command -v yum &>/dev/null; then
    # RHEL/CentOS/Fedora
    yum install -y git curl

    if ! command -v docker &>/dev/null; then
        echo "🐳 Installing Docker..."
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        systemctl enable --now docker
    fi
else
    echo "⚠️ Unsupported package manager. Please install Docker and Git manually."
    exit 1
fi

# Verify installations
echo "✅ Verifying installations..."
if ! command -v docker &>/dev/null; then
    echo "❌ Docker installation failed"
    exit 1
fi
if ! command -v git &>/dev/null; then
    echo "❌ Git installation failed"
    exit 1
fi

echo ""
echo "📍 Using config directory: ${CONFIG_DIR}"
echo ""

# Create config directories
echo "📁 Creating directories..."
sudo mkdir -p "${CONFIG_DIR}"/{custom_components/solarman/inverter_definitions,www/sunsynk-power-flow-card}
sudo chown -R $(whoami):$(whoami) "${CONFIG_DIR}"

# Copy configuration files from the repository templates directory
echo "📄 Copying configuration files..."
cp "${REPO_ROOT}/templates/configuration.yaml" "${CONFIG_DIR}/"
cp "${REPO_ROOT}/templates/srne_hesp.yaml" "${CONFIG_DIR}/custom_components/solarman/inverter_definitions/"

# Clone and install ha-solarman
echo "📥 Installing ha-solarman integration..."
cd "${TMPDIR}"
rm -rf ha-solarman || true
if ! git clone "${REPO}"; then
    echo "Error: Failed to clone ha-solarman repository"
    exit 1
fi
cp -r ha-solarman/custom_components/solarman "${CONFIG_DIR}/custom_components/"

# Detect Home Assistant container UID
echo "🔍 Detecting Home Assistant container UID..."
HA_UID=1000
if command -v docker >/dev/null 2>&1; then
    if docker ps --format '{{.Names}}' | grep -Eq '^homeassistant$'; then
        DET_UID=$(docker exec homeassistant id -u 2>/dev/null || true)
        if [[ -n "${DET_UID}" && "${DET_UID}" =~ ^[0-9]+$ ]]; then
            HA_UID=${DET_UID}
            echo "Found HA container UID: ${HA_UID}"
        fi
    fi
fi

# Set permissions
echo "🔒 Setting permissions..."
sudo chown -R ${HA_UID}:${HA_UID} "${CONFIG_DIR}/custom_components/solarman" || true

# Install Sunsynk card
echo "📥 Installing Sunsynk Power Flow card..."
if ! curl -L -o "${CONFIG_DIR}/www/sunsynk-power-flow-card/sunsynk-power-flow-card.js" "${SUNSYNK_URL}"; then
    echo "Error: Failed to download Sunsynk card"
    exit 1
fi
sudo chown -R ${HA_UID}:${HA_UID} "${CONFIG_DIR}/www" || true

# Create/update docker-compose.yml with correct config path
echo "🐳 Creating Docker Compose configuration..."
cat > "${COMPOSE_FILE}" <<EOF
version: '3.8'
services:
  homeassistant:
    container_name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    ports:
      - "8123:8123"
    volumes:
      - ${CONFIG_DIR}:/config
      - /etc/localtime:/etc/localtime:ro
    environment:
      - TZ=Asia/Singapore
    restart: unless-stopped
    network_mode: host
EOF

# Start/restart Home Assistant
echo "🔄 Starting Home Assistant container..."
cd "${REPO_ROOT}"

# Check if container already exists and is running
if docker ps -a --format '{{.Names}}' | grep -q '^homeassistant$'; then
    echo "   Container exists, restarting..."
    docker restart homeassistant || echo "⚠️  Warning: Failed to restart container"
else
    echo "   Creating new container..."
    if docker compose up -d; then
        echo "   ✅ Container started successfully"
    else
        echo "   ⚠️  Warning: Failed to start container"
        echo "   You may need to start it manually with: docker compose up -d"
    fi
fi

# Cleanup
echo "🧹 Cleaning up temporary files..."
rm -rf "${TMPDIR}/ha-solarman"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Access Home Assistant at: http://localhost:8123"
echo ""
echo "📋 Next Steps:"
echo "   1. Wait 1-2 minutes for Home Assistant to start"
echo "   2. Open http://localhost:8123 in your browser"
echo "   3. Complete the initial setup wizard"
echo "   4. Go to Settings → Dashboards → Resources"
echo "   5. Add resource: /local/sunsynk-power-flow-card/sunsynk-power-flow-card.js?ver=1"
echo "   6. Go to Settings → Devices & Services"
echo "   7. Add 'Solarman' integration with:"
echo "      - Title: SRNE"
echo "      - Profile: srne_hesp.yaml"
echo "      - IP: [Your dongle's IP address]"
echo ""
echo "📖 For detailed instructions, see the README.md"
echo "🐛 Having issues? Check the troubleshooting section in README.md"
echo ""
