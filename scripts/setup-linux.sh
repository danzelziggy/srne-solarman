#!/usr/bin/env bash
set -euo pipefail

# Usage: sudo ./scripts/setup-linux.sh [CONFIG_DIR]
CONFIG_DIR=${1:-/root/solarman/homeassistant_config}
TMPDIR=${TMPDIR:-/tmp}
REPO="https://github.com/davidrapan/ha-solarman.git"
SUNSYNK_URL="https://raw.githubusercontent.com/slipx06/sunsynk-power-flow-card/v7.0.0/dist/sunsynk-power-flow-card.js"

# Determine repo root (script is in scripts/)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo)"
    exit 1
fi

echo "🚀 Setting up SRNE Solarman integration"

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

echo "Using config dir: ${CONFIG_DIR}"

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

# Start/restart Home Assistant
echo "🔄 Restarting Home Assistant..."
if ! sudo docker compose up -d; then
    echo "Warning: Failed to start Home Assistant container"
fi
if ! sudo docker compose restart homeassistant; then
    echo "Warning: Failed to restart Home Assistant container"
fi

# Cleanup
rm -rf "${TMPDIR}/ha-solarman"

echo "✅ Installation complete!"
echo
echo "Next steps:"
echo "1. Open Home Assistant: http://localhost:8123"
echo "2. Go to Settings → Dashboards → Resources"
echo "3. Add resource: /local/sunsynk-power-flow-card/sunsynk-power-flow-card.js"
echo "4. Configure Solarman integration via Settings → Devices & Services"
echo
echo "For troubleshooting, check the README.md"
