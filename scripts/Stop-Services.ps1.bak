# Stop-Services.ps1
# Stops Apache and MariaDB Windows services for IsotoneStack
# Requires Administrator privileges

param(
    [switch]$Apache,     # Stop only Apache service
    [switch]$MariaDB,    # Stop only MariaDB service
    [switch]$Force       # Force stop even if dependencies exist
)

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logsPath "$scriptName`_$timestamp.log"

# Service names
$apacheServiceName = "IsotoneApache"
$mariadbServiceName = "IsotoneMariaDB"

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    
    # Also write to console with appropriate color (unless NoConsole specified)
    if (-not $NoConsole) {
        switch ($Level) {
            "ERROR"   { Write-Host $Message -ForegroundColor Red }
            "WARNING" { Write-Host $Message -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $Message -ForegroundColor Green }
            "INFO"    { Write-Host $Message -ForegroundColor White }
            "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
            "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
            "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
            "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
            default   { Write-Host $Message }
        }
    }
}

# Function to check if a service exists
function Test-ServiceExists {
    param([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    return $null -ne $service
}

# Function to stop a service
function Stop-ServiceSafe {
    param(
        [string]$ServiceName,
        [switch]$Force
    )
    
    if (!(Test-ServiceExists $ServiceName)) {
        Write-Log "  [NOT FOUND] Service '$ServiceName' is not registered" "WARNING"
        return $true  # Consider it "stopped" if it doesn't exist
    }
    
    $service = Get-Service -Name $ServiceName
    
    if ($service.Status -eq 'Stopped') {
        Write-Log "  [OK] Service already stopped: $ServiceName" "SUCCESS"
        return $true
    }
    
    Write-Log "  Stopping service: $ServiceName" "INFO"
    try {
        if ($Force) {
            Stop-Service -Name $ServiceName -Force -ErrorAction Stop
        } else {
            Stop-Service -Name $ServiceName -ErrorAction Stop
        }
        
        # Wait for service to stop (max 30 seconds)
        $timeout = 30
        $waited = 0
        while ((Get-Service -Name $ServiceName).Status -ne 'Stopped' -and $waited -lt $timeout) {
            Start-Sleep -Seconds 1
            $waited++
        }
        
        if ((Get-Service -Name $ServiceName).Status -eq 'Stopped') {
            Write-Log "  [OK] Service stopped: $ServiceName" "SUCCESS"
            return $true
        } else {
            Write-Log "  [WARNING] Service did not stop within timeout: $ServiceName" "WARNING"
            return $false
        }
    } catch {
        Write-Log "  [ERROR] Failed to stop service: $_" "ERROR"
        return $false
    }
}

try {
    # Start logging
    Write-Log "========================================" "INFO"
    Write-Log "IsotoneStack Service Stop Started" "INFO"
    Write-Log "Installation Directory: $isotonePath" "INFO"
    Write-Log "Parameters: Apache=$Apache, MariaDB=$MariaDB, Force=$Force" "INFO"
    Write-Log "========================================" "INFO"
    
    Write-Host ""
    Write-Log "=== Stopping IsotoneStack Services ===" "MAGENTA"
    Write-Host ""
    
    # Check for Administrator privileges
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "This script requires Administrator privileges" "ERROR"
        Write-Log "Please run this script as Administrator" "ERROR"
        exit 1
    }
    Write-Log "[OK] Running with Administrator privileges" "SUCCESS"
    Write-Host ""
    
    # Determine which services to stop
    $stopApache = $true
    $stopMariaDB = $true
    
    if ($Apache -and !$MariaDB) {
        $stopMariaDB = $false
        Write-Log "Stopping Apache service only" "INFO"
    } elseif ($MariaDB -and !$Apache) {
        $stopApache = $false
        Write-Log "Stopping MariaDB service only" "INFO"
    } else {
        Write-Log "Stopping all services" "INFO"
    }
    
    Write-Host ""
    
    # Track results
    $apacheStopped = $false
    $mariadbStopped = $false
    
    # =================================================================
    # Stop Apache Service (stop first as it may depend on MariaDB)
    # =================================================================
    if ($stopApache) {
        Write-Log "Apache Service:" "CYAN"
        $apacheStopped = Stop-ServiceSafe -ServiceName $apacheServiceName -Force:$Force
        Write-Host ""
    }
    
    # =================================================================
    # Stop MariaDB Service
    # =================================================================
    if ($stopMariaDB) {
        Write-Log "MariaDB Service:" "CYAN"
        $mariadbStopped = Stop-ServiceSafe -ServiceName $mariadbServiceName -Force:$Force
        Write-Host ""
    }
    
    # =================================================================
    # Summary
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Service Status Summary" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check final status
    if ($stopApache) {
        if (Test-ServiceExists $apacheServiceName) {
            $apacheService = Get-Service -Name $apacheServiceName
            $statusColor = if ($apacheService.Status -eq 'Stopped') { "SUCCESS" } else { "WARNING" }
            Write-Log "Apache:  $($apacheService.Status)" $statusColor
        } else {
            Write-Log "Apache:  Not Registered" "WARNING"
        }
    }
    
    if ($stopMariaDB) {
        if (Test-ServiceExists $mariadbServiceName) {
            $mariadbService = Get-Service -Name $mariadbServiceName
            $statusColor = if ($mariadbService.Status -eq 'Stopped') { "SUCCESS" } else { "WARNING" }
            Write-Log "MariaDB: $($mariadbService.Status)" $statusColor
        } else {
            Write-Log "MariaDB: Not Registered" "WARNING"
        }
    }
    
    Write-Host ""
    
    # Overall success/failure
    $allSuccess = $true
    if ($stopApache -and !$apacheStopped) { $allSuccess = $false }
    if ($stopMariaDB -and !$mariadbStopped) { $allSuccess = $false }
    
    if ($allSuccess) {
        Write-Log "[SUCCESS] All requested services stopped successfully" "SUCCESS"
    } else {
        Write-Log "[WARNING] Some services failed to stop" "WARNING"
        Write-Log "Check the log file for details: $logFile" "INFO"
        if (!$Force) {
            Write-Log "Try using -Force parameter to force stop" "INFO"
        }
    }
    
    Write-Host ""
    Write-Log "Next steps:" "INFO"
    Write-Log "  To start services again: Start-Services.ps1" "DEBUG"
    Write-Log "  To unregister services: Unregister-Services.ps1" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "INFO"
    Write-Log "Service stop completed" "INFO"
    Write-Log "Log file: $logFile" "INFO"
    Write-Log "========================================" "INFO"
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service stop failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}