#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Restarts the IsotoneStack Apache service
.DESCRIPTION
    Stops and starts the Apache HTTP Server service for IsotoneStack
.PARAMETER AlwaysLog
    Forces logging even when there are no errors
.EXAMPLE
    .\Restart-Apache.ps1
    .\Restart-Apache.ps1 -AlwaysLog
#>

[CmdletBinding()]
param(
    [switch]$AlwaysLog
)

# Script configuration
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Get isotone root path (parent of scripts directory)
$IsotoneRoot = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $IsotoneRoot "logs\isotone"

# Settings file path
$SettingsFile = Join-Path $IsotoneRoot "config\isotone-settings.json"

# Load settings
$Settings = @{
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

if (Test-Path $SettingsFile) {
    try {
        $LoadedSettings = Get-Content $SettingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        foreach ($key in $LoadedSettings.PSObject.Properties.Name) {
            if ($LoadedSettings.$key -is [PSCustomObject]) {
                foreach ($subkey in $LoadedSettings.$key.PSObject.Properties.Name) {
                    $Settings[$key][$subkey] = $LoadedSettings.$key.$subkey
                }
            } else {
                $Settings[$key] = $LoadedSettings.$key
            }
        }
    } catch {
        Write-Warning "Failed to load settings from $SettingsFile. Using defaults."
    }
}

# Override verbose if specified in command line
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $Settings.logging.verbose = $true
}

# Create logs directory if it doesn't exist
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Initialize log file with date
$LogDate = Get-Date -Format "yyyyMMdd"
$LogFile = Join-Path $LogDir "Restart-Apache_$LogDate.log"

# Function to write log messages
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    # Write to file if enabled
    if ($Settings.logging.logToFile) {
        # Check log file size and rotate if needed
        if (Test-Path $LogFile) {
            $FileInfo = Get-Item $LogFile
            if ($FileInfo.Length -gt ($Settings.logging.maxLogSizeMB * 1MB)) {
                $ArchiveFile = $LogFile -replace '\.log$', "_$(Get-Date -Format 'HHmmss').log"
                Move-Item $LogFile $ArchiveFile -Force
                if (!$Settings.logging.archiveOldLogs) {
                    Remove-Item $ArchiveFile -Force
                }
            }
        }
        Add-Content -Path $LogFile -Value $LogEntry
    }
    
    # Write to console based on settings
    if ($Settings.logging.logToConsole) {
        $ShowInConsole = $Settings.logging.verbose -or 
                        $Level -in $Settings.logging.consoleLogLevels -or
                        $AlwaysLog
        
        if ($ShowInConsole) {
            switch ($Level) {
                "ERROR" { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO" { Write-Host $Message -ForegroundColor Cyan }
                "DEBUG" { Write-Host $Message -ForegroundColor Gray }
                default { Write-Host $Message }
            }
        }
    }
}

# Function to clean old logs
function Remove-OldLogs {
    if ($Settings.logging.cleanupEnabled -and $Settings.logging.maxLogAgeDays -gt 0) {
        $CutoffDate = (Get-Date).AddDays(-$Settings.logging.maxLogAgeDays)
        Get-ChildItem $LogDir -Filter "Restart-Apache_*.log" | 
            Where-Object { $_.LastWriteTime -lt $CutoffDate } | 
            Remove-Item -Force
    }
}

# Main script
try {
    Write-Host ""
    Write-Host "=== Restarting IsotoneStack Apache Service ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Log "Starting Apache restart process" "INFO"
    
    # Check if running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "This script requires Administrator privileges" "ERROR"
        throw "Please run this script as Administrator"
    }
    Write-Log "Running with Administrator privileges" "DEBUG"
    
    # Check if Apache service exists
    $serviceName = "IsotoneApache"
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    
    if (!$service) {
        Write-Log "Apache service '$serviceName' not found. Please run Register-Services.ps1 first." "ERROR"
        throw "Service not found"
    }
    
    Write-Log "Found Apache service: $serviceName" "DEBUG"
    
    # Stop Apache if running
    if ($service.Status -eq 'Running') {
        Write-Host "Stopping Apache..." -ForegroundColor Yellow
        Write-Log "Stopping Apache service" "INFO"
        
        try {
            Stop-Service -Name $serviceName -Force
            Start-Sleep -Seconds 2
            
            # Wait for service to stop
            $timeout = 30
            $elapsed = 0
            while ((Get-Service -Name $serviceName).Status -ne 'Stopped' -and $elapsed -lt $timeout) {
                Start-Sleep -Seconds 1
                $elapsed++
            }
            
            if ($elapsed -ge $timeout) {
                Write-Log "Timeout waiting for Apache to stop" "WARNING"
            } else {
                Write-Log "Apache stopped successfully" "SUCCESS"
            }
        } catch {
            Write-Log "Failed to stop Apache: $_" "ERROR"
            throw
        }
    } else {
        Write-Log "Apache was not running" "INFO"
    }
    
    # Start Apache
    Write-Host "Starting Apache..." -ForegroundColor Yellow
    Write-Log "Starting Apache service" "INFO"
    
    try {
        Start-Service -Name $serviceName
        Start-Sleep -Seconds 2
        
        # Wait for service to start
        $timeout = 30
        $elapsed = 0
        while ((Get-Service -Name $serviceName).Status -ne 'Running' -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 1
            $elapsed++
        }
        
        if ($elapsed -ge $timeout) {
            Write-Log "Timeout waiting for Apache to start" "ERROR"
            throw "Apache failed to start within timeout period"
        }
        
        # Verify service is running
        $service = Get-Service -Name $serviceName
        if ($service.Status -eq 'Running') {
            Write-Host ""
            Write-Host "[OK] Apache restarted successfully!" -ForegroundColor Green
            Write-Log "Apache restarted successfully" "SUCCESS"
            
            # Show URLs
            Write-Host ""
            Write-Host "Apache is now available at:" -ForegroundColor Cyan
            Write-Host "  - http://localhost" -ForegroundColor White
            Write-Host "  - http://localhost/default/" -ForegroundColor White
            Write-Host "  - http://localhost/default/control/" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Log "Apache service is not running after start attempt" "ERROR"
            throw "Failed to start Apache"
        }
    } catch {
        Write-Log "Failed to start Apache: $_" "ERROR"
        throw
    }
    
    # Clean old logs
    Remove-OldLogs
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to restart Apache: $_" -ForegroundColor Red
    Write-Host ""
    Write-Log "Script failed: $_" "ERROR"
    exit 1
} finally {
    if ($AlwaysLog) {
        Write-Host ""
        Write-Host "Log file: $LogFile" -ForegroundColor Gray
    }
}