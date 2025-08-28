# _Template.ps1
# Template for IsotoneStack PowerShell scripts
# Copy this file and rename for new scripts

param(
    # Add parameters here
    [switch]$Force,
    [switch]$Verbose
)

#Requires -Version 5.1

# Get script locations using portable paths (no hardcoded paths)
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$pwshPath = Join-Path $isotonePath "pwsh"
$pwshExe = Join-Path $pwshPath "pwsh.exe"
$logsPath = Join-Path $isotonePath "logs\isotone"

# Define common paths
$paths = @{
    Root      = $isotonePath
    Scripts   = $scriptPath
    Pwsh      = $pwshPath
    Apache    = Join-Path $isotonePath "apache24"
    PHP       = Join-Path $isotonePath "php"
    MariaDB   = Join-Path $isotonePath "mariadb"
    WWW       = Join-Path $isotonePath "www"
    Config    = Join-Path $isotonePath "config"
    Bin       = Join-Path $isotonePath "bin"
    Backups   = Join-Path $isotonePath "backups"
    Logs      = Join-Path $isotonePath "logs"
    LogsIsotone = $logsPath
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logsPath "$scriptName`_$timestamp.log"

# Helper function to check admin privileges
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Logging function - writes to both console and log file
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

# Main script logic
try {
    # Start logging
    Write-Log "========================================" "INFO"
    Write-Log "$scriptName Started" "INFO"
    Write-Log "Script: $scriptName" "INFO"
    Write-Log "Installation Directory: $isotonePath" "INFO"
    Write-Log "Parameters: Force=$Force, Verbose=$Verbose" "INFO"
    Write-Log "========================================" "INFO"
    
    Write-Host ""
    Write-Log "=== Script Name Here ===" "MAGENTA"
    Write-Log "IsotoneStack Path: $isotonePath" "INFO"
    Write-Host ""
    
    # Check if running as admin (if needed)
    # if (-not (Test-Administrator)) {
    #     Write-Log "This script requires Administrator privileges" "ERROR"
    #     Write-Log "Please run this script as Administrator" "ERROR"
    #     exit 1
    # }
    
    # Your script logic here
    Write-Log "Performing task..." "INFO"
    
    # Example of step logging
    # Write-Log "[1/3] First step..." "YELLOW"
    # Write-Log "  Processing..." "DEBUG"
    # Write-Log "  [OK] First step complete" "SUCCESS"
    
    # Summary
    Write-Host ""
    Write-Log "========================================" "INFO"
    Write-Log "Script completed successfully" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    Write-Log "========================================" "INFO"
}
catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Script failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}