<div align="center">

<h1>☀️ SRNE - Solarman for Home Assistant</h1>

![SRNE Solarman](https://img.shields.io/badge/SRNE-Solarman-brightgreen?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBmaWxsPSIjZmZmZmZmIiBkPSJNMTEuNSA9TDEzIDYuNUwxNC41IDlIMTEuNW0zLjcgOUwxOSAxMC41TDIxLjggMThIMTUuMk0xMCAyMEwyIDEyTDEwIDRMMTggMTJMMTAgMjBaIi8+PC9zdmc+)
[![Version](https://img.shields.io/badge/version-2.0-blue?style=for-the-badge)](https://github.com/davidrapan/ha-solarman)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-Ready-41BDF5?style=for-the-badge&logo=home-assistant)](https://www.home-assistant.io)
[![Docker](https://img.shields.io/badge/docker-ready-2496ED?style=for-the-badge&logo=docker)](https://www.docker.com)

<p style="font-size: 1.2em; margin: 1em 0;">A comprehensive guide for integrating SRNE/Solarman inverters with Home Assistant using Docker.</p>

<p style="font-size: 1.1em; margin: 1em 0;">
<b>🛠️ Prerequisites</b> • <b>⚡ Quick Start</b> • <b>📖 Setup Guide</b> • <b>📊 Dashboard</b>
</p>

</div>

---

# 📋 Table of Contents

<details open>
<summary>Click to expand/collapse</summary>

- [💻 Hardware Requirements](#hardware-requirements)
- [⚙️ Prerequisites](#prerequisites)
- [⚡ Quick Start](#quick-start)
- [🚀 Installation](#installation)
    - [🤖 Automated Installation](#automated-installation)
    - [🐧 Linux - step-by-step](#linux-step-by-step)
    - [🪟 Windows - step-by-step](#windows-step-by-step)
- [🏠 Home Assistant Setup](#home-assistant-setup)
- [🖼️ Lovelace Dashboard](#lovelace-dashboard)
    - [🧩 Manual Installation](#manual-installation)
    - [⚙️ Card Configuration](#card-configuration)
- [📱 Mobile App Installation](#mobile-app-installation)
- [🔧 Advanced Configuration](#advanced-configuration)
- [❗ Troubleshooting](#troubleshooting)
- [📁 Project Structure](#project-structure)
- [📚 References & Credits](#references-credits)

</details>

<h2 id="hardware-requirements">💻 Hardware Requirements</h2>

<div style="text-align: left">
<h3>Minimum Requirements</h3>

- **Orange Pi One (1GB RAM)**
    - ✅ Suitable for basic setup
    - ✅ Direct ethernet connection to router
    - ❌ No built-in WiFi
    - 💰 Budget-friendly option
    - Perfect for direct cable connection setups

<h3>Recommended Alternative</h3>

- **Orange Pi Zero 3**
    - ✅ Built-in WiFi support
    - ✅ Better performance
    - ✅ More flexible installation options
    - Recommended if wireless connectivity is needed

<h3>Network Connection</h3>

- Orange Pi One: Use direct ethernet cable to router
- Orange Pi Zero 3: Can use either WiFi or ethernet

> Note: Both options are sufficient to run Home Assistant with the Solarman integration. Choose based on your network connectivity needs.
</div>

<h2 id="prerequisites">⚙️ Prerequisites</h2>

- Docker (Linux) or Docker Desktop (Windows)
- Git (optional - you can download ZIP instead)
- Network access to your SRNE/Solarman inverter
- 2GB+ RAM recommended

<h2 id="quick-start">⚡ Quick Start</h2>

<div style="text-align: left">
<h3>Summary (high level)</h3>

1. Install Docker and git on your host.
2. Create a Home Assistant config directory on the host.
3. Use Docker Compose to run Home Assistant container mapping the config directory.
4. Copy the `custom_components/solarman` folder from https://github.com/davidrapan/ha-solarman into your HA config's `custom_components` directory.
5. Install the Sunsynk Power Flow card into HA's `www` directory (manual install) and add it as a resource.
6. Open Home Assistant, add the Solarman integration, and add a Lovelace card using the provided example YAML.
</div>

<h2 id="installation">🚀 Installation</h2>

<div style="text-align: left">
<h3>🤖 Automated Installation</h3>

The repository includes smart setup scripts that handle the entire installation process automatically:

#### Linux Users
```bash
git clone https://github.com/davidrapan/ha-solarman.git
cd ha-solarman
sudo ./scripts/setup-linux.sh
```

The Linux script (`setup-linux.sh`) automatically:
1. **Checks Prerequisites**
    - Verifies root/sudo access
    - Detects package manager (apt/yum)

2. **Installs Dependencies**
    - Docker Engine & Docker Compose
    - Git
    - Required system packages

3. **Configures Environment**
    - Creates configuration directories
    - Sets correct file permissions
    - Configures Docker service

4. **Installs Components**
    - Home Assistant Docker container
    - ha-solarman integration
    - Sunsynk Power Flow card

5. **Handles Permissions**
    - Auto-detects Home Assistant container UID
    - Sets proper file ownership
    - Ensures Docker access rights

#### Windows Users
```powershell
# Run PowerShell as Administrator
git clone https://github.com/davidrapan/ha-solarman.git
cd ha-solarman
.\scripts\setup-windows.ps1
```

The Windows script (`setup-windows.ps1`) automatically:
1. **Checks Prerequisites**
    - Verifies Administrator privileges
    - Checks Windows version compatibility

2. **Installs Software**
    - Downloads & installs Docker Desktop
    - Downloads & installs Git
    - Handles PATH environment setup

3. **Configures System**
    - Creates necessary directories
    - Sets up Docker Desktop with WSL2
    - Configures file sharing

4. **Installs Components**
    - Home Assistant container
    - ha-solarman integration
    - Sunsynk Power Flow card

5. **Provides Guidance**
    - Handles system restart if needed
    - Shows clear next steps
    - Includes troubleshooting help

> 💡 **Note**: Both scripts include error handling, progress indicators, and automatic cleanup. They will guide you through any necessary system restarts or additional steps needed.

<h3 align="left">Manual Installation</h3>
If you prefer manual installation or need to customize the setup, follow the step-by-step instructions below:

<h3 id="linux-step-by-step" align="left">🐧 Linux - step-by-step</h3>

1) Install Docker & git

```bash
sudo apt update && sudo apt install -y docker.io docker-compose git
sudo systemctl enable --now docker
```

0) (Optional but required for commands below) Make sure you are in the repository root (where this README and the `templates/` directory live). If you haven't cloned the repo yet, run:

```bash
# Clone the repo and change into it (only needed if you don't already have the files locally)
git clone https://github.com/davidrapan/ha-solarman.git
cd ha-solarman
```

2) Create HA config directory

```bash
sudo mkdir -p /root/solarman/homeassistant_config/{custom_components/solarman/inverter_definitions,www/sunsynk-power-flow-card}
sudo chown -R $(whoami):$(whoami) /root/solarman/homeassistant_config
```

3) Docker Compose example

Create `docker-compose.yml` (adjust TZ and paths as needed):

```yaml
version: '3.8'
services:
  homeassistant:
    container_name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    ports:
      - "8123:8123"
    volumes:
      - /root/solarman/homeassistant_config:/config
      - /etc/localtime:/etc/localtime:ro
    environment:
      - TZ=Asia/Singapore
    restart: unless-stopped
```

4) Copy configuration files

```bash
# Copy base configuration
cp ./templates/configuration.yaml /root/solarman/homeassistant_config/
# Copy SRNE inverter definition
cp ./templates/srne_hesp.yaml /root/solarman/homeassistant_config/custom_components/solarman/inverter_definitions/

# Ensure proper permissions
sudo chown -R 1000:1000 /root/solarman/homeassistant_config/custom_components/solarman/inverter_definitions
```

Start Home Assistant:

```bash
sudo docker compose up -d
```

4) Install ha-solarman (custom component)

```bash
cd /tmp
git clone https://github.com/davidrapan/ha-solarman.git
mkdir -p /root/solarman/homeassistant_config/custom_components
cp -r ha-solarman/custom_components/solarman /root/solarman/homeassistant_config/custom_components/
# Ensure the container can read the files (common HA container UID is 1000)
sudo chown -R 1000:1000 /root/solarman/homeassistant_config/custom_components/solarman || true
sudo docker compose restart homeassistant
```

5) Install Sunsynk Power Flow card (manual)

```bash
sudo mkdir -p /root/solarman/homeassistant_config/www/sunsynk-power-flow-card
sudo curl -L -o /root/solarman/homeassistant_config/www/sunsynk-power-flow-card/sunsynk-power-flow-card.js \
  https://raw.githubusercontent.com/slipx06/sunsynk-power-flow-card/v7.0.0/dist/sunsynk-power-flow-card.js
sudo chown -R 1000:1000 /root/solarman/homeassistant_config/www || true
sudo docker compose restart homeassistant
```

In the Home Assistant UI add this resource (Settings -> Dashboards -> Resources):

/local/sunsynk-power-flow-card/sunsynk-power-flow-card.js

Tip: append `?ver=1` (increment on updates) to bypass browser cache, or clear your browser cache after updating the file.

---

<h3 id="windows-step-by-step" align="left">🪟 Windows - step-by-step</h3>

Notes:
- Use Docker Desktop with WSL2 backend (recommended) or Hyper-V. Ensure Docker Desktop has access to the host folder used for HA config.
- Example host path: `C:\solarman\homeassistant_config`

> This repository includes a ready-made docker-compose.windows.yml and setup scripts:
> - docker-compose.windows.yml (repo root) — Windows-friendly compose file using a C:\\ path.
> - scripts\setup-windows.ps1 — PowerShell script to clone ha-solarman, copy the custom component and download the Sunsynk card.
> - scripts\setup-linux.sh — Bash script for Linux automation.

You can use the provided compose file instead of creating one manually. From the repository root run Docker Compose with the file specified (PowerShell / CMD):

```powershell
docker compose -f docker-compose.windows.yml up -d
```

1) Install Docker Desktop and Git for Windows

- Docker Desktop: https://www.docker.com/products/docker-desktop
- Git for Windows: https://git-scm.com/download/win

0) (Optional but required for commands below) Make sure you have cloned this repository and are running the following commands from the repository root where `templates\` exists. If you haven't cloned it yet, in PowerShell run:

```powershell
# Clone the repo and change into it (only needed if you don't already have the files locally)
git clone https://github.com/davidrapan/ha-solarman.git
Set-Location -Path .\ha-solarman
```

2) Create HA config directory (PowerShell as Administrator)

```powershell
New-Item -Path 'C:\solarman\homeassistant_config\custom_components\solarman\inverter_definitions' -ItemType Directory -Force
New-Item -Path 'C:\solarman\homeassistant_config\www\sunsynk-power-flow-card' -ItemType Directory -Force
```

3) Docker Compose example (Windows paths)

Create a `docker-compose.yml` (example, adjust TZ if needed):

```yaml
version: '3.8'
services:
  homeassistant:
    container_name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    ports:
      - "8123:8123"
    volumes:
      - "C:\\solarman\\homeassistant_config:/config"
    environment:
      - TZ=Asia/Singapore
    restart: unless-stopped
```

4) Copy configuration files

```powershell
# Copy base configuration
Copy-Item -Path ".\templates\configuration.yaml" -Destination "C:\solarman\homeassistant_config\" -Force
# Copy SRNE inverter definition
Copy-Item -Path ".\templates\srne_hesp.yaml" -Destination "C:\solarman\homeassistant_config\custom_components\solarman\inverter_definitions\" -Force
```

Start Home Assistant (run in folder with the compose file):

```powershell
docker compose up -d
```


---

<h2 id="home-assistant-setup">🏠 Home Assistant Setup</h2>

<div style="text-align: left">

1. Open Home Assistant UI: http://ip-address-of-solarman-dongle:8123 and complete the basic onboarding.

2. Settings -> Devices & Services -> Add integration -> search `Solarman` and follow prompts to configure your SRNE inverter.

3. Provide Title: `SRNE`. Profile: `srne_hesp.yaml`. IP address. Its important to provide the Title and Profile correctly to match the sensors names used in the Lovelace card.

4. After adding, check Settings -> Devices & Entities for the entities created by the integration (entity IDs may vary).

> **Note**: If the integration is not available in the UI, confirm the `custom_components/solarman` folder exists inside the active HA config and restart the container.

</div>

<h2 id="lovelace-dashboard">🖼️ Lovelace Dashboard</h2>

<div style="text-align: left">
<h3>Manual Installation</h3>

> Important: these manual instructions assume you have the repository files available locally (specifically the `templates/` directory). If you haven't already, clone this repository or download the ZIP and change into the repository root before running the commands below.
>
> Linux / macOS:
>
> ```bash
> git clone https://github.com/davidrapan/ha-solarman.git
> cd ha-solarman
> ```
>
> Windows (PowerShell):
>
> ```powershell
> git clone https://github.com/davidrapan/ha-solarman.git
> Set-Location -Path .\ha-solarman
> ```
>
> If you downloaded the ZIP from GitHub, extract it and `cd` into the extracted folder so `./templates` is available.

1. **Download the Card**
   ```bash
   # Linux
   sudo mkdir -p /root/solarman/homeassistant_config/www/sunsynk-power-flow-card
   sudo curl -L -o /root/solarman/homeassistant_config/www/sunsynk-power-flow-card/sunsynk-power-flow-card.js \
     https://raw.githubusercontent.com/slipx06/sunsynk-power-flow-card/v7.0.0/dist/sunsynk-power-flow-card.js

   # Windows (PowerShell)
   New-Item -Path 'C:\solarman\homeassistant_config\www\sunsynk-power-flow-card' -ItemType Directory -Force
   Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/slipx06/sunsynk-power-flow-card/v7.0.0/dist/sunsynk-power-flow-card.js' -OutFile 'C:\solarman\homeassistant_config\www\sunsynk-power-flow-card\sunsynk-power-flow-card.js'
   ```

2. **Add Resource to Home Assistant**
    1. Navigate to Configuration → Dashboards → Resources
    2. Click "+ ADD RESOURCE" in the bottom right
    3. Click the three dots in the top right
    4. ![HACS Integration](img.png)
    5. Enter the following:
        - URL: `/local/sunsynk-power-flow-card/sunsynk-power-flow-card.js?ver=1`
        - Resource type: JavaScript Module
    6. ![Dashboard Example](img_1.png)

<h3 align="left">⚙️ Card Configuration</h3>

1. Create a new dashboard or edit an existing one
2. Add a new card → Manual
3. Copy this configuration (adjust entity IDs as needed):

```yaml
type: custom:sunsynk-power-flow-card
cardstyle: full
show_solar: true
battery:
  energy: 28512
  shutdown_soc: 20
  show_daily: true
inverter:
  colour: green
solar:
  show_daily: true
  mppts: 2
load:
  show_daily: true
grid:
  show_daily_buy: true
  show_daily_sell: false
  show_nonessential: false
entities:
  battery_current_191: sensor.srne_battery_current
  battery_power_190: sensor.srne_battery_power
  battery_soc_184: sensor.srne_battery
  battery_voltage_183: sensor.srne_battery_voltage
  day_battery_charge_70: sensor.srne_today_battery_charge_ampere_hour
  day_battery_discharge_71: sensor.srne_today_battery_discharge_ampere_hour
  day_grid_import_76: sensor.srne_today_energy_import
  day_load_energy_84: sensor.srne_today_load_consumption
  day_pv_energy_108: sensor.srne_today_production
  dc_transformer_temp_90: sensor.srne_dc_temperature
  grid_ct_power_172: sensor.grid_l1_power_signed
  grid_power_167: sensor.srne_grid_l1_voltage
  inverter_current_164: sensor.srne_output_l1_current
  inverter_power_175: sensor.srne_load_l1_power
  inverter_voltage_154: sensor.srne_output_l1_voltage
  load_frequency_192: sensor.srne_output_frequency
  pv1_current_110: sensor.srne_pv1_current
  pv1_power_186: sensor.srne_pv1_power
  pv1_voltage_109: sensor.srne_pv1_voltage
  pv2_current_112: sensor.srne_pv2_current
  pv2_power_187: sensor.srne_pv2_power
  pv2_voltage_111: sensor.srne_pv2_voltage
  radiator_temp_91: sensor.srne_ac_temperature
large_font: true
```

### Important Notes

- Replace `energy: 28512` with your actual battery capacity in Wh
    - Calculate: Battery voltage × capacity in Ah
    - Example: 48V × 594Ah = 28,512 Wh
- Entity IDs (like `sensor.srne_battery_voltage`) must match your actual HA entities
- Add `?ver=1` to the resource URL and increment it when updating the card
- Clear your browser cache if the card doesn't appear after installation

### Troubleshooting

1. **Card Not Showing**
    - Verify the JS file exists in the correct location
    - Check browser console for errors (F12)
    - Try adding `?ver=2` to the resource URL
    - Clear browser cache and reload

2. **No Data Displayed**
    - Confirm entity IDs match your system
    - Check if entities are available in HA
    - Verify Solarman integration is working

3. **Permission Issues**
    - Linux: Ensure proper ownership with `chown -R 1000:1000`
    - Windows: Check Docker Desktop file sharing

<h2 id="mobile-app-installation">📱 Mobile App Installation</h2>

<div style="text-align: left">
<h3>Installing Home Assistant App</h3>

1. **Download the Official App**:
    - **Android**: [Google Play Store](https://play.google.com/store/apps/details?id=io.homeassistant.companion.android)
    - **iPhone/iPad**: [Apple App Store](https://apps.apple.com/us/app/home-assistant/id1099568401)

### Local Network Configuration

1. **Find Your Home Assistant URL**:
    - If using Orange Pi One: `http://[ethernet-ip]:8123`
    - If using Orange Pi Zero 3: `http://[wifi-or-ethernet-ip]:8123`
   > Replace [ethernet-ip] or [wifi-or-ethernet-ip] with your actual device IP

2. **Connect Mobile App**:
    1. Open Home Assistant app
    2. Tap "START"
    3. Select "Local Network" connection method
    4. Enter your Home Assistant URL
    5. Login with your credentials

### Mobile App Features

1. **Dashboard Access**:
    - View your Sunsynk Power Flow card
    - Monitor solar production
    - Check battery status
    - View grid consumption

2. **Push Notifications**:
    - Set up alerts for:
        - Low battery
        - High power consumption
        - Grid outages
        - System issues

3. **Sensors & Location**:
    - Enable/disable device sensors
    - Configure location tracking
    - Set up geofencing (optional)

### Troubleshooting Mobile Connection

1. **Can't Connect**:
    - Verify you're on the same network
    - Check if HA is running (http://localhost:8123)
    - Ensure port 8123 isn't blocked
    - Try using IP address instead of hostname

2. **App Showing Offline**:
    - Check network connectivity
    - Verify HA server is running
    - Restart the app
    - Clear app cache

3. **Slow Performance**:
    - Reduce number of entities
    - Optimize update intervals
    - Clear app cache
    - Check network speed

### Optional: Remote Access (Advanced)

For remote access without opening ports:

1. **Nabu Casa** (Paid Service):
    - Most secure option
    - Supports remote access
    - Includes SSL certificate
    - Simple setup

2. **VPN Solution**:
    - Set up WireGuard/OpenVPN on your router
    - Connect to home network remotely
    - Access HA through local URL
    - More technical but free

> 💡 **Tip**: For best performance and security, we recommend using the mobile app on your local network.

---

<h2 id="advanced-configuration">🔧 Advanced Configuration</h2>

<div style="text-align: left">
<h3>Customizing Sensor Definitions</h3>

- Edit `custom_components/solarman/inverter_definitions/srne_hesp.yaml`
- Adjust Modbus registers as needed
- Refer to SRNE Modbus Register Map for details

### Environment Variables

- `TZ`: Set your timezone (e.g., `Asia/Singapore`)
- `HA_CONFIG`: Custom Home Assistant config path (if not using default)

### Docker Compose Overrides

- Create `docker-compose.override.yml` for customizations
- Example: change ports, add volumes, etc.

```yaml
version: '3.8'
services:
  homeassistant:
    ports:
      - "8124:8123" # Change host port
    volumes:
      - /path/to/your/config:/config # Add custom volume
```

### Backup & Restore

- Regularly back up your Home Assistant config
- Use built-in HA snapshot feature
- Store backups offsite or in cloud storage

> ⚠️ **Warning**: Advanced configurations are for users who understand the implications. Incorrect settings may lead to system instability.

---

<h2 id="troubleshooting">❗ Troubleshooting</h2>

<div style="text-align: left">
<h3>Common Issues</h3>

1. **Home Assistant not starting**
    - Check Docker container logs: `docker logs homeassistant`
    - Ensure no port conflicts on the host
    - Verify config file syntax: `ha core check`

2. **Integration not found**
    - Confirm `custom_components/solarman` folder exists
    - Check file permissions
    - Restart Home Assistant

3. **Data not updating**
    - Verify network connection to inverter
    - Check Modbus register settings
    - Restart the Solarman integration

### Getting Help

- **Documentation**: Refer to this guide and linked resources
- **Community Forums**: Home Assistant and SRNE forums
- **GitHub Issues**: Search for similar issues or open a new one

> 💡 **Tip**: Before posting for help, gather relevant information:
> - Describe your setup (hardware, OS, Docker version)
> - List steps to reproduce the issue
> - Include error messages or logs

---

<h2 id="project-structure">📁 Project Structure</h2>

<div align="left">

```
srne-solarman/
├── docker-compose.yml          # Linux Docker configuration
├── docker-compose.windows.yml  # Windows Docker configuration
├── README.md                   # This documentation
├── srne-modbus-V2.07.pdf      # SRNE Modbus protocol reference
├── img.png                     # Documentation images
├── img_1.png
├── scripts/
│   ├── setup-linux.sh         # Linux automated setup
│   └── setup-windows.ps1      # Windows automated setup
└── templates/
    ├── configuration.yaml     # Home Assistant base config
    └── srne_hesp.yaml        # SRNE inverter definition
```

</div>

The configuration files in the `templates` directory are automatically copied to these locations during setup:

**Linux Container Paths:**
- `configuration.yaml` → `/config/configuration.yaml`
- `srne_hesp.yaml` → `/config/custom_components/solarman/inverter_definitions/srne_hesp.yaml`

**Windows Host Paths:**
- `configuration.yaml` → `C:\solarman\homeassistant_config\configuration.yaml`
- `srne_hesp.yaml` → `C:\solarman\homeassistant_config\custom_components\solarman\inverter_definitions\srne_hesp.yaml`

<h2 id="references-credits">📚 References & Credits</h2>

<div style="text-align: left">

### Main Projects
- [ha-solarman](https://github.com/davidrapan/ha-solarman) - Core integration for SRNE/Solarman inverters with Home Assistant
- [Sunsynk Power Flow Card](https://github.com/slipx06/sunsynk-power-flow-card) - Beautiful energy monitoring dashboard card
- [Home Assistant](https://www.home-assistant.io/) - The home automation platform we're building on

### Documentation
- [SRNE Modbus Register Map](srne-modbus-V2.07.pdf) - Complete protocol reference included in this repository
- [HA Docker Installation](https://www.home-assistant.io/installation/linux#docker) - Official HA Docker setup guide
- [Docker Documentation](https://docs.docker.com/get-started/) - Official Docker documentation

### Hardware
- Orange Pi Documentation
    - [Orange Pi One](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/details/Orange-Pi-One.html)
    - [Orange Pi Zero 3](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/details/Orange-Pi-Zero-3.html)

### Contributors & Thanks
- **David Rapan** ([@davidrapan](https://github.com/davidrapan))
    - Author of the ha-solarman integration
    - Core functionality and Modbus implementation

- **slipx06** ([@slipx06](https://github.com/slipx06))
    - Creator of the Sunsynk Power Flow card
    - Beautiful visualization components

- **SRNE / Solarman**
    - Hardware manufacturers
    - Protocol documentation

- **Home Assistant Community**
    - Testing and feedback
    - Bug reports and feature suggestions

### License Information
- This guide and setup scripts are provided under MIT License
- Component licenses:
    - ha-solarman: Check [repository](https://github.com/davidrapan/ha-solarman)
    - Sunsynk Power Flow card: Check [repository](https://github.com/slipx06/sunsynk-power-flow-card)
    - Home Assistant: Apache 2.0

> 💡 **Contributing**: Found a bug or want to improve this guide? Please open an issue or submit a pull request!

---

<div align="center">
  <h2>🌟 Found this useful?</h2>

  <p>
    <a href="https://github.com/davidrapan/ha-solarman">
      <img src="https://img.shields.io/github/stars/davidrapan/ha-solarman?style=for-the-badge" alt="GitHub Stars">
    </a>
    <a href="https://github.com/davidrapan/ha-solarman/issues">
      <img src="https://img.shields.io/github/issues/davidrapan/ha-solarman?style=for-the-badge" alt="GitHub Issues">
    </a>
  </p>

  <p>
    <a href="https://github.com/davidrapan/ha-solarman/issues">🐞 Report Issues</a> •
    <a href="https://github.com/davidrapan/ha-solarman/issues/new">💡 Request Features</a>
  </p>
</div>
</div>

</div>

</div>

</div>

</div>

</div>
