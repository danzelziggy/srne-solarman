# Requires -RunAsAdministrator
<#
.SYNOPSIS
    Setup script for SRNE Solarman Home Assistant integration on Windows.
.DESCRIPTION
    Installs Docker Desktop, Git, the ha-solarman integration and Sunsynk Power Flow card for Home Assistant.
.PARAMETER ConfigDir
    Home Assistant configuration directory. Defaults to 'C:\solarman\homeassistant_config'
.EXAMPLE
    .\scripts\setup-windows.ps1 -ConfigDir 'C:\solarman\homeassistant_config'
#>
[CmdletBinding()]
param(
    [string]$ConfigDir = 'C:\solarman\homeassistant_config'
)

$ErrorActionPreference = 'Stop'
$repo = 'https://github.com/davidrapan/ha-solarman.git'
$sunsynkUrl = 'https://raw.githubusercontent.com/slipx06/sunsynk-power-flow-card/v7.0.0/dist/sunsynk-power-flow-card.js'
$dockerUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
$gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe"
$tmp = Join-Path $env:TEMP 'ha-solarman'

# Determine repository root (script is in scripts\)
$repoRoot = Split-Path -Parent $PSScriptRoot
$composeFile = Join-Path $repoRoot 'docker-compose.windows.yml'

function Write-Step {
    param([string]$Message)
    Write-Host "🔹 $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Install-Prerequisites {
    # Check and install Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Step "Git not found. Downloading Git for Windows..."
        $gitInstaller = Join-Path $env:TEMP "GitInstaller.exe"

        try {
            Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
            Write-Step "Installing Git (this may take a few minutes)..."
            Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait
            Remove-Item $gitInstaller -Force

            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            Write-Success "Git installed successfully"
        } catch {
            Write-Error "Failed to install Git: $_"
            exit 1
        }
    } else {
        Write-Success "Git is already installed"
    }

    # Check and install Docker Desktop
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Step "Docker not found. Downloading Docker Desktop..."
        Write-Warning-Custom "This is a large download (500+ MB) and may take several minutes"
        $dockerInstaller = Join-Path $env:TEMP "DockerDesktopInstaller.exe"

        try {
            Invoke-WebRequest -Uri $dockerUrl -OutFile $dockerInstaller -UseBasicParsing
            Write-Step "Installing Docker Desktop..."
            Start-Process -FilePath $dockerInstaller -ArgumentList "install --quiet" -Wait
            Remove-Item $dockerInstaller -Force

            Write-Host ""
            Write-Warning-Custom "Docker Desktop has been installed"
            Write-Warning-Custom "You MUST restart your computer now"
            Write-Host ""
            Write-Host "After restarting:" -ForegroundColor Cyan
            Write-Host "  1. Start Docker Desktop from the Start Menu" -ForegroundColor Cyan
            Write-Host "  2. Wait for Docker to fully start" -ForegroundColor Cyan
            Write-Host "  3. Run this script again" -ForegroundColor Cyan
            Write-Host ""
            exit 0
        } catch {
            Write-Error "Failed to install Docker Desktop: $_"
            exit 1
        }
    } else {
        Write-Success "Docker is already installed"
    }

    # Verify Docker is running
    Write-Step "Checking if Docker is running..."
    try {
        $null = docker info 2>&1
        Write-Success "Docker is running"
    } catch {
        Write-Host ""
        Write-Error "Docker Desktop is not running!"
        Write-Host ""
        Write-Host "Please:" -ForegroundColor Yellow
        Write-Host "  1. Start Docker Desktop from the Start Menu" -ForegroundColor Yellow
        Write-Host "  2. Wait for it to fully start (icon in system tray will stop animating)" -ForegroundColor Yellow
        Write-Host "  3. Run this script again" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
}

# Main installation
try {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "🚀 SRNE Solarman Home Assistant Setup" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Host "⏱️  This will take 10-15 minutes" -ForegroundColor Cyan
    Write-Host "📦 What this script does:" -ForegroundColor Cyan
    Write-Host "   • Installs Docker Desktop (if needed)"
    Write-Host "   • Installs Git (if needed)"
    Write-Host "   • Downloads Home Assistant"
    Write-Host "   • Installs Solarman integration"
    Write-Host "   • Installs beautiful dashboard card"
    Write-Host "   • Starts everything automatically"
    Write-Host ""

    # Check for Administrator rights
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Error "This script must be run as Administrator!"
        Write-Host ""
        Write-Host "Please:" -ForegroundColor Yellow
        Write-Host "  1. Right-click PowerShell" -ForegroundColor Yellow
        Write-Host "  2. Select 'Run as Administrator'" -ForegroundColor Yellow
        Write-Host "  3. Run this script again" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "📦 Step 1/7: Installing prerequisites..." -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Install-Prerequisites

    Write-Host ""
    Write-Step "Using config directory: $ConfigDir"
    Write-Host ""

    # Create directories
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "📁 Step 2/7: Creating directories..." -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    New-Item -Path "$ConfigDir" -ItemType Directory -Force | Out-Null
    New-Item -Path "$ConfigDir\custom_components\solarman\inverter_definitions" -ItemType Directory -Force | Out-Null
    New-Item -Path "$ConfigDir\www\sunsynk-power-flow-card" -ItemType Directory -Force | Out-Null

    # Copy configuration files
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "📄 Step 3/7: Copying configuration files..." -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    $templatesDir = Join-Path $repoRoot 'templates'

    if (Test-Path (Join-Path $templatesDir 'configuration.yaml')) {
        Copy-Item -Path (Join-Path $templatesDir 'configuration.yaml') -Destination "$ConfigDir\" -Force
        Copy-Item -Path (Join-Path $templatesDir 'srne_hesp.yaml') -Destination "$ConfigDir\custom_components\solarman\inverter_definitions\" -Force
        Write-Success "Configuration files copied"
    } else {
        Write-Warning-Custom "Templates directory not found, skipping configuration file copy"
    }

    # Clone repository
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "📥 Step 4/7: Downloading ha-solarman integration..." -ForegroundColor Green
    Write-Host "    (This connects to your SRNE inverter)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    if (Test-Path -Path $tmp) {
        Remove-Item -Recurse -Force -Path $tmp
    }
    git clone $repo $tmp 2>&1 | Out-Null

    # Install custom component
    Write-Step "Installing Solarman integration..."
    $destComponents = Join-Path $ConfigDir 'custom_components'
    Copy-Item -Path (Join-Path $tmp 'custom_components\solarman') -Destination $destComponents -Recurse -Force
    Write-Success "Solarman integration installed"

    # Install Sunsynk card
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "📥 Step 5/7: Downloading Sunsynk Power Flow card..." -ForegroundColor Green
    Write-Host "    (This makes your dashboard look beautiful!)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    $wwwDir = Join-Path $ConfigDir 'www\sunsynk-power-flow-card'
    Invoke-WebRequest -Uri $sunsynkUrl -OutFile (Join-Path $wwwDir 'sunsynk-power-flow-card.js') -UseBasicParsing
    Write-Success "Power Flow card installed"

    # Create docker-compose file
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "🐳 Step 6/7: Creating Docker Compose configuration..." -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    $composeContent = @"
version: '3.8'
services:
  homeassistant:
    container_name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    ports:
      - "8123:8123"
    volumes:
      - "$($ConfigDir -replace '\\', '\\'):/config"
    environment:
      - TZ=Asia/Singapore
    restart: unless-stopped
"@
    Set-Content -Path $composeFile -Value $composeContent
    Write-Success "Docker Compose file created"

    # Docker operations
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "🔄 Step 7/7: Starting Home Assistant container..." -ForegroundColor Green
    Write-Host "    (Please wait, this may take 1-2 minutes)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Push-Location $repoRoot
    try {
        # Check if container exists
        $containerExists = docker ps -a --format "{{.Names}}" | Select-String -Pattern "^homeassistant$"

        if ($containerExists) {
            Write-Step "Container exists, restarting..."
            docker restart homeassistant | Out-Null
            Write-Success "Container restarted"
        } else {
            Write-Step "Creating new container..."
            docker compose -f docker-compose.windows.yml up -d | Out-Null
            Write-Success "Container created and started"
        }
    } catch {
        Write-Warning-Custom "Docker operations failed: $_"
        Write-Warning-Custom "You may need to start the container manually"
    } finally {
        Pop-Location
    }

    # Cleanup
    Write-Step "Cleaning up temporary files..."
    if (Test-Path -Path $tmp) {
        Remove-Item -Recurse -Force -Path $tmp
    }

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "✅ Installation Complete!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Access Home Assistant at: http://localhost:8123" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Wait 1-2 minutes for Home Assistant to start"
    Write-Host "   2. Open http://localhost:8123 in your browser"
    Write-Host "   3. Complete the initial setup wizard"
    Write-Host "   4. Go to Settings → Dashboards → Resources"
    Write-Host "   5. Add resource: /local/sunsynk-power-flow-card/sunsynk-power-flow-card.js?ver=1"
    Write-Host "   6. Go to Settings → Devices & Services"
    Write-Host "   7. Add 'Solarman' integration with:"
    Write-Host "      - Title: SRNE"
    Write-Host "      - Profile: srne_hesp.yaml"
    Write-Host "      - IP: [Your dongle's IP address]"
    Write-Host ""
    Write-Host "📖 For detailed instructions, see the README.md" -ForegroundColor Cyan
    Write-Host "🐛 Having issues? Check the troubleshooting section in README.md" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host ""
    Write-Error "Installation failed: $_"
    Write-Host ""
    Write-Host "Please check the error message above and try again." -ForegroundColor Yellow
    Write-Host "For help, see the troubleshooting section in README.md" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
