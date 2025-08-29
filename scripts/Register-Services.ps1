# Register-Services.ps1
# Registers Apache and MariaDB as Windows services for IsotoneStack
# Requires Administrator privileges

param(
    [switch]$Force,      # Force reinstall even if services exist
    [switch]$StartAfter  # Start services after registration
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
        Write-Warning "Failed to load settings file: # Register-Services.ps1
# Registers Apache and MariaDB as Windows services for IsotoneStack
# Requires Administrator privileges

param(
    [switch]$Force,      # Force reinstall even if services exist
    [switch]$StartAfter  # Start services after registration
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

# Function to remove a service
function Remove-Service {
    param([string]$ServiceName,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    if (Test-ServiceExists $ServiceName) {
        Write-Log "  Stopping service: $ServiceName" "DEBUG"
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        
        Write-Log "  Removing service: $ServiceName" "DEBUG"
        sc.exe delete $ServiceName | Out-Null
        Start-Sleep -Seconds 2  # Give Windows time to remove the service
        
        if (!(Test-ServiceExists $ServiceName)) {
            Write-Log "  [OK] Service removed: $ServiceName" "SUCCESS"
            return $true
        } else {
            Write-Log "  [WARNING] Service may not be fully removed: $ServiceName" "WARNING"
            return $false
        }
    }
    return $true
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    Write-Log "Parameters: $($PSBoundParameters | Out-String)" "DEBUG"
    
    
    Write-Host ""
    Write-Log "=== IsotoneStack Service Registration ===" "MAGENTA"
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
    
    # Check if components exist
    Write-Log "Checking components..." "CYAN"
    
    # Check Apache
    $apacheExe = Join-Path $isotonePath "apache24\bin\httpd.exe"
    $apacheConf = Join-Path $isotonePath "apache24\conf\httpd.conf"
    if (!(Test-Path $apacheExe)) {
        Write-Log "  [ERROR] Apache not found at: $apacheExe" "ERROR"
        exit 1
    }
    Write-Log "  [OK] Apache found" "SUCCESS"
    
    # Check MariaDB (support both mariadbd.exe and mysqld.exe)
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mariadbExe = $null
    $mariadbExeName = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadbd.exe")) {
        $mariadbExe = Join-Path $mariadbBin "mariadbd.exe"
        $mariadbExeName = "mariadbd.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysqld.exe")) {
        $mariadbExe = Join-Path $mariadbBin "mysqld.exe"
        $mariadbExeName = "mysqld.exe"
    } else {
        Write-Log "  [ERROR] MariaDB not found in: $mariadbBin" "ERROR"
        Write-Log "  Looking for mariadbd.exe or mysqld.exe" "ERROR"
        exit 1
    }
    Write-Log "  [OK] MariaDB found ($mariadbExeName)" "SUCCESS"
    
    # Check MariaDB configuration
    $mariadbConfig = Join-Path $isotonePath "mariadb\my.ini"
    if (!(Test-Path $mariadbConfig)) {
        Write-Log "  [WARNING] MariaDB configuration not found" "WARNING"
        Write-Log "  Run Configure-IsotoneStack.ps1 first to create configuration" "WARNING"
    }
    
    Write-Host ""
    
    # =================================================================
    # Register Apache Service
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Registering Apache Service" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check if Apache service exists
    if (Test-ServiceExists $apacheServiceName) {
        if ($Force) {
            Write-Log "Removing existing Apache service (Force mode)..." "WARNING"
            Remove-Service $apacheServiceName
        } else {
            Write-Log "Apache service already exists. Use -Force to reinstall." "WARNING"
            $skipApache = $true
        }
    }
    
    if (!$skipApache) {
        Write-Log "Installing Apache service..." "INFO"
        
        # Change to Apache bin directory for installation
        Push-Location (Join-Path $isotonePath "apache24\bin")
        
        try {
            # Install Apache service
            $installArgs = @("-k", "install", "-n", $apacheServiceName, "-f", $apacheConf)
            $result = & .\httpd.exe $installArgs 2>&1 | Out-String
            
            Write-Log "Apache installation output:" "DEBUG" -NoConsole
            Write-Log $result "DEBUG"
            
            if (Test-ServiceExists $apacheServiceName) {
                Write-Log "[OK] Apache service installed successfully" "SUCCESS"
                
                # Set service to manual start
                sc.exe config $apacheServiceName start= demand | Out-Null
                Write-Log "[OK] Apache service set to manual start" "SUCCESS"
                
                # Set service description
                sc.exe description $apacheServiceName "IsotoneStack Apache HTTP Server" | Out-Null
            } else {
                Write-Log "[ERROR] Failed to install Apache service" "ERROR"
                Write-Log "Installation output: $result" "ERROR"
            }
        } catch {
            Write-Log "[ERROR] Exception installing Apache: $_" "ERROR"
        } finally {
            Pop-Location
        }
    }
    
    Write-Host ""
    
    # =================================================================
    # Register MariaDB Service
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Registering MariaDB Service" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check if MariaDB service exists
    if (Test-ServiceExists $mariadbServiceName) {
        if ($Force) {
            Write-Log "Removing existing MariaDB service (Force mode)..." "WARNING"
            
            # Try MariaDB's own removal method first
            & $mariadbExe --remove $mariadbServiceName 2>&1 | Out-Null
            Start-Sleep -Seconds 2
            
            # Then use sc.exe as backup
            Remove-Service $mariadbServiceName
        } else {
            Write-Log "MariaDB service already exists. Use -Force to reinstall." "WARNING"
            $skipMariaDB = $true
        }
    }
    
    if (!$skipMariaDB) {
        Write-Log "Installing MariaDB service..." "INFO"
        
        # Ensure data directory exists
        $dataDir = Join-Path $isotonePath "mariadb\data"
        if (!(Test-Path $dataDir)) {
            New-Item -Path $dataDir -ItemType Directory -Force | Out-Null
            Write-Log "  Created data directory: $dataDir" "DEBUG"
        }
        
        # Check if data directory is initialized
        $mysqlDir = Join-Path $dataDir "mysql"
        if (!(Test-Path $mysqlDir)) {
            Write-Log "  MariaDB data directory not initialized" "WARNING"
            Write-Log "  Run Configure-IsotoneStack.ps1 to initialize database" "WARNING"
        }
        
        try {
            # Install MariaDB service
            if (Test-Path $mariadbConfig) {
                $installArgs = @("--install", $mariadbServiceName, "--defaults-file=`"$mariadbConfig`"")
            } else {
                # Basic installation without config file
                $installArgs = @("--install", $mariadbServiceName)
            }
            
            $result = & $mariadbExe $installArgs 2>&1 | Out-String
            
            Write-Log "MariaDB installation output:" "DEBUG" -NoConsole
            Write-Log $result "DEBUG"
            
            # Give Windows time to register the service
            Start-Sleep -Seconds 3
            
            if (Test-ServiceExists $mariadbServiceName) {
                Write-Log "[OK] MariaDB service installed successfully" "SUCCESS"
                
                # Set service to manual start
                sc.exe config $mariadbServiceName start= demand | Out-Null
                Write-Log "[OK] MariaDB service set to manual start" "SUCCESS"
                
                # Set service description
                sc.exe description $mariadbServiceName "IsotoneStack MariaDB Database Server" | Out-Null
            } else {
                Write-Log "[WARNING] MariaDB service installation had issues" "WARNING"
                Write-Log "Installation output: $result" "WARNING"
                Write-Log "You may need to initialize the database first" "WARNING"
            }
        } catch {
            Write-Log "[ERROR] Exception installing MariaDB: $_" "ERROR"
        }
    }
    
    Write-Host ""
    
    # =================================================================
    # Service Registration Summary
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Service Registration Summary" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check Apache service status
    if (Test-ServiceExists $apacheServiceName) {
        $apacheService = Get-Service -Name $apacheServiceName
        Write-Log "[OK] $apacheServiceName is registered (Status: $($apacheService.Status))" "SUCCESS"
        $apacheRegistered = $true
    } else {
        Write-Log "[FAILED] $apacheServiceName is NOT registered" "ERROR"
        $apacheRegistered = $false
    }
    
    # Check MariaDB service status
    if (Test-ServiceExists $mariadbServiceName) {
        $mariadbService = Get-Service -Name $mariadbServiceName
        Write-Log "[OK] $mariadbServiceName is registered (Status: $($mariadbService.Status))" "SUCCESS"
        $mariadbRegistered = $true
    } else {
        Write-Log "[FAILED] $mariadbServiceName is NOT registered" "ERROR"
        $mariadbRegistered = $false
    }
    
    # Start services if requested
    if ($StartAfter -and ($apacheRegistered -or $mariadbRegistered)) {
        Write-Host ""
        Write-Log "Starting services..." "CYAN"
        
        if ($apacheRegistered) {
            try {
                Start-Service -Name $apacheServiceName -ErrorAction Stop
                Write-Log "  [OK] Apache service started" "SUCCESS"
            } catch {
                Write-Log "  [WARNING] Could not start Apache: $_" "WARNING"
            }
        }
        
        if ($mariadbRegistered) {
            try {
                Start-Service -Name $mariadbServiceName -ErrorAction Stop
                Write-Log "  [OK] MariaDB service started" "SUCCESS"
            } catch {
                Write-Log "  [WARNING] Could not start MariaDB: $_" "WARNING"
            }
        }
    }
    
    Write-Host ""
    Write-Log "============================================" "CYAN"
    Write-Log "    Next Steps" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    if ($apacheRegistered -or $mariadbRegistered) {
        Write-Log "To start services:" "INFO"
        Write-Log "  Start-Services.ps1" "DEBUG"
        Write-Host ""
        Write-Log "To stop services:" "INFO"
        Write-Log "  Stop-Services.ps1" "DEBUG"
    }
    
    # Additional service management commands
    Write-Host ""
    Write-Log "Service Management Commands:" "INFO"
    Write-Log "  View services:   Get-Service Isotone*" "DEBUG"
    Write-Log "  Start services:  Start-Service Isotone*" "DEBUG"
    Write-Log "  Stop services:   Stop-Service Isotone*" "DEBUG"
    Write-Log "  Service status:  sc query IsotoneApache" "DEBUG"
    
    Write-Host ""
    
    Write-Log "Service registration completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service registration failed with fatal error" "ERROR"
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
            Where-Object { # Register-Services.ps1
# Registers Apache and MariaDB as Windows services for IsotoneStack
# Requires Administrator privileges

param(
    [switch]$Force,      # Force reinstall even if services exist
    [switch]$StartAfter  # Start services after registration
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

# Function to remove a service
function Remove-Service {
    param([string]$ServiceName,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    if (Test-ServiceExists $ServiceName) {
        Write-Log "  Stopping service: $ServiceName" "DEBUG"
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        
        Write-Log "  Removing service: $ServiceName" "DEBUG"
        sc.exe delete $ServiceName | Out-Null
        Start-Sleep -Seconds 2  # Give Windows time to remove the service
        
        if (!(Test-ServiceExists $ServiceName)) {
            Write-Log "  [OK] Service removed: $ServiceName" "SUCCESS"
            return $true
        } else {
            Write-Log "  [WARNING] Service may not be fully removed: $ServiceName" "WARNING"
            return $false
        }
    }
    return $true
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    Write-Log "Parameters: $($PSBoundParameters | Out-String)" "DEBUG"
    
    
    Write-Host ""
    Write-Log "=== IsotoneStack Service Registration ===" "MAGENTA"
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
    
    # Check if components exist
    Write-Log "Checking components..." "CYAN"
    
    # Check Apache
    $apacheExe = Join-Path $isotonePath "apache24\bin\httpd.exe"
    $apacheConf = Join-Path $isotonePath "apache24\conf\httpd.conf"
    if (!(Test-Path $apacheExe)) {
        Write-Log "  [ERROR] Apache not found at: $apacheExe" "ERROR"
        exit 1
    }
    Write-Log "  [OK] Apache found" "SUCCESS"
    
    # Check MariaDB (support both mariadbd.exe and mysqld.exe)
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mariadbExe = $null
    $mariadbExeName = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadbd.exe")) {
        $mariadbExe = Join-Path $mariadbBin "mariadbd.exe"
        $mariadbExeName = "mariadbd.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysqld.exe")) {
        $mariadbExe = Join-Path $mariadbBin "mysqld.exe"
        $mariadbExeName = "mysqld.exe"
    } else {
        Write-Log "  [ERROR] MariaDB not found in: $mariadbBin" "ERROR"
        Write-Log "  Looking for mariadbd.exe or mysqld.exe" "ERROR"
        exit 1
    }
    Write-Log "  [OK] MariaDB found ($mariadbExeName)" "SUCCESS"
    
    # Check MariaDB configuration
    $mariadbConfig = Join-Path $isotonePath "mariadb\my.ini"
    if (!(Test-Path $mariadbConfig)) {
        Write-Log "  [WARNING] MariaDB configuration not found" "WARNING"
        Write-Log "  Run Configure-IsotoneStack.ps1 first to create configuration" "WARNING"
    }
    
    Write-Host ""
    
    # =================================================================
    # Register Apache Service
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Registering Apache Service" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check if Apache service exists
    if (Test-ServiceExists $apacheServiceName) {
        if ($Force) {
            Write-Log "Removing existing Apache service (Force mode)..." "WARNING"
            Remove-Service $apacheServiceName
        } else {
            Write-Log "Apache service already exists. Use -Force to reinstall." "WARNING"
            $skipApache = $true
        }
    }
    
    if (!$skipApache) {
        Write-Log "Installing Apache service..." "INFO"
        
        # Change to Apache bin directory for installation
        Push-Location (Join-Path $isotonePath "apache24\bin")
        
        try {
            # Install Apache service
            $installArgs = @("-k", "install", "-n", $apacheServiceName, "-f", $apacheConf)
            $result = & .\httpd.exe $installArgs 2>&1 | Out-String
            
            Write-Log "Apache installation output:" "DEBUG" -NoConsole
            Write-Log $result "DEBUG"
            
            if (Test-ServiceExists $apacheServiceName) {
                Write-Log "[OK] Apache service installed successfully" "SUCCESS"
                
                # Set service to manual start
                sc.exe config $apacheServiceName start= demand | Out-Null
                Write-Log "[OK] Apache service set to manual start" "SUCCESS"
                
                # Set service description
                sc.exe description $apacheServiceName "IsotoneStack Apache HTTP Server" | Out-Null
            } else {
                Write-Log "[ERROR] Failed to install Apache service" "ERROR"
                Write-Log "Installation output: $result" "ERROR"
            }
        } catch {
            Write-Log "[ERROR] Exception installing Apache: $_" "ERROR"
        } finally {
            Pop-Location
        }
    }
    
    Write-Host ""
    
    # =================================================================
    # Register MariaDB Service
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Registering MariaDB Service" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check if MariaDB service exists
    if (Test-ServiceExists $mariadbServiceName) {
        if ($Force) {
            Write-Log "Removing existing MariaDB service (Force mode)..." "WARNING"
            
            # Try MariaDB's own removal method first
            & $mariadbExe --remove $mariadbServiceName 2>&1 | Out-Null
            Start-Sleep -Seconds 2
            
            # Then use sc.exe as backup
            Remove-Service $mariadbServiceName
        } else {
            Write-Log "MariaDB service already exists. Use -Force to reinstall." "WARNING"
            $skipMariaDB = $true
        }
    }
    
    if (!$skipMariaDB) {
        Write-Log "Installing MariaDB service..." "INFO"
        
        # Ensure data directory exists
        $dataDir = Join-Path $isotonePath "mariadb\data"
        if (!(Test-Path $dataDir)) {
            New-Item -Path $dataDir -ItemType Directory -Force | Out-Null
            Write-Log "  Created data directory: $dataDir" "DEBUG"
        }
        
        # Check if data directory is initialized
        $mysqlDir = Join-Path $dataDir "mysql"
        if (!(Test-Path $mysqlDir)) {
            Write-Log "  MariaDB data directory not initialized" "WARNING"
            Write-Log "  Run Configure-IsotoneStack.ps1 to initialize database" "WARNING"
        }
        
        try {
            # Install MariaDB service
            if (Test-Path $mariadbConfig) {
                $installArgs = @("--install", $mariadbServiceName, "--defaults-file=`"$mariadbConfig`"")
            } else {
                # Basic installation without config file
                $installArgs = @("--install", $mariadbServiceName)
            }
            
            $result = & $mariadbExe $installArgs 2>&1 | Out-String
            
            Write-Log "MariaDB installation output:" "DEBUG" -NoConsole
            Write-Log $result "DEBUG"
            
            # Give Windows time to register the service
            Start-Sleep -Seconds 3
            
            if (Test-ServiceExists $mariadbServiceName) {
                Write-Log "[OK] MariaDB service installed successfully" "SUCCESS"
                
                # Set service to manual start
                sc.exe config $mariadbServiceName start= demand | Out-Null
                Write-Log "[OK] MariaDB service set to manual start" "SUCCESS"
                
                # Set service description
                sc.exe description $mariadbServiceName "IsotoneStack MariaDB Database Server" | Out-Null
            } else {
                Write-Log "[WARNING] MariaDB service installation had issues" "WARNING"
                Write-Log "Installation output: $result" "WARNING"
                Write-Log "You may need to initialize the database first" "WARNING"
            }
        } catch {
            Write-Log "[ERROR] Exception installing MariaDB: $_" "ERROR"
        }
    }
    
    Write-Host ""
    
    # =================================================================
    # Service Registration Summary
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Service Registration Summary" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check Apache service status
    if (Test-ServiceExists $apacheServiceName) {
        $apacheService = Get-Service -Name $apacheServiceName
        Write-Log "[OK] $apacheServiceName is registered (Status: $($apacheService.Status))" "SUCCESS"
        $apacheRegistered = $true
    } else {
        Write-Log "[FAILED] $apacheServiceName is NOT registered" "ERROR"
        $apacheRegistered = $false
    }
    
    # Check MariaDB service status
    if (Test-ServiceExists $mariadbServiceName) {
        $mariadbService = Get-Service -Name $mariadbServiceName
        Write-Log "[OK] $mariadbServiceName is registered (Status: $($mariadbService.Status))" "SUCCESS"
        $mariadbRegistered = $true
    } else {
        Write-Log "[FAILED] $mariadbServiceName is NOT registered" "ERROR"
        $mariadbRegistered = $false
    }
    
    # Start services if requested
    if ($StartAfter -and ($apacheRegistered -or $mariadbRegistered)) {
        Write-Host ""
        Write-Log "Starting services..." "CYAN"
        
        if ($apacheRegistered) {
            try {
                Start-Service -Name $apacheServiceName -ErrorAction Stop
                Write-Log "  [OK] Apache service started" "SUCCESS"
            } catch {
                Write-Log "  [WARNING] Could not start Apache: $_" "WARNING"
            }
        }
        
        if ($mariadbRegistered) {
            try {
                Start-Service -Name $mariadbServiceName -ErrorAction Stop
                Write-Log "  [OK] MariaDB service started" "SUCCESS"
            } catch {
                Write-Log "  [WARNING] Could not start MariaDB: $_" "WARNING"
            }
        }
    }
    
    Write-Host ""
    Write-Log "============================================" "CYAN"
    Write-Log "    Next Steps" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    if ($apacheRegistered -or $mariadbRegistered) {
        Write-Log "To start services:" "INFO"
        Write-Log "  Start-Services.ps1" "DEBUG"
        Write-Host ""
        Write-Log "To stop services:" "INFO"
        Write-Log "  Stop-Services.ps1" "DEBUG"
    }
    
    # Additional service management commands
    Write-Host ""
    Write-Log "Service Management Commands:" "INFO"
    Write-Log "  View services:   Get-Service Isotone*" "DEBUG"
    Write-Log "  Start services:  Start-Service Isotone*" "DEBUG"
    Write-Log "  Stop services:   Stop-Service Isotone*" "DEBUG"
    Write-Log "  Service status:  sc query IsotoneApache" "DEBUG"
    
    Write-Host ""
    
    Write-Log "Service registration completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service registration failed with fatal error" "ERROR"
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

# Function to remove a service
function Remove-Service {
    param([string]$ServiceName,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    if (Test-ServiceExists $ServiceName) {
        Write-Log "  Stopping service: $ServiceName" "DEBUG"
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        
        Write-Log "  Removing service: $ServiceName" "DEBUG"
        sc.exe delete $ServiceName | Out-Null
        Start-Sleep -Seconds 2  # Give Windows time to remove the service
        
        if (!(Test-ServiceExists $ServiceName)) {
            Write-Log "  [OK] Service removed: $ServiceName" "SUCCESS"
            return $true
        } else {
            Write-Log "  [WARNING] Service may not be fully removed: $ServiceName" "WARNING"
            return $false
        }
    }
    return $true
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    Write-Log "Parameters: $($PSBoundParameters | Out-String)" "DEBUG"
    
    
    Write-Host ""
    Write-Log "=== IsotoneStack Service Registration ===" "MAGENTA"
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
    
    # Check if components exist
    Write-Log "Checking components..." "CYAN"
    
    # Check Apache
    $apacheExe = Join-Path $isotonePath "apache24\bin\httpd.exe"
    $apacheConf = Join-Path $isotonePath "apache24\conf\httpd.conf"
    if (!(Test-Path $apacheExe)) {
        Write-Log "  [ERROR] Apache not found at: $apacheExe" "ERROR"
        exit 1
    }
    Write-Log "  [OK] Apache found" "SUCCESS"
    
    # Check MariaDB (support both mariadbd.exe and mysqld.exe)
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mariadbExe = $null
    $mariadbExeName = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadbd.exe")) {
        $mariadbExe = Join-Path $mariadbBin "mariadbd.exe"
        $mariadbExeName = "mariadbd.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysqld.exe")) {
        $mariadbExe = Join-Path $mariadbBin "mysqld.exe"
        $mariadbExeName = "mysqld.exe"
    } else {
        Write-Log "  [ERROR] MariaDB not found in: $mariadbBin" "ERROR"
        Write-Log "  Looking for mariadbd.exe or mysqld.exe" "ERROR"
        exit 1
    }
    Write-Log "  [OK] MariaDB found ($mariadbExeName)" "SUCCESS"
    
    # Check MariaDB configuration
    $mariadbConfig = Join-Path $isotonePath "mariadb\my.ini"
    if (!(Test-Path $mariadbConfig)) {
        Write-Log "  [WARNING] MariaDB configuration not found" "WARNING"
        Write-Log "  Run Configure-IsotoneStack.ps1 first to create configuration" "WARNING"
    }
    
    Write-Host ""
    
    # =================================================================
    # Register Apache Service
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Registering Apache Service" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check if Apache service exists
    if (Test-ServiceExists $apacheServiceName) {
        if ($Force) {
            Write-Log "Removing existing Apache service (Force mode)..." "WARNING"
            Remove-Service $apacheServiceName
        } else {
            Write-Log "Apache service already exists. Use -Force to reinstall." "WARNING"
            $skipApache = $true
        }
    }
    
    if (!$skipApache) {
        Write-Log "Installing Apache service..." "INFO"
        
        # Change to Apache bin directory for installation
        Push-Location (Join-Path $isotonePath "apache24\bin")
        
        try {
            # Install Apache service
            $installArgs = @("-k", "install", "-n", $apacheServiceName, "-f", $apacheConf)
            $result = & .\httpd.exe $installArgs 2>&1 | Out-String
            
            Write-Log "Apache installation output:" "DEBUG" -NoConsole
            Write-Log $result "DEBUG"
            
            if (Test-ServiceExists $apacheServiceName) {
                Write-Log "[OK] Apache service installed successfully" "SUCCESS"
                
                # Set service to manual start
                sc.exe config $apacheServiceName start= demand | Out-Null
                Write-Log "[OK] Apache service set to manual start" "SUCCESS"
                
                # Set service description
                sc.exe description $apacheServiceName "IsotoneStack Apache HTTP Server" | Out-Null
            } else {
                Write-Log "[ERROR] Failed to install Apache service" "ERROR"
                Write-Log "Installation output: $result" "ERROR"
            }
        } catch {
            Write-Log "[ERROR] Exception installing Apache: $_" "ERROR"
        } finally {
            Pop-Location
        }
    }
    
    Write-Host ""
    
    # =================================================================
    # Register MariaDB Service
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Registering MariaDB Service" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check if MariaDB service exists
    if (Test-ServiceExists $mariadbServiceName) {
        if ($Force) {
            Write-Log "Removing existing MariaDB service (Force mode)..." "WARNING"
            
            # Try MariaDB's own removal method first
            & $mariadbExe --remove $mariadbServiceName 2>&1 | Out-Null
            Start-Sleep -Seconds 2
            
            # Then use sc.exe as backup
            Remove-Service $mariadbServiceName
        } else {
            Write-Log "MariaDB service already exists. Use -Force to reinstall." "WARNING"
            $skipMariaDB = $true
        }
    }
    
    if (!$skipMariaDB) {
        Write-Log "Installing MariaDB service..." "INFO"
        
        # Ensure data directory exists
        $dataDir = Join-Path $isotonePath "mariadb\data"
        if (!(Test-Path $dataDir)) {
            New-Item -Path $dataDir -ItemType Directory -Force | Out-Null
            Write-Log "  Created data directory: $dataDir" "DEBUG"
        }
        
        # Check if data directory is initialized
        $mysqlDir = Join-Path $dataDir "mysql"
        if (!(Test-Path $mysqlDir)) {
            Write-Log "  MariaDB data directory not initialized" "WARNING"
            Write-Log "  Run Configure-IsotoneStack.ps1 to initialize database" "WARNING"
        }
        
        try {
            # Install MariaDB service
            if (Test-Path $mariadbConfig) {
                $installArgs = @("--install", $mariadbServiceName, "--defaults-file=`"$mariadbConfig`"")
            } else {
                # Basic installation without config file
                $installArgs = @("--install", $mariadbServiceName)
            }
            
            $result = & $mariadbExe $installArgs 2>&1 | Out-String
            
            Write-Log "MariaDB installation output:" "DEBUG" -NoConsole
            Write-Log $result "DEBUG"
            
            # Give Windows time to register the service
            Start-Sleep -Seconds 3
            
            if (Test-ServiceExists $mariadbServiceName) {
                Write-Log "[OK] MariaDB service installed successfully" "SUCCESS"
                
                # Set service to manual start
                sc.exe config $mariadbServiceName start= demand | Out-Null
                Write-Log "[OK] MariaDB service set to manual start" "SUCCESS"
                
                # Set service description
                sc.exe description $mariadbServiceName "IsotoneStack MariaDB Database Server" | Out-Null
            } else {
                Write-Log "[WARNING] MariaDB service installation had issues" "WARNING"
                Write-Log "Installation output: $result" "WARNING"
                Write-Log "You may need to initialize the database first" "WARNING"
            }
        } catch {
            Write-Log "[ERROR] Exception installing MariaDB: $_" "ERROR"
        }
    }
    
    Write-Host ""
    
    # =================================================================
    # Service Registration Summary
    # =================================================================
    Write-Log "============================================" "CYAN"
    Write-Log "    Service Registration Summary" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    # Check Apache service status
    if (Test-ServiceExists $apacheServiceName) {
        $apacheService = Get-Service -Name $apacheServiceName
        Write-Log "[OK] $apacheServiceName is registered (Status: $($apacheService.Status))" "SUCCESS"
        $apacheRegistered = $true
    } else {
        Write-Log "[FAILED] $apacheServiceName is NOT registered" "ERROR"
        $apacheRegistered = $false
    }
    
    # Check MariaDB service status
    if (Test-ServiceExists $mariadbServiceName) {
        $mariadbService = Get-Service -Name $mariadbServiceName
        Write-Log "[OK] $mariadbServiceName is registered (Status: $($mariadbService.Status))" "SUCCESS"
        $mariadbRegistered = $true
    } else {
        Write-Log "[FAILED] $mariadbServiceName is NOT registered" "ERROR"
        $mariadbRegistered = $false
    }
    
    # Start services if requested
    if ($StartAfter -and ($apacheRegistered -or $mariadbRegistered)) {
        Write-Host ""
        Write-Log "Starting services..." "CYAN"
        
        if ($apacheRegistered) {
            try {
                Start-Service -Name $apacheServiceName -ErrorAction Stop
                Write-Log "  [OK] Apache service started" "SUCCESS"
            } catch {
                Write-Log "  [WARNING] Could not start Apache: $_" "WARNING"
            }
        }
        
        if ($mariadbRegistered) {
            try {
                Start-Service -Name $mariadbServiceName -ErrorAction Stop
                Write-Log "  [OK] MariaDB service started" "SUCCESS"
            } catch {
                Write-Log "  [WARNING] Could not start MariaDB: $_" "WARNING"
            }
        }
    }
    
    Write-Host ""
    Write-Log "============================================" "CYAN"
    Write-Log "    Next Steps" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    if ($apacheRegistered -or $mariadbRegistered) {
        Write-Log "To start services:" "INFO"
        Write-Log "  Start-Services.ps1" "DEBUG"
        Write-Host ""
        Write-Log "To stop services:" "INFO"
        Write-Log "  Stop-Services.ps1" "DEBUG"
    }
    
    # Additional service management commands
    Write-Host ""
    Write-Log "Service Management Commands:" "INFO"
    Write-Log "  View services:   Get-Service Isotone*" "DEBUG"
    Write-Log "  Start services:  Start-Service Isotone*" "DEBUG"
    Write-Log "  Stop services:   Stop-Service Isotone*" "DEBUG"
    Write-Log "  Service status:  sc query IsotoneApache" "DEBUG"
    
    Write-Host ""
    
    Write-Log "Service registration completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service registration failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
