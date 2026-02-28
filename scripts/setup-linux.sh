#!/usr/bin/env bash
set -euo pipefail

# Usage: sudo ./scripts/setup-linux.sh [CONFIG_DIR]
CONFIG_DIR=${1:-/root/solarman/homeassistant_config}
TMPDIR=${TMPDIR:-/tmp}
REPO="https://github.com/davidrapan/ha-solarman.git"
SUNSYNK_URL="https://raw.githubusercontent.com/slipx06/sunsynk-power-flow-card/v7.0.0/dist/sunsynk-power-flow-card.js"

# Determine repo root (script is in scripts/)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/docker/docker-compose.yml"

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
echo "⏱️  This will take 10-15 minutes"
echo "📦 What this script does:"
echo "   • Installs Docker (if not already installed)"
echo "   • Downloads Home Assistant"
echo "   • Installs Solarman integration"
echo "   • Installs beautiful dashboard card"
echo "   • Starts everything automatically"
echo ""

# ===== PRE-FLIGHT CHECKS =====
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Running pre-flight checks..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check available disk space (need 10GB minimum)
AVAILABLE=$(df /root 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")
REQUIRED=$((10 * 1024 * 1024))  # 10GB in KB

if [ "$AVAILABLE" -lt "$REQUIRED" ]; then
    AVAIL_GB=$((AVAILABLE / 1024 / 1024))
    echo "❌ ERROR: Insufficient disk space"
    echo "   Required: 10 GB minimum"
    echo "   Available: ${AVAIL_GB} GB"
    exit 1
fi
echo "✅ Disk space: OK ($(( AVAILABLE / 1024 / 1024 )) GB available)"

# Check internet connectivity
echo -n "🌐 Checking internet connectivity... "
if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "✅"
else
    echo "⚠️  WARNING: No internet detected"
    echo "   Installation requires internet to download Docker and components"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Docker already installed
echo -n "🐳 Checking Docker... "
if command -v docker &>/dev/null; then
    DOCKER_VERSION=$(docker --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1)
    echo "✅ (v${DOCKER_VERSION})"
else
    echo "⚠️  Docker not found - will be installed"
fi

# Check if port 8123 is available
echo -n "🔌 Checking port 8123... "
if command -v netstat &>/dev/null; then
    if netstat -tuln 2>/dev/null | grep -q ":8123 "; then
        echo "⚠️  WARNING: Port 8123 already in use"
        echo "   Home Assistant may not start correctly"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo "✅"
    fi
else
    echo "⚠️  (skipped - netstat not available)"
fi

echo "✅ All pre-flight checks passed!"
echo ""

# Install prerequisites
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Step 1/7: Installing prerequisites..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if command -v apt-get &>/dev/null; then
    # Debian/Ubuntu
    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        gnupg \
        lsb-release \
        net-tools

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

# Install Tailscale
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Installing Tailscale for remote access..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! command -v tailscale &>/dev/null; then
    echo "   Downloading and installing Tailscale..."
    if curl -fsSL https://tailscale.com/install.sh | sh; then
        systemctl enable --now tailscaled
        echo "   ✅ Tailscale installed successfully"
        
        # Check if Tailscale service is running
        if systemctl is-active --quiet tailscaled; then
            echo "   ✅ Tailscale service is running"
        else
            echo "   ⚠️  Warning: Tailscale service may not be running properly"
            echo "   You may need to start it manually: sudo systemctl start tailscaled"
        fi
    else
        echo "   ❌ Failed to install Tailscale"
        echo "   You can install it manually later with: curl -fsSL https://tailscale.com/install.sh | sh"
    fi
else
    echo "   ✅ Tailscale already installed"
    
    # Check if Tailscale service is running
    if systemctl is-active --quiet tailscaled 2>/dev/null; then
        echo "   ✅ Tailscale service is running"
    else
        echo "   ⚠️  Tailscale service not running, starting..."
        systemctl enable --now tailscaled
    fi
fi

# Verify installations
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Verifying installations..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! command -v docker &>/dev/null; then
    echo "❌ Docker installation failed"
    exit 1
fi
if ! command -v git &>/dev/null; then
    echo "❌ Git installation failed"
    exit 1
fi
if ! command -v tailscale &>/dev/null; then
    echo "❌ Tailscale installation failed"
    exit 1
fi

echo ""
echo "📍 Using config directory: ${CONFIG_DIR}"
echo ""

# Create config directories
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Step 2/7: Creating directories..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo mkdir -p "${CONFIG_DIR}"/{custom_components/solarman/inverter_definitions,www/sunsynk-power-flow-card}
sudo chown -R $(whoami):$(whoami) "${CONFIG_DIR}"

# Copy configuration files from the repository templates directory
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 Step 3/7: Copying configuration files..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cp "${REPO_ROOT}/templates/configuration.yaml" "${CONFIG_DIR}/"
cp "${REPO_ROOT}/templates/srne_hesp.yaml" "${CONFIG_DIR}/custom_components/solarman/inverter_definitions/"

# Clone and install ha-solarman
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 Step 4/7: Installing ha-solarman integration..."
echo "    (This connects to your SRNE inverter)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔒 Step 5/7: Setting permissions..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo chown -R ${HA_UID}:${HA_UID} "${CONFIG_DIR}/custom_components/solarman" || true

# Install Sunsynk card
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 Step 6/7: Installing Sunsynk Power Flow card..."
echo "    (This makes your dashboard look beautiful!)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Step 7/7: Starting Home Assistant container..."
echo "    (Please wait, this may take 1-2 minutes)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
echo "🌐 Remote Access with Tailscale:"
echo "   1. Connect to Tailscale: sudo tailscale up"
echo "   2. Visit the URL shown to authenticate"
echo "   3. Get your Tailscale IP: tailscale ip -4"
echo "   4. Access Home Assistant remotely: http://[tailscale-ip]:8123"
echo "   5. Install Tailscale app on mobile for remote access"
echo ""
echo "📖 For detailed instructions, see the README.md"
echo "🐛 Having issues? Check the troubleshooting section in README.md"
echo ""
