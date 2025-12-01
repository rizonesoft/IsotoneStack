#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Reinitializes MariaDB database by clearing data directory and creating system tables.

.DESCRIPTION
    This script backs up and clears the MariaDB data directory, then reinitializes
    it with proper system tables using mysql_install_db.
#>

# Get script and isotone root paths
$ScriptRoot = $PSScriptRoot
$IsotoneRoot = Split-Path -Parent $ScriptRoot

# MariaDB paths
$MariaDBDataDir = Join-Path $IsotoneRoot "mariadb\data"
$MariaDBBin = Join-Path $IsotoneRoot "mariadb\bin"
$MySQLInstallDB = Join-Path $MariaDBBin "mysql_install_db.exe"

# Backup directory
$BackupDir = Join-Path $IsotoneRoot "backups\mariadb-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host ""
Write-Host "=== MariaDB Reinitialization ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[ERROR] This script requires Administrator privileges." -ForegroundColor Red
    exit 1
}

# Stop MariaDB service if running
Write-Host "Stopping MariaDB service..." -ForegroundColor Yellow
try {
    $service = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        Stop-Service -Name "IsotoneMariaDB" -Force -ErrorAction Stop
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
    $service = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if ($service) {
        & sc.exe delete "IsotoneMariaDB" | Out-Null
        Start-Sleep -Seconds 1
        Write-Host "[OK] Service removed" -ForegroundColor Green
    } else {
        Write-Host "[OK] Service does not exist" -ForegroundColor Green
    }
} catch {
    Write-Host "[WARNING] Could not remove service: $_" -ForegroundColor Yellow
}

# Kill any remaining mariadbd processes
Write-Host "Checking for running MariaDB processes..." -ForegroundColor Yellow
$processes = Get-Process -Name "mariadbd","mysqld" -ErrorAction SilentlyContinue
if ($processes) {
    Write-Host "[OK] Stopping $($processes.Count) process(es)" -ForegroundColor Yellow
    $processes | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "[OK] Processes stopped" -ForegroundColor Green
} else {
    Write-Host "[OK] No processes running" -ForegroundColor Green
}

# Backup existing data directory
if (Test-Path $MariaDBDataDir) {
    Write-Host "Backing up existing data directory..." -ForegroundColor Yellow
    try {
        New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
        Copy-Item -Path "$MariaDBDataDir\*" -Destination $BackupDir -Recurse -Force -ErrorAction Stop
        Write-Host "[OK] Backup created at: $BackupDir" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Backup failed: $_" -ForegroundColor Yellow
    }
}

# Clear data directory
Write-Host "Clearing data directory..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
try {
    Get-ChildItem -Path $MariaDBDataDir -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction Stop
    Write-Host "[OK] Data directory cleared" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to clear data directory: $_" -ForegroundColor Red
    Write-Host "       Try closing any applications accessing the files or reboot." -ForegroundColor Red
    exit 1
}

# Run mysql_install_db
Write-Host "Initializing MariaDB system tables..." -ForegroundColor Yellow
try {
    # Note: We don't use --service here because the service should already exist
    # and is managed separately by Register-Services.ps1
    $installArgs = @(
        "--datadir=`"$MariaDBDataDir`"",
        "--default-user"
    )
    
    $process = Start-Process -FilePath $MySQLInstallDB -ArgumentList $installArgs -Wait -NoNewWindow -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "[OK] MariaDB initialized successfully" -ForegroundColor Green
    } else {
        throw "mysql_install_db exited with code $($process.ExitCode)"
    }
} catch {
    Write-Host "[ERROR] Failed to initialize MariaDB: $_" -ForegroundColor Red
    exit 1
}

# Re-register the service
Write-Host "Re-registering MariaDB service..." -ForegroundColor Yellow
try {
    $mariadbd = Join-Path $MariaDBBin "mariadbd.exe"
    $mariadbConfig = Join-Path $IsotoneRoot "mariadb\my.ini"
    
    if (Test-Path $mariadbConfig) {
        & $mariadbd --install "IsotoneMariaDB" --defaults-file="`"$mariadbConfig`"" 2>&1 | Out-Null
    } else {
        & $mariadbd --install "IsotoneMariaDB" 2>&1 | Out-Null
    }
    
    Start-Sleep -Seconds 2
    
    $service = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "[OK] MariaDB service registered" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Service registration may have failed" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[WARNING] Could not register service: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== MariaDB Reinitialization Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "You can now start the MariaDB service from Iso-control." -ForegroundColor Cyan
Write-Host "Default root password: (blank)" -ForegroundColor Cyan
Write-Host ""
