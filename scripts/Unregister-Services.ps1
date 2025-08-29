# Unregister-Services.ps1
# Unregisters Apache and MariaDB Windows services for IsotoneStack
# Only removes service registrations - does not delete any files or data
# Requires Administrator privileges

param(
    [switch]$Force      # Force stop and removal even if services are running
,`n    [switch]$Verbose,`n    [switch]$Debug)

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
        Write-Warning "Failed to load settings file: # Unregister-Services.ps1
# Unregisters Apache and MariaDB Windows services for IsotoneStack
# Only removes service registrations - does not delete any files or data
# Requires Administrator privileges

param(
    [switch]$Force      # Force stop and removal even if services are running
,`n    [switch]$Verbose,`n    [switch]$Debug)

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to check if a service exists
function Test-ServiceExists {
    param([string]$ServiceName,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    return $null -ne $service
}

# Function to stop a service
function Stop-ServiceSafe {
    param([string]$ServiceName,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    if (Test-ServiceExists $ServiceName) {
        $service = Get-Service -Name $ServiceName
        
        if ($service.Status -eq 'Running') {
            Write-Log "  Stopping service: $ServiceName" "WARNING"
            try {
                Stop-Service -Name $ServiceName -Force -ErrorAction Stop
                
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
        } else {
            Write-Log "  Service already stopped: $ServiceName" "DEBUG"
            return $true
        }
    }
    return $true
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    Write-Log "Parameters: $($PSBoundParameters | Out-String)" "DEBUG"
    
    
    Write-Host ""
    Write-Log "=== IsotoneStack Service Unregistration ===" "MAGENTA"
    Write-Host ""
    
    # Check for Administrator privileges (redundant but ensures we're admin)
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "This script requires Administrator privileges" "ERROR"
        Write-Log "Please run this script as Administrator" "ERROR"
        exit 1
    }
    Write-Log "[OK] Running with Administrator privileges" "SUCCESS"
    Write-Host ""
    
    # Check what services exist
    Write-Log "Checking for existing services..." "CYAN"
    $apacheExists = Test-ServiceExists $apacheServiceName
    $mariadbExists = Test-ServiceExists $mariadbServiceName
    
    if (!$apacheExists -and !$mariadbExists) {
        Write-Log "No IsotoneStack services found to unregister" "WARNING"
        Write-Host ""
        exit 0
    }
    
    if ($apacheExists) {
        Write-Log "  [FOUND] $apacheServiceName service" "INFO"
    }
    if ($mariadbExists) {
        Write-Log "  [FOUND] $mariadbServiceName service" "INFO"
    }
    
    Write-Host ""
    
    # Confirm unregistration unless Force is specified
    if (!$Force) {
        Write-Log "This will unregister the following Windows services:" "WARNING"
        if ($apacheExists) {
            Write-Log "  - $apacheServiceName" "WARNING"
        }
        if ($mariadbExists) {
            Write-Log "  - $mariadbServiceName" "WARNING"
        }
        Write-Host ""
        Write-Log "NOTE: This only removes the Windows service registrations." "INFO"
        Write-Log "      No files or data will be deleted." "INFO"
        Write-Host ""
        Write-Log "Continue? (Y/N)" "YELLOW"
        
        $confirmation = Read-Host
        if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
            Write-Log "Unregistration cancelled by user" "WARNING"
            exit 0
        }
    }
    
    Write-Host ""
    
    # =================================================================
    # Unregister Apache Service
    # =================================================================
    if ($apacheExists) {
        Write-Log "============================================" "CYAN"
        Write-Log "    Unregistering Apache Service" "CYAN"
        Write-Log "============================================" "CYAN"
        Write-Host ""
        
        # Stop the service first
        $stopped = Stop-ServiceSafe $apacheServiceName
        
        if (!$stopped -and !$Force) {
            Write-Log "[ERROR] Cannot unregister service while it's running. Use -Force to override." "ERROR"
        } else {
            # Get Apache paths
            $apacheExe = Join-Path $isotonePath "apache24\bin\httpd.exe"
            
            # Try Apache's own uninstall method first
            if (Test-Path $apacheExe) {
                Write-Log "Uninstalling Apache service using httpd.exe..." "INFO"
                Push-Location (Join-Path $isotonePath "apache24\bin")
                
                try {
                    $result = & .\httpd.exe -k uninstall -n $apacheServiceName 2>&1 | Out-String
                    Write-Log "Apache uninstall output:" "DEBUG" -NoConsole
                    Write-Log $result "DEBUG"
                } catch {
                    Write-Log "Apache uninstall command failed: $_" "WARNING"
                } finally {
                    Pop-Location
                }
            }
            
            # Use sc.exe to ensure removal
            if (Test-ServiceExists $apacheServiceName) {
                Write-Log "Removing service using sc.exe..." "INFO"
                sc.exe delete $apacheServiceName | Out-Null
                Start-Sleep -Seconds 2
            }
            
            # Verify removal
            if (!(Test-ServiceExists $apacheServiceName)) {
                Write-Log "[OK] Apache service unregistered successfully" "SUCCESS"
            } else {
                Write-Log "[ERROR] Failed to unregister Apache service" "ERROR"
                Write-Log "Try running: sc delete $apacheServiceName" "WARNING"
            }
        }
        
        Write-Host ""
    }
    
    # =================================================================
    # Unregister MariaDB Service
    # =================================================================
    if ($mariadbExists) {
        Write-Log "============================================" "CYAN"
        Write-Log "    Unregistering MariaDB Service" "CYAN"
        Write-Log "============================================" "CYAN"
        Write-Host ""
        
        # Stop the service first
        $stopped = Stop-ServiceSafe $mariadbServiceName
        
        if (!$stopped -and !$Force) {
            Write-Log "[ERROR] Cannot unregister service while it's running. Use -Force to override." "ERROR"
        } else {
            # Find MariaDB executable
            $mariadbBin = Join-Path $isotonePath "mariadb\bin"
            $mariadbExe = $null
            
            if (Test-Path (Join-Path $mariadbBin "mariadbd.exe")) {
                $mariadbExe = Join-Path $mariadbBin "mariadbd.exe"
            } elseif (Test-Path (Join-Path $mariadbBin "mysqld.exe")) {
                $mariadbExe = Join-Path $mariadbBin "mysqld.exe"
            }
            
            # Try MariaDB's own removal method first
            if ($mariadbExe -and (Test-Path $mariadbExe)) {
                Write-Log "Uninstalling MariaDB service using MariaDB executable..." "INFO"
                try {
                    $result = & $mariadbExe --remove $mariadbServiceName 2>&1 | Out-String
                    Write-Log "MariaDB uninstall output:" "DEBUG" -NoConsole
                    Write-Log $result "DEBUG"
                } catch {
                    Write-Log "MariaDB uninstall command failed: $_" "WARNING"
                }
            }
            
            # Use sc.exe to ensure removal
            if (Test-ServiceExists $mariadbServiceName) {
                Write-Log "Removing service using sc.exe..." "INFO"
                sc.exe delete $mariadbServiceName | Out-Null
                Start-Sleep -Seconds 2
            }
            
            # Verify removal
            if (!(Test-ServiceExists $mariadbServiceName)) {
                Write-Log "[OK] MariaDB service unregistered successfully" "SUCCESS"
            } else {
                Write-Log "[ERROR] Failed to unregister MariaDB service" "ERROR"
                Write-Log "Try running: sc delete $mariadbServiceName" "WARNING"
            }
        }
        
        Write-Host ""
    }
    
    # =================================================================
    # Summary
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Unregistration Summary" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check final status
    $apacheStillExists = Test-ServiceExists $apacheServiceName
    $mariadbStillExists = Test-ServiceExists $mariadbServiceName
    
    if (!$apacheStillExists -and !$mariadbStillExists) {
        Write-Log "[SUCCESS] All IsotoneStack services have been unregistered" "SUCCESS"
        Write-Host ""
        Write-Log "NOTE: All files and data remain intact." "INFO"
        Write-Log "      Only the Windows service registrations were removed." "INFO"
    } else {
        Write-Log "[WARNING] Some services may still be registered:" "WARNING"
        if ($apacheStillExists) {
            Write-Log "  - $apacheServiceName still exists" "WARNING"
        }
        if ($mariadbStillExists) {
            Write-Log "  - $mariadbServiceName still exists" "WARNING"
        }
        Write-Host ""
        Write-Log "Manual cleanup commands:" "INFO"
        if ($apacheStillExists) {
            Write-Log "  sc delete $apacheServiceName" "DEBUG"
        }
        if ($mariadbStillExists) {
            Write-Log "  sc delete $mariadbServiceName" "DEBUG"
        }
    }
    
    Write-Host ""
    Write-Log "Next steps:" "INFO"
    Write-Log "  - Run Register-Services.ps1 to re-register services" "DEBUG"
    Write-Log "  - All configuration and data files remain unchanged" "DEBUG"
    
    Write-Host ""
    
    Write-Log "Service unregistration completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service unregistration failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}"
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
            Where-Object { # Unregister-Services.ps1
# Unregisters Apache and MariaDB Windows services for IsotoneStack
# Only removes service registrations - does not delete any files or data
# Requires Administrator privileges

param(
    [switch]$Force      # Force stop and removal even if services are running
,`n    [switch]$Verbose,`n    [switch]$Debug)

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to check if a service exists
function Test-ServiceExists {
    param([string]$ServiceName,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    return $null -ne $service
}

# Function to stop a service
function Stop-ServiceSafe {
    param([string]$ServiceName,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    if (Test-ServiceExists $ServiceName) {
        $service = Get-Service -Name $ServiceName
        
        if ($service.Status -eq 'Running') {
            Write-Log "  Stopping service: $ServiceName" "WARNING"
            try {
                Stop-Service -Name $ServiceName -Force -ErrorAction Stop
                
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
        } else {
            Write-Log "  Service already stopped: $ServiceName" "DEBUG"
            return $true
        }
    }
    return $true
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    Write-Log "Parameters: $($PSBoundParameters | Out-String)" "DEBUG"
    
    
    Write-Host ""
    Write-Log "=== IsotoneStack Service Unregistration ===" "MAGENTA"
    Write-Host ""
    
    # Check for Administrator privileges (redundant but ensures we're admin)
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "This script requires Administrator privileges" "ERROR"
        Write-Log "Please run this script as Administrator" "ERROR"
        exit 1
    }
    Write-Log "[OK] Running with Administrator privileges" "SUCCESS"
    Write-Host ""
    
    # Check what services exist
    Write-Log "Checking for existing services..." "CYAN"
    $apacheExists = Test-ServiceExists $apacheServiceName
    $mariadbExists = Test-ServiceExists $mariadbServiceName
    
    if (!$apacheExists -and !$mariadbExists) {
        Write-Log "No IsotoneStack services found to unregister" "WARNING"
        Write-Host ""
        exit 0
    }
    
    if ($apacheExists) {
        Write-Log "  [FOUND] $apacheServiceName service" "INFO"
    }
    if ($mariadbExists) {
        Write-Log "  [FOUND] $mariadbServiceName service" "INFO"
    }
    
    Write-Host ""
    
    # Confirm unregistration unless Force is specified
    if (!$Force) {
        Write-Log "This will unregister the following Windows services:" "WARNING"
        if ($apacheExists) {
            Write-Log "  - $apacheServiceName" "WARNING"
        }
        if ($mariadbExists) {
            Write-Log "  - $mariadbServiceName" "WARNING"
        }
        Write-Host ""
        Write-Log "NOTE: This only removes the Windows service registrations." "INFO"
        Write-Log "      No files or data will be deleted." "INFO"
        Write-Host ""
        Write-Log "Continue? (Y/N)" "YELLOW"
        
        $confirmation = Read-Host
        if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
            Write-Log "Unregistration cancelled by user" "WARNING"
            exit 0
        }
    }
    
    Write-Host ""
    
    # =================================================================
    # Unregister Apache Service
    # =================================================================
    if ($apacheExists) {
        Write-Log "============================================" "CYAN"
        Write-Log "    Unregistering Apache Service" "CYAN"
        Write-Log "============================================" "CYAN"
        Write-Host ""
        
        # Stop the service first
        $stopped = Stop-ServiceSafe $apacheServiceName
        
        if (!$stopped -and !$Force) {
            Write-Log "[ERROR] Cannot unregister service while it's running. Use -Force to override." "ERROR"
        } else {
            # Get Apache paths
            $apacheExe = Join-Path $isotonePath "apache24\bin\httpd.exe"
            
            # Try Apache's own uninstall method first
            if (Test-Path $apacheExe) {
                Write-Log "Uninstalling Apache service using httpd.exe..." "INFO"
                Push-Location (Join-Path $isotonePath "apache24\bin")
                
                try {
                    $result = & .\httpd.exe -k uninstall -n $apacheServiceName 2>&1 | Out-String
                    Write-Log "Apache uninstall output:" "DEBUG" -NoConsole
                    Write-Log $result "DEBUG"
                } catch {
                    Write-Log "Apache uninstall command failed: $_" "WARNING"
                } finally {
                    Pop-Location
                }
            }
            
            # Use sc.exe to ensure removal
            if (Test-ServiceExists $apacheServiceName) {
                Write-Log "Removing service using sc.exe..." "INFO"
                sc.exe delete $apacheServiceName | Out-Null
                Start-Sleep -Seconds 2
            }
            
            # Verify removal
            if (!(Test-ServiceExists $apacheServiceName)) {
                Write-Log "[OK] Apache service unregistered successfully" "SUCCESS"
            } else {
                Write-Log "[ERROR] Failed to unregister Apache service" "ERROR"
                Write-Log "Try running: sc delete $apacheServiceName" "WARNING"
            }
        }
        
        Write-Host ""
    }
    
    # =================================================================
    # Unregister MariaDB Service
    # =================================================================
    if ($mariadbExists) {
        Write-Log "============================================" "CYAN"
        Write-Log "    Unregistering MariaDB Service" "CYAN"
        Write-Log "============================================" "CYAN"
        Write-Host ""
        
        # Stop the service first
        $stopped = Stop-ServiceSafe $mariadbServiceName
        
        if (!$stopped -and !$Force) {
            Write-Log "[ERROR] Cannot unregister service while it's running. Use -Force to override." "ERROR"
        } else {
            # Find MariaDB executable
            $mariadbBin = Join-Path $isotonePath "mariadb\bin"
            $mariadbExe = $null
            
            if (Test-Path (Join-Path $mariadbBin "mariadbd.exe")) {
                $mariadbExe = Join-Path $mariadbBin "mariadbd.exe"
            } elseif (Test-Path (Join-Path $mariadbBin "mysqld.exe")) {
                $mariadbExe = Join-Path $mariadbBin "mysqld.exe"
            }
            
            # Try MariaDB's own removal method first
            if ($mariadbExe -and (Test-Path $mariadbExe)) {
                Write-Log "Uninstalling MariaDB service using MariaDB executable..." "INFO"
                try {
                    $result = & $mariadbExe --remove $mariadbServiceName 2>&1 | Out-String
                    Write-Log "MariaDB uninstall output:" "DEBUG" -NoConsole
                    Write-Log $result "DEBUG"
                } catch {
                    Write-Log "MariaDB uninstall command failed: $_" "WARNING"
                }
            }
            
            # Use sc.exe to ensure removal
            if (Test-ServiceExists $mariadbServiceName) {
                Write-Log "Removing service using sc.exe..." "INFO"
                sc.exe delete $mariadbServiceName | Out-Null
                Start-Sleep -Seconds 2
            }
            
            # Verify removal
            if (!(Test-ServiceExists $mariadbServiceName)) {
                Write-Log "[OK] MariaDB service unregistered successfully" "SUCCESS"
            } else {
                Write-Log "[ERROR] Failed to unregister MariaDB service" "ERROR"
                Write-Log "Try running: sc delete $mariadbServiceName" "WARNING"
            }
        }
        
        Write-Host ""
    }
    
    # =================================================================
    # Summary
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Unregistration Summary" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check final status
    $apacheStillExists = Test-ServiceExists $apacheServiceName
    $mariadbStillExists = Test-ServiceExists $mariadbServiceName
    
    if (!$apacheStillExists -and !$mariadbStillExists) {
        Write-Log "[SUCCESS] All IsotoneStack services have been unregistered" "SUCCESS"
        Write-Host ""
        Write-Log "NOTE: All files and data remain intact." "INFO"
        Write-Log "      Only the Windows service registrations were removed." "INFO"
    } else {
        Write-Log "[WARNING] Some services may still be registered:" "WARNING"
        if ($apacheStillExists) {
            Write-Log "  - $apacheServiceName still exists" "WARNING"
        }
        if ($mariadbStillExists) {
            Write-Log "  - $mariadbServiceName still exists" "WARNING"
        }
        Write-Host ""
        Write-Log "Manual cleanup commands:" "INFO"
        if ($apacheStillExists) {
            Write-Log "  sc delete $apacheServiceName" "DEBUG"
        }
        if ($mariadbStillExists) {
            Write-Log "  sc delete $mariadbServiceName" "DEBUG"
        }
    }
    
    Write-Host ""
    Write-Log "Next steps:" "INFO"
    Write-Log "  - Run Register-Services.ps1 to re-register services" "DEBUG"
    Write-Log "  - All configuration and data files remain unchanged" "DEBUG"
    
    Write-Host ""
    
    Write-Log "Service unregistration completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service unregistration failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

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
    param([string]$ServiceName,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    return $null -ne $service
}

# Function to stop a service
function Stop-ServiceSafe {
    param([string]$ServiceName,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    if (Test-ServiceExists $ServiceName) {
        $service = Get-Service -Name $ServiceName
        
        if ($service.Status -eq 'Running') {
            Write-Log "  Stopping service: $ServiceName" "WARNING"
            try {
                Stop-Service -Name $ServiceName -Force -ErrorAction Stop
                
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
        } else {
            Write-Log "  Service already stopped: $ServiceName" "DEBUG"
            return $true
        }
    }
    return $true
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    Write-Log "Parameters: $($PSBoundParameters | Out-String)" "DEBUG"
    
    
    Write-Host ""
    Write-Log "=== IsotoneStack Service Unregistration ===" "MAGENTA"
    Write-Host ""
    
    # Check for Administrator privileges (redundant but ensures we're admin)
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "This script requires Administrator privileges" "ERROR"
        Write-Log "Please run this script as Administrator" "ERROR"
        exit 1
    }
    Write-Log "[OK] Running with Administrator privileges" "SUCCESS"
    Write-Host ""
    
    # Check what services exist
    Write-Log "Checking for existing services..." "CYAN"
    $apacheExists = Test-ServiceExists $apacheServiceName
    $mariadbExists = Test-ServiceExists $mariadbServiceName
    
    if (!$apacheExists -and !$mariadbExists) {
        Write-Log "No IsotoneStack services found to unregister" "WARNING"
        Write-Host ""
        exit 0
    }
    
    if ($apacheExists) {
        Write-Log "  [FOUND] $apacheServiceName service" "INFO"
    }
    if ($mariadbExists) {
        Write-Log "  [FOUND] $mariadbServiceName service" "INFO"
    }
    
    Write-Host ""
    
    # Confirm unregistration unless Force is specified
    if (!$Force) {
        Write-Log "This will unregister the following Windows services:" "WARNING"
        if ($apacheExists) {
            Write-Log "  - $apacheServiceName" "WARNING"
        }
        if ($mariadbExists) {
            Write-Log "  - $mariadbServiceName" "WARNING"
        }
        Write-Host ""
        Write-Log "NOTE: This only removes the Windows service registrations." "INFO"
        Write-Log "      No files or data will be deleted." "INFO"
        Write-Host ""
        Write-Log "Continue? (Y/N)" "YELLOW"
        
        $confirmation = Read-Host
        if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
            Write-Log "Unregistration cancelled by user" "WARNING"
            exit 0
        }
    }
    
    Write-Host ""
    
    # =================================================================
    # Unregister Apache Service
    # =================================================================
    if ($apacheExists) {
        Write-Log "============================================" "CYAN"
        Write-Log "    Unregistering Apache Service" "CYAN"
        Write-Log "============================================" "CYAN"
        Write-Host ""
        
        # Stop the service first
        $stopped = Stop-ServiceSafe $apacheServiceName
        
        if (!$stopped -and !$Force) {
            Write-Log "[ERROR] Cannot unregister service while it's running. Use -Force to override." "ERROR"
        } else {
            # Get Apache paths
            $apacheExe = Join-Path $isotonePath "apache24\bin\httpd.exe"
            
            # Try Apache's own uninstall method first
            if (Test-Path $apacheExe) {
                Write-Log "Uninstalling Apache service using httpd.exe..." "INFO"
                Push-Location (Join-Path $isotonePath "apache24\bin")
                
                try {
                    $result = & .\httpd.exe -k uninstall -n $apacheServiceName 2>&1 | Out-String
                    Write-Log "Apache uninstall output:" "DEBUG" -NoConsole
                    Write-Log $result "DEBUG"
                } catch {
                    Write-Log "Apache uninstall command failed: $_" "WARNING"
                } finally {
                    Pop-Location
                }
            }
            
            # Use sc.exe to ensure removal
            if (Test-ServiceExists $apacheServiceName) {
                Write-Log "Removing service using sc.exe..." "INFO"
                sc.exe delete $apacheServiceName | Out-Null
                Start-Sleep -Seconds 2
            }
            
            # Verify removal
            if (!(Test-ServiceExists $apacheServiceName)) {
                Write-Log "[OK] Apache service unregistered successfully" "SUCCESS"
            } else {
                Write-Log "[ERROR] Failed to unregister Apache service" "ERROR"
                Write-Log "Try running: sc delete $apacheServiceName" "WARNING"
            }
        }
        
        Write-Host ""
    }
    
    # =================================================================
    # Unregister MariaDB Service
    # =================================================================
    if ($mariadbExists) {
        Write-Log "============================================" "CYAN"
        Write-Log "    Unregistering MariaDB Service" "CYAN"
        Write-Log "============================================" "CYAN"
        Write-Host ""
        
        # Stop the service first
        $stopped = Stop-ServiceSafe $mariadbServiceName
        
        if (!$stopped -and !$Force) {
            Write-Log "[ERROR] Cannot unregister service while it's running. Use -Force to override." "ERROR"
        } else {
            # Find MariaDB executable
            $mariadbBin = Join-Path $isotonePath "mariadb\bin"
            $mariadbExe = $null
            
            if (Test-Path (Join-Path $mariadbBin "mariadbd.exe")) {
                $mariadbExe = Join-Path $mariadbBin "mariadbd.exe"
            } elseif (Test-Path (Join-Path $mariadbBin "mysqld.exe")) {
                $mariadbExe = Join-Path $mariadbBin "mysqld.exe"
            }
            
            # Try MariaDB's own removal method first
            if ($mariadbExe -and (Test-Path $mariadbExe)) {
                Write-Log "Uninstalling MariaDB service using MariaDB executable..." "INFO"
                try {
                    $result = & $mariadbExe --remove $mariadbServiceName 2>&1 | Out-String
                    Write-Log "MariaDB uninstall output:" "DEBUG" -NoConsole
                    Write-Log $result "DEBUG"
                } catch {
                    Write-Log "MariaDB uninstall command failed: $_" "WARNING"
                }
            }
            
            # Use sc.exe to ensure removal
            if (Test-ServiceExists $mariadbServiceName) {
                Write-Log "Removing service using sc.exe..." "INFO"
                sc.exe delete $mariadbServiceName | Out-Null
                Start-Sleep -Seconds 2
            }
            
            # Verify removal
            if (!(Test-ServiceExists $mariadbServiceName)) {
                Write-Log "[OK] MariaDB service unregistered successfully" "SUCCESS"
            } else {
                Write-Log "[ERROR] Failed to unregister MariaDB service" "ERROR"
                Write-Log "Try running: sc delete $mariadbServiceName" "WARNING"
            }
        }
        
        Write-Host ""
    }
    
    # =================================================================
    # Summary
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Unregistration Summary" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check final status
    $apacheStillExists = Test-ServiceExists $apacheServiceName
    $mariadbStillExists = Test-ServiceExists $mariadbServiceName
    
    if (!$apacheStillExists -and !$mariadbStillExists) {
        Write-Log "[SUCCESS] All IsotoneStack services have been unregistered" "SUCCESS"
        Write-Host ""
        Write-Log "NOTE: All files and data remain intact." "INFO"
        Write-Log "      Only the Windows service registrations were removed." "INFO"
    } else {
        Write-Log "[WARNING] Some services may still be registered:" "WARNING"
        if ($apacheStillExists) {
            Write-Log "  - $apacheServiceName still exists" "WARNING"
        }
        if ($mariadbStillExists) {
            Write-Log "  - $mariadbServiceName still exists" "WARNING"
        }
        Write-Host ""
        Write-Log "Manual cleanup commands:" "INFO"
        if ($apacheStillExists) {
            Write-Log "  sc delete $apacheServiceName" "DEBUG"
        }
        if ($mariadbStillExists) {
            Write-Log "  sc delete $mariadbServiceName" "DEBUG"
        }
    }
    
    Write-Host ""
    Write-Log "Next steps:" "INFO"
    Write-Log "  - Run Register-Services.ps1 to re-register services" "DEBUG"
    Write-Log "  - All configuration and data files remain unchanged" "DEBUG"
    
    Write-Host ""
    
    Write-Log "Service unregistration completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service unregistration failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
