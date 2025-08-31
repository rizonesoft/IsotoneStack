# Launch-Chromium.ps1
# Launches Chromium browser with IsotoneStack default page

param(
    [string]$URL = "http://localhost",
    [switch]$IncognitoMode,
    [switch]$KioskMode,
    [switch]$Verbose
)

#Requires -Version 5.1

# Get script locations using portable paths (no hardcoded paths)
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent (Split-Path -Parent $scriptPath)
$pwshPath = Join-Path $isotonePath "pwsh"
$pwshExe = Join-Path $pwshPath "pwsh.exe"
$logsPath = Join-Path $isotonePath "logs\isotone"

# Define common paths
$paths = @{
    Root      = $isotonePath
    Scripts   = Split-Path -Parent $scriptPath
    Pwsh      = $pwshPath
    Apache    = Join-Path $isotonePath "apache24"
    PHP       = Join-Path $isotonePath "php"
    MariaDB   = Join-Path $isotonePath "mariadb"
    WWW       = Join-Path $isotonePath "www"
    Config    = Join-Path $isotonePath "config"
    Bin       = Join-Path $isotonePath "bin"
    Browser   = Join-Path $isotonePath "browser"
    Logs      = Join-Path $isotonePath "logs"
    LogsIsotone = $logsPath
}

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

# Helper function to check admin privileges
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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

# Main script logic
try {
    # Start logging (only log start/end and important events)
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    if ($Verbose) {
        Write-Log "Parameters: URL=$URL, IncognitoMode=$IncognitoMode, KioskMode=$KioskMode, Verbose=$Verbose" "DEBUG"
    }
    
    Write-Host ""
    Write-Log "=== Launch Chromium Browser ===" "MAGENTA"
    if ($Verbose) {
        Write-Log "IsotoneStack Path: $isotonePath" "DEBUG"
    }
    Write-Host ""
    
    # Find browser executable
    $browserExe = $null
    $browserFound = $false
    
    # Priority 1: Check for Chromium in isotone directory
    $isotoneChromium = Join-Path $paths.Browser "chromium\chrome.exe"
    if (Test-Path $isotoneChromium) {
        $browserExe = $isotoneChromium
        $browserFound = $true
        Write-Log "Found bundled Chromium in IsotoneStack" "INFO"
    }
    
    # Priority 2: Check for system-installed Chromium
    if (-not $browserFound) {
        $chromiumPaths = @(
            "${env:ProgramFiles}\Chromium\Application\chrome.exe",
            "${env:ProgramFiles(x86)}\Chromium\Application\chrome.exe",
            "${env:LocalAppData}\Chromium\Application\chrome.exe"
        )
        
        foreach ($path in $chromiumPaths) {
            if (Test-Path $path) {
                $browserExe = $path
                $browserFound = $true
                Write-Log "Found system Chromium at: $browserExe" "INFO"
                break
            }
        }
    }
    
    # Priority 3: Fall back to Chrome if no Chromium found
    if (-not $browserFound) {
        Write-Log "Chromium not found, checking for Google Chrome" "DEBUG"
        
        $chromePaths = @(
            "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
            "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
            "${env:LocalAppData}\Google\Chrome\Application\chrome.exe"
        )
        
        foreach ($path in $chromePaths) {
            if (Test-Path $path) {
                $browserExe = $path
                $browserFound = $true
                Write-Log "Using Google Chrome as fallback: $browserExe" "INFO"
                break
            }
        }
    }
    
    # Exit if no browser found
    if (-not $browserFound) {
        Write-Log "Chromium or Chrome browser not found on the system" "ERROR"
        Write-Log "Please install Chromium or Google Chrome to use this launcher" "ERROR"
        exit 1
    }
    
    # Build command line arguments
    $arguments = @()
    
    # Add URL
    $arguments += $URL
    
    # Add mode flags
    if ($IncognitoMode) {
        $arguments += "--incognito"
        Write-Log "Launching in Incognito mode" "INFO"
    }
    
    if ($KioskMode) {
        $arguments += "--kiosk"
        Write-Log "Launching in Kiosk mode" "INFO"
    }
    
    # Configure browser directories for IsotoneStack
    $browserDataDir = Join-Path $isotonePath "browser\data"
    $browserCacheDir = Join-Path $isotonePath "browser\cache"
    $browserTempDir = Join-Path $isotonePath "browser\temp"
    
    # Create directories if they don't exist
    if (!(Test-Path $browserDataDir)) {
        New-Item -Path $browserDataDir -ItemType Directory -Force | Out-Null
        Write-Log "Created browser data directory: $browserDataDir" "DEBUG"
    }
    if (!(Test-Path $browserCacheDir)) {
        New-Item -Path $browserCacheDir -ItemType Directory -Force | Out-Null
        Write-Log "Created browser cache directory: $browserCacheDir" "DEBUG"
    }
    if (!(Test-Path $browserTempDir)) {
        New-Item -Path $browserTempDir -ItemType Directory -Force | Out-Null
        Write-Log "Created browser temp directory: $browserTempDir" "DEBUG"
    }
    
    # Add directory arguments
    $arguments += "--user-data-dir=`"$browserDataDir`""
    $arguments += "--disk-cache-dir=`"$browserCacheDir`""
    
    # Disable default browser prompt and other notifications
    $arguments += "--no-first-run"
    $arguments += "--no-default-browser-check"
    $arguments += "--suppress-message-center-popups"
    $arguments += "--disable-features=DefaultBrowserInfoBar"
    
    # Enable extensions support
    $arguments += "--enable-extensions"
    $arguments += "--enable-web-store"
    
    # Launch browser
    Write-Log "Launching browser: $URL" "INFO"
    if ($Verbose) {
        Write-Log "Executable: $browserExe" "DEBUG"
        Write-Log "Arguments: $($arguments -join ' ')" "DEBUG"
    }
    
    try {
        # Try to launch the browser
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $browserExe
        $startInfo.Arguments = $arguments -join ' '
        $startInfo.UseShellExecute = $true
        $startInfo.WorkingDirectory = $isotonePath
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        Write-Log "Browser launched successfully" "SUCCESS"
    }
    catch {
        Write-Log "Failed to launch bundled Chromium: $_" "ERROR"
        
        # Check if the error is due to untrusted executable
        if ($_.Exception.Message -like "*canceled by the user*" -or $_.Exception.Message -like "*operation was canceled*") {
            Write-Log "The bundled Chromium appears to be blocked by Windows security" "WARNING"
            Write-Log "Attempting to use system Chrome/Chromium instead..." "INFO"
            
            # Fall back to system Chrome/Chromium
            $systemBrowserFound = $false
            
            # Try system Chromium first
            $chromiumPaths = @(
                "${env:ProgramFiles}\Chromium\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Chromium\Application\chrome.exe",
                "${env:LocalAppData}\Chromium\Application\chrome.exe"
            )
            
            foreach ($path in $chromiumPaths) {
                if (Test-Path $path) {
                    $browserExe = $path
                    $systemBrowserFound = $true
                    Write-Log "Using system Chromium: $browserExe" "INFO"
                    break
                }
            }
            
            # Try Chrome if no Chromium found
            if (-not $systemBrowserFound) {
                $chromePaths = @(
                    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
                    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                    "${env:LocalAppData}\Google\Chrome\Application\chrome.exe"
                )
                
                foreach ($path in $chromePaths) {
                    if (Test-Path $path) {
                        $browserExe = $path
                        $systemBrowserFound = $true
                        Write-Log "Using Google Chrome: $browserExe" "INFO"
                        break
                    }
                }
            }
            
            if ($systemBrowserFound) {
                try {
                    Start-Process -FilePath $browserExe -ArgumentList $arguments
                    Write-Log "System browser launched successfully" "SUCCESS"
                }
                catch {
                    Write-Log "Failed to launch system browser: $_" "ERROR"
                    exit 1
                }
            }
            else {
                Write-Log "No system Chrome or Chromium found" "ERROR"
                Write-Log "Please install Chrome or Chromium, or unblock the bundled executable" "ERROR"
                Write-Host ""
                Write-Host "To unblock the bundled Chromium:" -ForegroundColor Yellow
                Write-Host "1. Right-click on: $browserExe" -ForegroundColor Yellow
                Write-Host "2. Select Properties" -ForegroundColor Yellow
                Write-Host "3. Check 'Unblock' at the bottom of the General tab" -ForegroundColor Yellow
                Write-Host "4. Click OK and try again" -ForegroundColor Yellow
                exit 1
            }
        }
        else {
            # Other error
            Write-Log "Unexpected error: $_" "ERROR"
            exit 1
        }
    }
    
    # Summary
    Write-Host ""
    Write-Log "Browser launched successfully" "SUCCESS" -AlwaysLog
    if ($Verbose) {
        Write-Log "Log file: $logFile" "DEBUG"
    }
}
catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Script failed with fatal error" "ERROR"
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