# Set-IsotoneSettings.ps1
# Manages IsotoneStack settings configuration

param(
    [Parameter(Position=0)]
    [string]$Setting,
    
    [Parameter(Position=1)]
    [string]$Value,
    
    [switch]$List,
    [switch]$Reset,
    [switch]$AutoStart,           # Enable auto-start services with Windows
    [switch]$NoAutoStart,         # Disable auto-start services with Windows
    [switch]$EnableVerbose,
    [switch]$DisableVerbose,
    [int]$MaxLogSizeMB,
    [int]$MaxLogAgeDays,
    [switch]$EnableCleanup,
    [switch]$DisableCleanup,
    [switch]$EnableFileLogging,
    [switch]$DisableFileLogging,
    [switch]$Force
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$configPath = Join-Path $isotonePath "config"
$settingsFile = Join-Path $configPath "isotone-settings.json"
$logsPath = Join-Path $isotonePath "logs\isotone"

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Simple console output function (minimal logging for settings manager)
function Write-Output-Color {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    switch ($Color) {
        "Red"     { Write-Host $Message -ForegroundColor Red }
        "Yellow"  { Write-Host $Message -ForegroundColor Yellow }
        "Green"   { Write-Host $Message -ForegroundColor Green }
        "Cyan"    { Write-Host $Message -ForegroundColor Cyan }
        "Magenta" { Write-Host $Message -ForegroundColor Magenta }
        default   { Write-Host $Message -ForegroundColor White }
    }
}

# Default settings structure
$defaultSettings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $true
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
    services = @{
        autoStart = $false
        startupDelay = 5
    }
    paths = @{
        useRelativePaths = $true
    }
    development = @{
        debugMode = $false
        showStackTraces = $true
    }
}

# Load current settings
function Get-Settings {
    if (Test-Path $settingsFile) {
        try {
            $content = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
            return $content
        }
        catch {
            Write-Output-Color "[ERROR] Failed to load settings file: $_" "Red"
            return $defaultSettings
        }
    }
    else {
        return $defaultSettings
    }
}

# Save settings to file
function Save-Settings {
    param($Settings)
    
    try {
        # Ensure config directory exists
        if (!(Test-Path $configPath)) {
            New-Item -Path $configPath -ItemType Directory -Force | Out-Null
        }
        
        # Convert to JSON with proper formatting
        $json = $Settings | ConvertTo-Json -Depth 10 -Compress:$false
        
        # Save to file
        Set-Content -Path $settingsFile -Value $json -Encoding UTF8
        
        Write-Output-Color "[OK] Settings saved successfully" "Green"
        return $true
    }
    catch {
        Write-Output-Color "[ERROR] Failed to save settings: $_" "Red"
        return $false
    }
}

# Display current settings
function Show-Settings {
    param($Settings)
    
    Write-Output-Color "`n=== IsotoneStack Settings ===" "Magenta"
    
    Write-Output-Color "`nLogging Settings:" "Cyan"
    Write-Host "  Default Log Level:     $($Settings.logging.defaultLogLevel)"
    Write-Host "  Verbose Mode:          $($Settings.logging.verbose)"
    Write-Host "  Max Log Size (MB):     $($Settings.logging.maxLogSizeMB)"
    Write-Host "  Max Log Age (Days):    $($Settings.logging.maxLogAgeDays)"
    Write-Host "  Cleanup Enabled:       $($Settings.logging.cleanupEnabled)"
    Write-Host "  Log to File:           $($Settings.logging.logToFile)"
    Write-Host "  Log to Console:        $($Settings.logging.logToConsole)"
    Write-Host "  Console Log Levels:    $($Settings.logging.consoleLogLevels -join ', ')"
    Write-Host "  Archive Old Logs:      $($Settings.logging.archiveOldLogs)"
    
    Write-Output-Color "`nService Settings:" "Cyan"
    Write-Host "  Auto Start:            $($Settings.services.autoStart)"
    Write-Host "  Startup Delay (sec):   $($Settings.services.startupDelay)"
    
    Write-Output-Color "`nPath Settings:" "Cyan"
    Write-Host "  Use Relative Paths:    $($Settings.paths.useRelativePaths)"
    
    Write-Output-Color "`nDevelopment Settings:" "Cyan"
    Write-Host "  Debug Mode:            $($Settings.development.debugMode)"
    Write-Host "  Show Stack Traces:     $($Settings.development.showStackTraces)"
    
    Write-Host ""
    Write-Output-Color "Settings file: $settingsFile" "Yellow"
    Write-Host ""
}

# Main script logic
try {
    Write-Host ""
    Write-Output-Color "=== IsotoneStack Settings Manager ===" "Magenta"
    
    # Load current settings
    $settings = Get-Settings
    
    # Handle reset
    if ($Reset) {
        Write-Output-Color "Resetting to default settings..." "Yellow"
        if ($Force -or (Read-Host "Are you sure you want to reset all settings? (y/N)") -eq 'y') {
            $settings = $defaultSettings
            if (Save-Settings -Settings $settings) {
                Write-Output-Color "[OK] Settings reset to defaults" "Green"
            }
        }
        else {
            Write-Output-Color "Reset cancelled" "Yellow"
        }
        exit
    }
    
    # Handle list
    if ($List) {
        Show-Settings -Settings $settings
        exit
    }
    
    # Handle quick switches
    $modified = $false
    
    if ($EnableVerbose) {
        $settings.logging.verbose = $true
        Write-Output-Color "Verbose mode enabled" "Green"
        $modified = $true
    }
    
    if ($DisableVerbose) {
        $settings.logging.verbose = $false
        Write-Output-Color "Verbose mode disabled" "Green"
        $modified = $true
    }
    
    if ($MaxLogSizeMB -gt 0) {
        $settings.logging.maxLogSizeMB = $MaxLogSizeMB
        Write-Output-Color "Max log size set to $MaxLogSizeMB MB" "Green"
        $modified = $true
    }
    
    if ($MaxLogAgeDays -gt 0) {
        $settings.logging.maxLogAgeDays = $MaxLogAgeDays
        Write-Output-Color "Max log age set to $MaxLogAgeDays days" "Green"
        $modified = $true
    }
    
    if ($EnableCleanup) {
        $settings.logging.cleanupEnabled = $true
        Write-Output-Color "Log cleanup enabled" "Green"
        $modified = $true
    }
    
    if ($DisableCleanup) {
        $settings.logging.cleanupEnabled = $false
        Write-Output-Color "Log cleanup disabled" "Green"
        $modified = $true
    }
    
    if ($EnableFileLogging) {
        $settings.logging.logToFile = $true
        Write-Output-Color "File logging enabled" "Green"
        $modified = $true
    }
    
    if ($DisableFileLogging) {
        $settings.logging.logToFile = $false
        Write-Output-Color "File logging disabled" "Green"
        $modified = $true
    }
    
    if ($AutoStart) {
        $settings.services.autoStart = $true
        Write-Output-Color "Service auto-start enabled" "Green"
        $modified = $true
    }
    
    if ($NoAutoStart) {
        $settings.services.autoStart = $false
        Write-Output-Color "Service auto-start disabled" "Green"
        $modified = $true
    }
    
    # Handle direct setting/value pairs
    if ($Setting) {
        switch ($Setting.ToLower()) {
            "verbose" {
                $settings.logging.verbose = [bool]::Parse($Value)
                Write-Output-Color "Verbose mode set to $Value" "Green"
                $modified = $true
            }
            "loglevel" {
                if ($Value -in @("ERROR", "WARNING", "INFO", "DEBUG")) {
                    $settings.logging.defaultLogLevel = $Value
                    Write-Output-Color "Default log level set to $Value" "Green"
                    $modified = $true
                }
                else {
                    Write-Output-Color "[ERROR] Invalid log level. Must be: ERROR, WARNING, INFO, or DEBUG" "Red"
                }
            }
            "maxlogsize" {
                $settings.logging.maxLogSizeMB = [int]$Value
                Write-Output-Color "Max log size set to $Value MB" "Green"
                $modified = $true
            }
            "maxlogage" {
                $settings.logging.maxLogAgeDays = [int]$Value
                Write-Output-Color "Max log age set to $Value days" "Green"
                $modified = $true
            }
            "cleanup" {
                $settings.logging.cleanupEnabled = [bool]::Parse($Value)
                Write-Output-Color "Cleanup enabled set to $Value" "Green"
                $modified = $true
            }
            "filelog" {
                $settings.logging.logToFile = [bool]::Parse($Value)
                Write-Output-Color "File logging set to $Value" "Green"
                $modified = $true
            }
            "consolelog" {
                $settings.logging.logToConsole = [bool]::Parse($Value)
                Write-Output-Color "Console logging set to $Value" "Green"
                $modified = $true
            }
            "debugmode" {
                $settings.development.debugMode = [bool]::Parse($Value)
                Write-Output-Color "Debug mode set to $Value" "Green"
                $modified = $true
            }
            default {
                Write-Output-Color "[ERROR] Unknown setting: $Setting" "Red"
                Write-Output-Color "Valid settings: verbose, loglevel, maxlogsize, maxlogage, cleanup, filelog, consolelog, debugmode" "Yellow"
            }
        }
    }
    
    # Save if modified
    if ($modified) {
        Save-Settings -Settings $settings
    }
    elseif (-not $List -and -not $Reset -and -not $Setting) {
        # Show current settings if no action specified
        Show-Settings -Settings $settings
        
        Write-Output-Color "Usage Examples:" "Cyan"
        Write-Host "  Enable verbose mode:     .\Set-IsotoneSettings.ps1 -EnableVerbose"
        Write-Host "  Set max log size:        .\Set-IsotoneSettings.ps1 -MaxLogSizeMB 20"
        Write-Host "  Set max log age:         .\Set-IsotoneSettings.ps1 -MaxLogAgeDays 7"
        Write-Host "  Set log level:           .\Set-IsotoneSettings.ps1 loglevel DEBUG"
        Write-Host "  List all settings:       .\Set-IsotoneSettings.ps1 -List"
        Write-Host "  Reset to defaults:       .\Set-IsotoneSettings.ps1 -Reset"
        Write-Host ""
    }
}
catch {
    Write-Output-Color "[ERROR] $($_.Exception.Message)" "Red"
    exit 1
}