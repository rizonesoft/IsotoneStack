# Update-AllScriptsLogging.ps1
# Updates all existing scripts to use the new settings-based logging system
# Adds -Verbose and -Debug switches to all scripts

param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Verbose
)

#Requires -Version 5.1

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
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        Write-Warning "Failed to load settings file: $_"
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if needed
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
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
if (-not $currentLogLevel) { $currentLogLevel = 3 }

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog
    )
    
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    if ($logToConsole -and -not $NoConsole) {
        $showInConsole = $false
        
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        elseif ($Verbose) {
            $showInConsole = $true
        }
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

# Template for new logging section
$newLoggingTemplate = @'
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
'@

# Main script logic
try {
    Write-Log "Script Logging Update Started" "INFO" -AlwaysLog
    Write-Host ""
    Write-Log "=== Updating All Scripts to New Logging System ===" "MAGENTA"
    Write-Host ""
    
    # Get all PowerShell scripts to update
    $scriptsToUpdate = @(
        "Register-Services.ps1",
        "Unregister-Services.ps1",
        "Start-Services.ps1",
        "Stop-Services.ps1",
        "Configure-IsotoneStack.ps1",
        "Complete-Install.ps1",
        "Install-VCRedist.ps1",
        "Secure-phpMyAdmin-ControlUser.ps1",
        "Setup-phpMyAdmin-Storage.ps1"
    )
    
    Write-Log "Scripts to update: $($scriptsToUpdate.Count)" "INFO" -AlwaysLog
    
    $updatedCount = 0
    $errorCount = 0
    
    foreach ($scriptFile in $scriptsToUpdate) {
        $scriptFullPath = Join-Path $scriptPath $scriptFile
        
        if (!(Test-Path $scriptFullPath)) {
            Write-Log "  [SKIP] Not found: $scriptFile" "WARNING"
            continue
        }
        
        try {
            Write-Log "Processing: $scriptFile" "DEBUG"
            
            if ($DryRun) {
                Write-Log "  [DRY RUN] Would update: $scriptFile" "CYAN"
                $updatedCount++
                continue
            }
            
            # Read the script content
            $content = Get-Content -Path $scriptFullPath -Raw
            
            # Create backup
            $backupPath = "$scriptFullPath.bak"
            Copy-Item -Path $scriptFullPath -Destination $backupPath -Force
            
            # Check if script already has param block
            if ($content -notmatch 'param\s*\(') {
                # Add param block at the beginning
                $paramBlock = @'
param(
    [switch]$Force,
    [switch]$Verbose,
    [switch]$Debug
)

'@
                $content = $paramBlock + $content
            }
            else {
                # Update existing param block to include Verbose and Debug if not present
                if ($content -notmatch '\[switch\]\$Verbose') {
                    $content = $content -replace '(param\s*\([^)]*)', '$1,`n    [switch]$Verbose'
                }
                if ($content -notmatch '\[switch\]\$Debug') {
                    $content = $content -replace '(param\s*\([^)]*)', '$1,`n    [switch]$Debug'
                }
            }
            
            # Remove old logging initialization
            $content = $content -replace '# Initialize log file[\s\S]*?(?=# Helper function|# Logging function|function Write-Log|# Main script|try\s*\{)', ''
            $content = $content -replace '# Create logs directory[\s\S]*?(?=# Helper function|# Logging function|function Write-Log|# Main script|try\s*\{)', ''
            
            # Remove old Write-Log function
            $content = $content -replace '# Logging function[\s\S]*?function Write-Log[\s\S]*?\n\}', ''
            $content = $content -replace 'function Write-Log[\s\S]*?\n\}', ''
            
            # Find where to insert new logging code (after path definitions but before main logic)
            if ($content -match '(\$logsPath\s*=.*\n)') {
                $insertPoint = $Matches[0]
                $content = $content -replace [regex]::Escape($insertPoint), "$insertPoint`n$newLoggingTemplate`n"
            }
            elseif ($content -match '(\$isotonePath\s*=.*\n)') {
                # Add logsPath definition and new logging
                $insertPoint = $Matches[0]
                $logsPathDef = '$logsPath = Join-Path $isotonePath "logs\isotone"' + "`n"
                $content = $content -replace [regex]::Escape($insertPoint), "$insertPoint$logsPathDef`n$newLoggingTemplate`n"
            }
            
            # Update logging calls to use new format
            $content = $content -replace 'Write-Log\s+"====+"\s+"INFO"', ''
            $content = $content -replace 'Write-Log\s+"Script:\s*\$scriptName"\s+"INFO"', ''
            $content = $content -replace 'Write-Log\s+"Installation Directory:.*"\s+"INFO"', ''
            $content = $content -replace 'Write-Log\s+"Parameters:.*"\s+"INFO"', 'Write-Log "Parameters: $($PSBoundParameters | Out-String)" "DEBUG"'
            
            # Update script start/end logging
            $content = $content -replace 'Write-Log\s+".*Started"\s+"INFO"', 'Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog'
            $content = $content -replace 'Write-Log\s+"Script completed successfully"\s+"SUCCESS"', 'Write-Log "Script completed successfully" "SUCCESS" -AlwaysLog'
            
            # Add finally block for cleanup if not present
            if ($content -notmatch 'finally\s*\{') {
                $content = $content -replace '(catch\s*\{[\s\S]*?\n\})', @'
$1
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}
'@
            }
            
            # Save the updated script
            Set-Content -Path $scriptFullPath -Value $content -Encoding UTF8
            
            Write-Log "  [OK] Updated: $scriptFile" "SUCCESS"
            $updatedCount++
        }
        catch {
            Write-Log "  [ERROR] Failed to update $scriptFile : $_" "ERROR"
            $errorCount++
            
            # Restore from backup on error
            if (Test-Path "$scriptFullPath.bak") {
                Copy-Item -Path "$scriptFullPath.bak" -Destination $scriptFullPath -Force
            }
        }
    }
    
    # Clean up old timestamped log files
    if (-not $DryRun) {
        Write-Host ""
        Write-Log "Cleaning up old timestamped log files..." "INFO" -AlwaysLog
        
        $oldLogs = Get-ChildItem -Path $logsPath -Filter "*_20*.log" -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -match '_\d{8}_\d{6}\.log$' }
        
        if ($oldLogs.Count -gt 0) {
            Write-Log "Found $($oldLogs.Count) old timestamped log files" "INFO" -AlwaysLog
            $oldLogs | Remove-Item -Force
            Write-Log "Removed old timestamped log files" "SUCCESS"
        }
        else {
            Write-Log "No old timestamped log files found" "DEBUG"
        }
    }
    
    # Summary
    Write-Host ""
    Write-Log "Update Summary:" "INFO" -AlwaysLog
    Write-Log "  Updated: $updatedCount scripts" "SUCCESS"
    if ($errorCount -gt 0) {
        Write-Log "  Errors: $errorCount scripts" "ERROR"
    }
    if ($DryRun) {
        Write-Log "  Mode: DRY RUN (no changes made)" "CYAN"
    }
    
    Write-Host ""
    Write-Log "Script logging update completed successfully" "SUCCESS" -AlwaysLog
    
    if (-not $DryRun) {
        Write-Host ""
        Write-Log "Next steps:" "CYAN"
        Write-Log "1. Test updated scripts with -Verbose flag" "INFO" -AlwaysLog
        Write-Log "2. Configure global settings: .\scripts\Set-IsotoneSettings.bat -List" "INFO" -AlwaysLog
        Write-Log "3. Remove .bak files after testing: Remove-Item .\scripts\*.bak" "INFO" -AlwaysLog
    }
}
catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}
finally {
    # Clean up old logs
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}