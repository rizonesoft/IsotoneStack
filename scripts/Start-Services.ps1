# Start-Services.ps1
# Starts Apache and MariaDB Windows services for IsotoneStack
# Requires Administrator privileges

param(
    [switch]$Apache,     # Start only Apache service
    [switch]$MariaDB,    # Start only MariaDB service
    [switch]$Force       # Force start even if already running
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

# Function to start a service
function Start-ServiceSafe {
    param(
        [string]$ServiceName,
        [switch]$Force
    )
    
    if (!(Test-ServiceExists $ServiceName)) {
        Write-Log "  [NOT FOUND] Service '$ServiceName' is not registered" "WARNING"
        return $false
    }
    
    $service = Get-Service -Name $ServiceName
    
    if ($service.Status -eq 'Running') {
        if ($Force) {
            Write-Log "  Service already running, restarting: $ServiceName" "WARNING"
            try {
                Restart-Service -Name $ServiceName -Force -ErrorAction Stop
                Write-Log "  [OK] Service restarted: $ServiceName" "SUCCESS"
                return $true
            } catch {
                Write-Log "  [ERROR] Failed to restart service: $_" "ERROR"
                return $false
            }
        } else {
            Write-Log "  [OK] Service already running: $ServiceName" "SUCCESS"
            return $true
        }
    }
    
    Write-Log "  Starting service: $ServiceName" "INFO"
    try {
        Start-Service -Name $ServiceName -ErrorAction Stop
        
        # Wait for service to start (max 30 seconds)
        $timeout = 30
        $waited = 0
        while ((Get-Service -Name $ServiceName).Status -ne 'Running' -and $waited -lt $timeout) {
            Start-Sleep -Seconds 1
            $waited++
        }
        
        if ((Get-Service -Name $ServiceName).Status -eq 'Running') {
            Write-Log "  [OK] Service started: $ServiceName" "SUCCESS"
            return $true
        } else {
            Write-Log "  [WARNING] Service did not start within timeout: $ServiceName" "WARNING"
            return $false
        }
    } catch {
        Write-Log "  [ERROR] Failed to start service: $_" "ERROR"
        return $false
    }
}

try {
    # Start logging
    Write-Log "========================================" "INFO"
    Write-Log "IsotoneStack Service Start Started" "INFO"
    Write-Log "Installation Directory: $isotonePath" "INFO"
    Write-Log "Parameters: Apache=$Apache, MariaDB=$MariaDB, Force=$Force" "INFO"
    Write-Log "========================================" "INFO"
    
    Write-Host ""
    Write-Log "=== Starting IsotoneStack Services ===" "MAGENTA"
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
    
    # Determine which services to start
    $startApache = $true
    $startMariaDB = $true
    
    if ($Apache -and !$MariaDB) {
        $startMariaDB = $false
        Write-Log "Starting Apache service only" "INFO"
    } elseif ($MariaDB -and !$Apache) {
        $startApache = $false
        Write-Log "Starting MariaDB service only" "INFO"
    } else {
        Write-Log "Starting all services" "INFO"
    }
    
    Write-Host ""
    
    # Track results
    $apacheStarted = $false
    $mariadbStarted = $false
    
    # =================================================================
    # Start MariaDB Service (start first as Apache/PHP may depend on it)
    # =================================================================
    if ($startMariaDB) {
        Write-Log "MariaDB Service:" "CYAN"
        $mariadbStarted = Start-ServiceSafe -ServiceName $mariadbServiceName -Force:$Force
        Write-Host ""
    }
    
    # =================================================================
    # Start Apache Service
    # =================================================================
    if ($startApache) {
        Write-Log "Apache Service:" "CYAN"
        $apacheStarted = Start-ServiceSafe -ServiceName $apacheServiceName -Force:$Force
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
    if ($startApache) {
        if (Test-ServiceExists $apacheServiceName) {
            $apacheService = Get-Service -Name $apacheServiceName
            $statusColor = if ($apacheService.Status -eq 'Running') { "SUCCESS" } else { "WARNING" }
            Write-Log "Apache:  $($apacheService.Status)" $statusColor
        } else {
            Write-Log "Apache:  Not Registered" "WARNING"
        }
    }
    
    if ($startMariaDB) {
        if (Test-ServiceExists $mariadbServiceName) {
            $mariadbService = Get-Service -Name $mariadbServiceName
            $statusColor = if ($mariadbService.Status -eq 'Running') { "SUCCESS" } else { "WARNING" }
            Write-Log "MariaDB: $($mariadbService.Status)" $statusColor
        } else {
            Write-Log "MariaDB: Not Registered" "WARNING"
        }
    }
    
    Write-Host ""
    
    # Provide access URLs if services are running
    $apacheRunning = (Test-ServiceExists $apacheServiceName) -and ((Get-Service -Name $apacheServiceName).Status -eq 'Running')
    $mariadbRunning = (Test-ServiceExists $mariadbServiceName) -and ((Get-Service -Name $mariadbServiceName).Status -eq 'Running')
    
    if ($apacheRunning) {
        Write-Log "Access URLs:" "INFO"
        Write-Log "  Web Server:  http://localhost" "DEBUG"
        Write-Log "  phpMyAdmin:  http://localhost/phpmyadmin" "DEBUG"
        Write-Host ""
    }
    
    if ($mariadbRunning) {
        Write-Log "Database Connection:" "INFO"
        Write-Log "  Host:     localhost" "DEBUG"
        Write-Log "  Port:     3306" "DEBUG"
        Write-Log "  User:     root" "DEBUG"
        Write-Log "  Password: (blank by default)" "DEBUG"
        Write-Host ""
    }
    
    # Overall success/failure
    $allSuccess = $true
    if ($startApache -and !$apacheStarted) { $allSuccess = $false }
    if ($startMariaDB -and !$mariadbStarted) { $allSuccess = $false }
    
    if ($allSuccess) {
        Write-Log "[SUCCESS] All requested services started successfully" "SUCCESS"
    } else {
        Write-Log "[WARNING] Some services failed to start" "WARNING"
        Write-Log "Check the log file for details: $logFile" "INFO"
    }
    
    Write-Host ""
    Write-Log "========================================" "INFO"
    Write-Log "Service start completed" "INFO"
    Write-Log "Log file: $logFile" "INFO"
    Write-Log "========================================" "INFO"
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service start failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}