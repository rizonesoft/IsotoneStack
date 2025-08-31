# Stop-Services.ps1
# Stops Apache, MariaDB and Mailpit Windows services for IsotoneStack
# Requires Administrator privileges

param(
    [switch]$Apache,     # Stop only Apache service
    [switch]$MariaDB,    # Stop only MariaDB service
    [switch]$Mailpit,    # Stop only Mailpit service
    [switch]$Force,      # Force stop even if dependencies exist
    [switch]$Verbose,    # Enable verbose output
    [switch]$Debug       # Enable debug output
)

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: $_"
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Service names
$apacheServiceName = "IsotoneApache"
$mariadbServiceName = "IsotoneMariaDB"
$mailpitServiceName = "IsotoneMailpit"

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
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
    # Start logging (only log start/end and important events)
    Write-Log "IsotoneStack Service Stop Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    if ($Verbose) {
        Write-Log "Parameters: Apache=$Apache, MariaDB=$MariaDB, Force=$Force, Verbose=$Verbose" "DEBUG"
    }
    
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
    $stopMailpit = $true
    
    # Check if specific services were requested
    if ($Apache -or $MariaDB -or $Mailpit) {
        # Stop only specified services
        $stopApache = $Apache
        $stopMariaDB = $MariaDB
        $stopMailpit = $Mailpit
        
        if ($Apache -and !$MariaDB -and !$Mailpit) {
            Write-Log "Stopping Apache service only" "INFO"
        } elseif ($MariaDB -and !$Apache -and !$Mailpit) {
            Write-Log "Stopping MariaDB service only" "INFO"
        } elseif ($Mailpit -and !$Apache -and !$MariaDB) {
            Write-Log "Stopping Mailpit service only" "INFO"
        } else {
            Write-Log "Stopping selected services" "INFO"
        }
    } else {
        Write-Log "Stopping all available services" "INFO"
    }
    
    Write-Host ""
    
    # Track results
    $apacheStopped = $false
    $mariadbStopped = $false
    $mailpitStopped = $false
    
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
    # Stop Mailpit Service (Optional)
    # =================================================================
    if ($stopMailpit) {
        # Check if Mailpit service exists before trying to stop
        if (Test-ServiceExists $mailpitServiceName) {
            Write-Log "Mailpit Service:" "CYAN"
            $mailpitStopped = Stop-ServiceSafe -ServiceName $mailpitServiceName -Force:$Force
            Write-Host ""
        } else {
            if ($Mailpit) {
                # User specifically requested Mailpit but it's not installed
                Write-Log "[WARNING] Mailpit service not found" "WARNING"
                Write-Host ""
            }
            # If not specifically requested, silently skip
        }
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
    
    if ($stopMailpit) {
        if (Test-ServiceExists $mailpitServiceName) {
            $mailpitService = Get-Service -Name $mailpitServiceName
            $statusColor = if ($mailpitService.Status -eq 'Stopped') { "SUCCESS" } else { "WARNING" }
            Write-Log "Mailpit: $($mailpitService.Status)" $statusColor
        } else {
            # Only show if user specifically requested Mailpit
            if ($Mailpit) {
                Write-Log "Mailpit: Not Registered" "WARNING"
            }
        }
    }
    
    Write-Host ""
    
    # Overall success/failure
    $allSuccess = $true
    if ($stopApache -and !$apacheStopped) { $allSuccess = $false }
    if ($stopMariaDB -and !$mariadbStopped) { $allSuccess = $false }
    if ($stopMailpit -and $Mailpit -and !$mailpitStopped) { $allSuccess = $false }
    
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
    Write-Log "Service stop completed successfully" "SUCCESS" -AlwaysLog
    if ($Verbose) {
        Write-Log "Log file: $logFile" "DEBUG"
    }
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service stop failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}