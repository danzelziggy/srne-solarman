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

function Write-Step {
    param([string]$Message)
    Write-Host "🔹 $Message" -ForegroundColor Cyan
}

function Install-Prerequisites {
    # Check and install Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Step "Downloading Git for Windows..."
        $gitInstaller = Join-Path $env:TEMP "GitInstaller.exe"
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing

        Write-Step "Installing Git..."
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait
        Remove-Item $gitInstaller -Force

        # Add Git to PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    # Check and install Docker Desktop
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Step "Downloading Docker Desktop..."
        $dockerInstaller = Join-Path $env:TEMP "DockerDesktopInstaller.exe"
        Invoke-WebRequest -Uri $dockerUrl -OutFile $dockerInstaller -UseBasicParsing

        Write-Step "Installing Docker Desktop..."
        Start-Process -FilePath $dockerInstaller -ArgumentList "install --quiet" -Wait
        Remove-Item $dockerInstaller -Force

        Write-Host "⚠️ Please restart your computer after Docker Desktop installation" -ForegroundColor Yellow
        Write-Host "Then run this script again to continue the setup" -ForegroundColor Yellow
        exit 0
    }

    # Verify Docker is running
    try {
        $null = docker info
    } catch {
        Write-Error "Docker Desktop is not running. Please start Docker Desktop and try again."
        exit 1
    }
}

# Main installation
try {
    Write-Host "🚀 Starting SRNE Solarman setup..." -ForegroundColor Green

    Write-Step "Installing prerequisites..."
    Install-Prerequisites

    Write-Step "Using config directory: $ConfigDir"

    # Create directories
    Write-Step "Creating directories..."
    New-Item -Path "$ConfigDir" -ItemType Directory -Force | Out-Null
    New-Item -Path "$ConfigDir\custom_components\solarman\inverter_definitions" -ItemType Directory -Force | Out-Null
    New-Item -Path "$ConfigDir\www\sunsynk-power-flow-card" -ItemType Directory -Force | Out-Null

    # Copy configuration files
    Write-Step "Copying configuration files..."
    # Determine repository root (script is in scripts\)
    $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    $templatesDir = Join-Path $repoRoot 'templates'

    Copy-Item -Path (Join-Path $templatesDir 'configuration.yaml') -Destination "$ConfigDir\" -Force
    Copy-Item -Path (Join-Path $templatesDir 'srne_hesp.yaml') -Destination "$ConfigDir\custom_components\solarman\inverter_definitions\" -Force

    # Clone repository
    Write-Step "Cloning ha-solarman..."
    if (Test-Path -Path $tmp) {
        Remove-Item -Recurse -Force -Path $tmp
    }
    git clone $repo $tmp

    # Install custom component
    Write-Step "Installing ha-solarman integration..."
    $destComponents = Join-Path $ConfigDir 'custom_components'
    Copy-Item -Path (Join-Path $tmp 'custom_components\solarman') -Destination $destComponents -Recurse -Force

    # Install Sunsynk card
    Write-Step "Installing Sunsynk Power Flow card..."
    $wwwDir = Join-Path $ConfigDir 'www\sunsynk-power-flow-card'
    Invoke-WebRequest -Uri $sunsynkUrl -OutFile (Join-Path $wwwDir 'sunsynk-power-flow-card.js') -UseBasicParsing

    # Docker operations
    Write-Step "Managing Docker container..."
    try {
        docker compose up -d
        docker compose restart homeassistant
    } catch {
        Write-Warning "Docker operations failed. Please ensure Docker Desktop is running and try again."
        Write-Warning "Error: $_"
    }

    # Cleanup
    if (Test-Path -Path $tmp) {
        Remove-Item -Recurse -Force -Path $tmp
    }

    Write-Host "`n✅ Installation complete!" -ForegroundColor Green
    Write-Host "`nNext steps:"
    Write-Host "1. Open Home Assistant: http://localhost:8123"
    Write-Host "2. Go to Settings → Dashboards → Resources"
    Write-Host "3. Add resource: /local/sunsynk-power-flow-card/sunsynk-power-flow-card.js"
    Write-Host "4. Configure Solarman integration via Settings → Devices & Services"
    Write-Host "`nFor troubleshooting, check the README.md"

} catch {
    Write-Error "Installation failed: $_"
    exit 1
}
