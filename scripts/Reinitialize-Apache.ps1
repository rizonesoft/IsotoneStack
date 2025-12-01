#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Reinitializes Apache HTTP Server by resetting configuration to defaults.

.DESCRIPTION
    This script backs up the current Apache configuration, restores it from templates,
    and re-registers the Apache service.
#>

# Get script and isotone root paths
$ScriptRoot = $PSScriptRoot
$IsotoneRoot = Split-Path -Parent $ScriptRoot

# Apache paths
$ApachePath = Join-Path $IsotoneRoot "apache24"
$ApacheBin = Join-Path $ApachePath "bin"
$ApacheConf = Join-Path $ApachePath "conf"
$ApacheHttpdExe = Join-Path $ApacheBin "httpd.exe"
$ApacheConfigFile = Join-Path $ApacheConf "httpd.conf"

# Config template
$ConfigPath = Join-Path $IsotoneRoot "config"
$ApacheTemplate = Join-Path $ConfigPath "apache\httpd.conf"

# Backup directory
$BackupDir = Join-Path $IsotoneRoot "backups\apache-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host ""
Write-Host "=== Apache Reinitialization ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[ERROR] This script requires Administrator privileges." -ForegroundColor Red
    exit 1
}

# Check if Apache exists
if (!(Test-Path $ApacheHttpdExe)) {
    Write-Host "[ERROR] Apache not found at: $ApacheHttpdExe" -ForegroundColor Red
    exit 1
}

# Stop Apache service if running
Write-Host "Stopping Apache service..." -ForegroundColor Yellow
try {
    $service = Get-Service -Name "IsotoneApache" -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        Stop-Service -Name "IsotoneApache" -Force -ErrorAction Stop
        Start-Sleep -Seconds 2
        Write-Host "[OK] Service stopped" -ForegroundColor Green
    } else {
        Write-Host "[OK] Service not running" -ForegroundColor Green
    }
} catch {
    Write-Host "[WARNING] Could not stop service: $_" -ForegroundColor Yellow
}

# Remove existing service if it exists
Write-Host "Removing existing service..." -ForegroundColor Yellow
try {
    $service = Get-Service -Name "IsotoneApache" -ErrorAction SilentlyContinue
    if ($service) {
        & sc.exe delete "IsotoneApache" | Out-Null
        Start-Sleep -Seconds 1
        Write-Host "[OK] Service removed" -ForegroundColor Green
    } else {
        Write-Host "[OK] Service does not exist" -ForegroundColor Green
    }
} catch {
    Write-Host "[WARNING] Could not remove service: $_" -ForegroundColor Yellow
}

# Kill any remaining httpd processes
Write-Host "Checking for running Apache processes..." -ForegroundColor Yellow
$processes = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($processes) {
    Write-Host "[OK] Stopping $($processes.Count) process(es)" -ForegroundColor Yellow
    $processes | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "[OK] Processes stopped" -ForegroundColor Green
} else {
    Write-Host "[OK] No processes running" -ForegroundColor Green
}

# Backup existing configuration
if (Test-Path $ApacheConfigFile) {
    Write-Host "Backing up existing configuration..." -ForegroundColor Yellow
    try {
        New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
        Copy-Item -Path "$ApacheConf\*" -Destination $BackupDir -Recurse -Force -ErrorAction Stop
        Write-Host "[OK] Backup created at: $BackupDir" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Backup failed: $_" -ForegroundColor Yellow
    }
}

# Restore configuration from template
Write-Host "Restoring Apache configuration from template..." -ForegroundColor Yellow
if (Test-Path $ApacheTemplate) {
    try {
        # Read template and replace variables
        $content = Get-Content -Path $ApacheTemplate -Raw
        $installPathFS = $IsotoneRoot.Replace('\', '/')
        $installPathBS = $IsotoneRoot
        $currentYear = (Get-Date).Year
        
        $content = $content -replace '{{INSTALL_PATH}}', $installPathFS
        $content = $content -replace '{{INSTALL_PATH_BS}}', $installPathBS
        $content = $content -replace '{{YEAR}}', $currentYear
        $content = $content -replace 'C:/isotone', $installPathFS
        $content = $content -replace 'C:\\isotone', $installPathBS
        
        # Write configuration
        Set-Content -Path $ApacheConfigFile -Value $content -Encoding UTF8
        Write-Host "[OK] Configuration restored from template" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to restore configuration: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[ERROR] Template not found at: $ApacheTemplate" -ForegroundColor Red
    exit 1
}

# Re-register the service
Write-Host "Re-registering Apache service..." -ForegroundColor Yellow
try {
    Push-Location $ApacheBin
    
    $installArgs = @("-k", "install", "-n", "IsotoneApache", "-f", $ApacheConfigFile)
    & .\httpd.exe $installArgs 2>&1 | Out-Null
    
    Start-Sleep -Seconds 2
    
    $service = Get-Service -Name "IsotoneApache" -ErrorAction SilentlyContinue
    if ($service) {
        # Set service to manual start
        & sc.exe config "IsotoneApache" start= demand | Out-Null
        & sc.exe description "IsotoneApache" "IsotoneStack Apache HTTP Server" | Out-Null
        Write-Host "[OK] Apache service registered" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Service registration may have failed" -ForegroundColor Yellow
    }
    
    Pop-Location
} catch {
    Write-Host "[WARNING] Could not register service: $_" -ForegroundColor Yellow
    Pop-Location
}

Write-Host ""
Write-Host "=== Apache Reinitialization Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "You can now start the Apache service from Iso-control." -ForegroundColor Cyan
Write-Host ""
