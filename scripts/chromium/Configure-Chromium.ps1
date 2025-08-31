# Configure-Chromium.ps1
# Configures Chromium preferences to disable sign-in and other features

param(
    [switch]$DisableSignIn = $true,
    [switch]$DisableSync = $true,
    [switch]$DisablePasswordManager = $false,
    [switch]$SetHomePage,
    [string]$HomePage = "http://localhost",
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
    BrowserData = Join-Path $isotonePath "browser\data"
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
        Write-Log "Parameters: DisableSignIn=$DisableSignIn, DisableSync=$DisableSync, DisablePasswordManager=$DisablePasswordManager" "DEBUG"
    }
    
    Write-Host ""
    Write-Log "=== Configure Chromium Settings ===" "MAGENTA"
    if ($Verbose) {
        Write-Log "IsotoneStack Path: $isotonePath" "DEBUG"
    }
    Write-Host ""
    
    # Check if browser data directory exists
    $browserDataDir = $paths.BrowserData
    $defaultProfile = Join-Path $browserDataDir "Default"
    $preferencesFile = Join-Path $defaultProfile "Preferences"
    $localStateFile = Join-Path $browserDataDir "Local State"
    
    # Create directories if they don't exist
    if (!(Test-Path $defaultProfile)) {
        New-Item -Path $defaultProfile -ItemType Directory -Force | Out-Null
        Write-Log "Created Default profile directory" "INFO"
    }
    
    # Load or create preferences
    $preferences = $null
    if (Test-Path $preferencesFile) {
        try {
            $jsonContent = Get-Content -Path $preferencesFile -Raw
            $preferences = $jsonContent | ConvertFrom-Json -AsHashtable -ErrorAction SilentlyContinue
            if (-not $preferences) {
                # Fallback for older PowerShell versions
                $preferences = $jsonContent | ConvertFrom-Json
            }
            Write-Log "Loaded existing preferences file" "DEBUG"
        }
        catch {
            Write-Log "Failed to load preferences, creating new one" "WARNING"
            $preferences = $null
        }
    }
    
    # Convert to hashtable for easier manipulation
    function ConvertTo-HashtableRecursive {
        param($InputObject)
        
        if ($InputObject -is [System.Collections.Hashtable]) {
            return $InputObject
        }
        elseif ($InputObject -is [System.Management.Automation.PSCustomObject]) {
            $hash = @{}
            $InputObject.PSObject.Properties | ForEach-Object {
                $hash[$_.Name] = ConvertTo-HashtableRecursive $_.Value
            }
            return $hash
        }
        elseif ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            return @($InputObject | ForEach-Object { ConvertTo-HashtableRecursive $_ })
        }
        else {
            return $InputObject
        }
    }
    
    if ($preferences) {
        $prefsHash = ConvertTo-HashtableRecursive $preferences
    }
    else {
        $prefsHash = @{}
    }
    
    # Configure sign-in and sync settings
    if ($DisableSignIn) {
        Write-Log "Disabling sign-in features" "INFO"
        
        # Ensure browser object exists
        if (-not $prefsHash.browser) {
            $prefsHash.browser = @{}
        }
        
        # Disable sign-in
        $prefsHash.browser.signin = @{
            allowed = $false
            allowed_on_next_startup = $false
        }
        
        # Disable profile picker
        $prefsHash.browser.show_avatar_button = $false
        $prefsHash.browser.show_profile_picker_on_startup = $false
        
        # Ensure signin object exists
        if (-not $prefsHash.signin) {
            $prefsHash.signin = @{}
        }
        $prefsHash.signin.allowed = $false
        $prefsHash.signin.allowed_on_next_startup = $false
    }
    
    if ($DisableSync) {
        Write-Log "Disabling sync features" "INFO"
        
        # Ensure sync_promo object exists
        if (-not $prefsHash.sync_promo) {
            $prefsHash.sync_promo = @{}
        }
        
        $prefsHash.sync_promo.show_on_first_run_allowed = $false
        $prefsHash.sync_promo.user_skipped = $true
        
        # Disable sync
        if (-not $prefsHash.sync) {
            $prefsHash.sync = @{}
        }
        $prefsHash.sync.requested = $false
    }
    
    if ($DisablePasswordManager) {
        Write-Log "Disabling password manager" "INFO"
        
        # Ensure credentials_enable_service exists
        if (-not $prefsHash.credentials_enable_service) {
            $prefsHash.credentials_enable_service = $false
        }
        
        # Ensure profile object exists
        if (-not $prefsHash.profile) {
            $prefsHash.profile = @{}
        }
        
        # Ensure password_manager_enabled exists
        if (-not $prefsHash.profile.password_manager_enabled) {
            $prefsHash.profile.password_manager_enabled = $false
        }
    }
    
    if ($SetHomePage) {
        Write-Log "Setting homepage to: $HomePage" "INFO"
        
        # Ensure homepage exists
        if (-not $prefsHash.homepage) {
            $prefsHash.homepage = $HomePage
        }
        
        # Ensure homepage_is_newtabpage exists
        if (-not $prefsHash.homepage_is_newtabpage) {
            $prefsHash.homepage_is_newtabpage = $false
        }
        
        # Ensure session object exists
        if (-not $prefsHash.session) {
            $prefsHash.session = @{}
        }
        
        # Set startup pages
        $prefsHash.session.restore_on_startup = 4  # Open specific pages
        $prefsHash.session.startup_urls = @($HomePage)
    }
    
    # Disable default browser check
    if (-not $prefsHash.browser) {
        $prefsHash.browser = @{}
    }
    $prefsHash.browser.check_default_browser = $false
    $prefsHash.browser.show_home_button = $true
    
    # Show bookmarks bar by default
    if (-not $prefsHash.bookmark_bar) {
        $prefsHash.bookmark_bar = @{}
    }
    $prefsHash.bookmark_bar.show_on_all_tabs = $true
    
    # Disable notifications
    if (-not $prefsHash.default_apps_install_state) {
        $prefsHash.default_apps_install_state = 3  # Suppress default apps
    }
    
    # Additional privacy settings
    if (-not $prefsHash.safebrowsing) {
        $prefsHash.safebrowsing = @{}
    }
    $prefsHash.safebrowsing.enabled = $false
    $prefsHash.safebrowsing.enhanced = $false
    
    if (-not $prefsHash.alternate_error_pages) {
        $prefsHash.alternate_error_pages = @{}
    }
    $prefsHash.alternate_error_pages.enabled = $false
    
    if (-not $prefsHash.search_suggest) {
        $prefsHash.search_suggest = @{}
    }
    $prefsHash.search_suggest.enabled = $false
    
    # Convert back to JSON and save
    $preferencesJson = $prefsHash | ConvertTo-Json -Depth 100
    Set-Content -Path $preferencesFile -Value $preferencesJson -Encoding UTF8
    Write-Log "Saved preferences file" "SUCCESS"
    
    # Configure Local State file for additional settings
    $localState = $null
    if (Test-Path $localStateFile) {
        try {
            $jsonContent = Get-Content -Path $localStateFile -Raw
            $localState = $jsonContent | ConvertFrom-Json -AsHashtable -ErrorAction SilentlyContinue
            if (-not $localState) {
                # Fallback for older PowerShell versions
                $localState = $jsonContent | ConvertFrom-Json
            }
            Write-Log "Loaded existing Local State file" "DEBUG"
        }
        catch {
            Write-Log "Failed to load Local State, creating new one" "WARNING"
            $localState = $null
        }
    }
    
    # Convert to hashtable
    if ($localState) {
        $localStateHash = ConvertTo-HashtableRecursive $localState
    }
    else {
        $localStateHash = @{}
    }
    
    # Disable first run experience
    if (-not $localStateHash.browser) {
        $localStateHash.browser = @{}
    }
    $localStateHash.browser.enabled_labs_experiments = @()
    $localStateHash.browser.first_run_finished = $true
    
    # Disable metrics reporting
    if (-not $localStateHash.user_experience_metrics) {
        $localStateHash.user_experience_metrics = @{}
    }
    $localStateHash.user_experience_metrics.reporting_enabled = $false
    
    # Convert back to JSON and save
    $localStateJson = $localStateHash | ConvertTo-Json -Depth 100
    Set-Content -Path $localStateFile -Value $localStateJson -Encoding UTF8
    Write-Log "Saved Local State file" "SUCCESS"
    
    # Summary
    Write-Host ""
    Write-Log "Chromium configuration completed successfully" "SUCCESS" -AlwaysLog
    Write-Log "[OK] Sign-in disabled" "SUCCESS"
    Write-Log "[OK] Sync disabled" "SUCCESS"
    if ($DisablePasswordManager) {
        Write-Log "[OK] Password manager disabled" "SUCCESS"
    }
    if ($SetHomePage) {
        Write-Log "[OK] Homepage set to: $HomePage" "SUCCESS"
    }
    
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