# Update-ScriptLogging.ps1
# Updates all existing scripts to use the new optimized logging approach
# This is a one-time migration script

param(
    [switch]$DryRun,
    [switch]$Verbose
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$pwshPath = Join-Path $isotonePath "pwsh"
$pwshExe = Join-Path $pwshPath "pwsh.exe"
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

# Apply settings
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
    $Verbose = $true
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
    
    if ($AlwaysLog -or $levelPriority -le $currentLogLevel) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    if (-not $NoConsole) {
        switch ($Level) {
            "ERROR"   { Write-Host $Message -ForegroundColor Red }
            "WARNING" { Write-Host $Message -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $Message -ForegroundColor Green }
            "INFO"    { if ($Verbose) { Write-Host $Message -ForegroundColor White } }
            "DEBUG"   { if ($Verbose) { Write-Host $Message -ForegroundColor Gray } }
            "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
            "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
            default   { if ($Verbose) { Write-Host $Message } }
        }
    }
}

# Main script logic
try {
    Write-Log "Script Logging Update Started" "INFO" -AlwaysLog
    Write-Host ""
    Write-Log "=== Updating Script Logging ===" "MAGENTA"
    Write-Host ""
    
    # Get all PowerShell scripts except this one and the template
    $scripts = Get-ChildItem -Path $scriptPath -Filter "*.ps1" | 
        Where-Object { 
            $_.Name -ne "Update-ScriptLogging.ps1" -and 
            $_.Name -ne "_Template.ps1" 
        }
    
    Write-Log "Found $($scripts.Count) scripts to update" "INFO" -AlwaysLog
    
    $updatedCount = 0
    $skippedCount = 0
    $errorCount = 0
    
    foreach ($script in $scripts) {
        try {
            Write-Log "Processing: $($script.Name)" "DEBUG"
            
            # Read the script content
            $content = Get-Content -Path $script.FullName -Raw
            
            # Check if it uses the old logging pattern (timestamped log files)
            if ($content -match '\$timestamp\s*=\s*Get-Date\s*-Format\s*"yyyyMMdd_HHmmss"' -and 
                $content -match '\$logFile\s*=.*\$scriptName.*\$timestamp.*\.log') {
                
                if ($DryRun) {
                    Write-Log "  [DRY RUN] Would update: $($script.Name)" "CYAN"
                    $updatedCount++
                    continue
                }
                
                # Create backup
                $backupPath = "$($script.FullName).bak"
                Copy-Item -Path $script.FullName -Destination $backupPath -Force
                
                # Update the logging initialization section
                $content = $content -replace '# Initialize log file[\s\S]*?\$logFile = Join-Path[^\r\n]+', @'
# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"
$maxLogSize = 10MB
$maxLogAge = 30
$logLevel = if ($Verbose) { "DEBUG" } else { "INFO" }

# Rotate log if it's too large
if ((Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs
    Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
        Remove-Item -Force
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
if (-not $currentLogLevel) { $currentLogLevel = 3 }'@
                
                # Save the updated script
                Set-Content -Path $script.FullName -Value $content -Encoding UTF8
                
                Write-Log "  [OK] Updated: $($script.Name)" "SUCCESS"
                $updatedCount++
            }
            else {
                Write-Log "  [SKIP] Already updated or custom logging: $($script.Name)" "DEBUG"
                $skippedCount++
            }
        }
        catch {
            Write-Log "  [ERROR] Failed to update $($script.Name): $_" "ERROR"
            $errorCount++
        }
    }
    
    # Clean up old timestamped log files
    if (-not $DryRun) {
        Write-Host ""
        Write-Log "Cleaning up old timestamped log files..." "INFO" -AlwaysLog
        
        $oldLogs = Get-ChildItem -Path $logsPath -Filter "*_20*.log" | 
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
    Write-Log "========================================" "INFO" -AlwaysLog
    Write-Log "Update Summary:" "INFO" -AlwaysLog
    Write-Log "  Updated: $updatedCount scripts" "SUCCESS"
    Write-Log "  Skipped: $skippedCount scripts" "INFO" -AlwaysLog
    if ($errorCount -gt 0) {
        Write-Log "  Errors: $errorCount scripts" "ERROR"
    }
    if ($DryRun) {
        Write-Log "  Mode: DRY RUN (no changes made)" "CYAN"
    }
    Write-Log "========================================" "INFO" -AlwaysLog
    
    Write-Host ""
    Write-Log "Script logging update completed successfully" "SUCCESS" -AlwaysLog
}
catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}
finally {
    # Clean up old logs
    if (Test-Path $logsPath) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}