#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Restores MariaDB database from a backup.

.DESCRIPTION
    This script stops MariaDB, restores data from a backup directory,
    and re-registers the service.

.PARAMETER BackupPath
    Path to the backup directory to restore from.
    Example: R:\isotone\backups\mariadb-20251124-154021

.EXAMPLE
    .\Restore-MariaDB.ps1 -BackupPath "R:\isotone\backups\mariadb-20251124-154021"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$BackupPath
)

# Get script and isotone root paths
$ScriptRoot = $PSScriptRoot
$IsotoneRoot = Split-Path -Parent $ScriptRoot

# MariaDB paths
$MariaDBDataDir = Join-Path $IsotoneRoot "mariadb\data"
$MariaDBBin = Join-Path $IsotoneRoot "mariadb\bin"

Write-Host ""
Write-Host "=== MariaDB Restore ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[ERROR] This script requires Administrator privileges." -ForegroundColor Red
    exit 1
}

# If no backup path provided, list available backups
if (-not $BackupPath) {
    $backupsDir = Join-Path $IsotoneRoot "backups"
    Write-Host "Available MariaDB backups:" -ForegroundColor Yellow
    Write-Host ""
    
    if (Test-Path $backupsDir) {
        $backups = Get-ChildItem -Path $backupsDir -Directory -Filter "mariadb-*" | Sort-Object Name -Descending
        
        if ($backups.Count -eq 0) {
            Write-Host "[ERROR] No MariaDB backups found in: $backupsDir" -ForegroundColor Red
            exit 1
        }
        
        for ($i = 0; $i -lt $backups.Count; $i++) {
            $backup = $backups[$i]
            $size = (Get-ChildItem -Path $backup.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
            Write-Host "  [$($i+1)] $($backup.Name)" -ForegroundColor White
            Write-Host "      Path: $($backup.FullName)" -ForegroundColor Gray
            Write-Host "      Size: $([math]::Round($size, 2)) MB" -ForegroundColor Gray
            Write-Host ""
        }
        
        Write-Host "Please specify a backup to restore:" -ForegroundColor Yellow
        Write-Host "  .\Restore-MariaDB.ps1 -BackupPath ""<path>""" -ForegroundColor Cyan
        Write-Host ""
        exit 0
    } else {
        Write-Host "[ERROR] Backups directory not found: $backupsDir" -ForegroundColor Red
        exit 1
    }
}

# Validate backup path
if (-not (Test-Path $BackupPath)) {
    Write-Host "[ERROR] Backup path not found: $BackupPath" -ForegroundColor Red
    exit 1
}

# Check if backup contains mysql directory (system database)
$mysqlBackupDir = Join-Path $BackupPath "mysql"
if (-not (Test-Path $mysqlBackupDir)) {
    Write-Host "[WARNING] Backup does not contain 'mysql' system database." -ForegroundColor Yellow
    Write-Host "          This may not be a valid MariaDB backup." -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Continue anyway? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Restore cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "Restore source: $BackupPath" -ForegroundColor Cyan
Write-Host "Restore target: $MariaDBDataDir" -ForegroundColor Cyan
Write-Host ""

# Confirm restore
Write-Host "[WARNING] This will replace all current MariaDB data!" -ForegroundColor Yellow
Write-Host "          Current data will be backed up before restore." -ForegroundColor Yellow
Write-Host ""
$response = Read-Host "Are you sure you want to continue? (y/N)"
if ($response -ne 'y' -and $response -ne 'Y') {
    Write-Host "Restore cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

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

# Remove existing service
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

# Backup current data directory before restore
if (Test-Path $MariaDBDataDir) {
    $preRestoreBackup = Join-Path $IsotoneRoot "backups\mariadb-pre-restore-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "Backing up current data directory..." -ForegroundColor Yellow
    try {
        New-Item -Path $preRestoreBackup -ItemType Directory -Force | Out-Null
        Copy-Item -Path "$MariaDBDataDir\*" -Destination $preRestoreBackup -Recurse -Force -ErrorAction Stop
        Write-Host "[OK] Pre-restore backup created at: $preRestoreBackup" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Pre-restore backup failed: $_" -ForegroundColor Yellow
    }
}

# Clear current data directory
Write-Host "Clearing data directory..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
try {
    if (Test-Path $MariaDBDataDir) {
        Get-ChildItem -Path $MariaDBDataDir -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction Stop
    }
    Write-Host "[OK] Data directory cleared" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to clear data directory: $_" -ForegroundColor Red
    Write-Host "       Try closing any applications accessing the files or reboot." -ForegroundColor Red
    exit 1
}

# Restore from backup
Write-Host "Restoring data from backup..." -ForegroundColor Yellow
try {
    # Ensure data directory exists
    if (-not (Test-Path $MariaDBDataDir)) {
        New-Item -Path $MariaDBDataDir -ItemType Directory -Force | Out-Null
    }
    
    # Copy all files from backup
    Copy-Item -Path "$BackupPath\*" -Destination $MariaDBDataDir -Recurse -Force -ErrorAction Stop
    Write-Host "[OK] Data restored from backup" -ForegroundColor Green
    
    # Count databases
    $databases = Get-ChildItem -Path $MariaDBDataDir -Directory | Where-Object { $_.Name -notmatch "^(mysql|performance_schema|sys|phpmyadmin)$" }
    Write-Host "[OK] Restored $($databases.Count) user database(s)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to restore data: $_" -ForegroundColor Red
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
Write-Host "=== MariaDB Restore Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Restored from: $BackupPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now start the MariaDB service from Iso-control." -ForegroundColor Cyan
Write-Host ""
