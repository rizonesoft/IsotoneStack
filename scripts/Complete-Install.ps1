# Complete-Install.ps1
# Master installation script for IsotoneStack
# Runs all configuration and setup scripts in the correct order

param(
    [switch]$SkipServices,     # Skip service registration
    [switch]$SkipAutoStart,    # Skip auto-start configuration
    [switch]$Force             # Force reinstall even if already configured
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file
$scriptName = "Complete-Install"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logsPath "$scriptName`_$timestamp.log"

# Logging function
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
            "BLUE"    { Write-Host $Message -ForegroundColor Blue }
            default   { Write-Host $Message }
        }
    }
}

# Function to run a script and check result
function Invoke-InstallScript {
    param(
        [string]$ScriptName,
        [string]$Description,
        [string[]]$Arguments = @(),
        [switch]$Optional
    )
    
    $scriptFile = Join-Path $scriptPath "$ScriptName.ps1"
    
    if (!(Test-Path $scriptFile)) {
        if ($Optional) {
            Write-Log "  [SKIP] $Description (script not found)" "YELLOW"
            return $true
        } else {
            Write-Log "  [ERROR] Script not found: $scriptFile" "ERROR"
            return $false
        }
    }
    
    Write-Log "  Running: $Description" "INFO"
    
    try {
        $result = & $scriptFile @Arguments
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Log "  [OK] $Description completed successfully" "SUCCESS"
            return $true
        } else {
            Write-Log "  [ERROR] $Description failed with exit code: $LASTEXITCODE" "ERROR"
            return $false
        }
    } catch {
        Write-Log "  [ERROR] $Description failed: $_" "ERROR"
        return $false
    }
}

# Main installation process
try {
    Clear-Host
    
    # Display banner
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "                   IsotoneStack Installation                    " -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "========================================" "INFO"
    Write-Log "IsotoneStack Master Installation Started" "INFO"
    Write-Log "Installation Directory: $isotonePath" "INFO"
    Write-Log "========================================" "INFO"
    Write-Host ""
    
    # Check for Administrator privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (!$isAdmin) {
        Write-Log "[WARNING] Not running as Administrator" "WARNING"
        Write-Log "Some operations may fail without Administrator privileges" "WARNING"
        Write-Host ""
        Write-Host "Press any key to continue or Ctrl+C to abort..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host ""
    } else {
        Write-Log "[OK] Running with Administrator privileges" "SUCCESS"
    }
    
    # Installation steps
    $steps = @(
        @{
            Name = "Configure-IsotoneStack"
            Description = "Configuring IsotoneStack components"
            Critical = $true
        },
        @{
            Name = "Register-Services"
            Description = "Registering Windows services"
            Critical = $true
            Skip = $SkipServices
        },
        @{
            Name = "Start-Services"
            Description = "Starting IsotoneStack services"
            Critical = $false
        },
        @{
            Name = "Setup-phpMyAdmin-Storage"
            Description = "Setting up phpMyAdmin configuration storage"
            Critical = $false
        }
    )
    
    # Track success
    $allSuccess = $true
    $failedSteps = @()
    
    Write-Host ""
    Write-Log "================================================================" "BLUE"
    Write-Log "                    Installation Steps                          " "BLUE"
    Write-Log "================================================================" "BLUE"
    Write-Host ""
    
    $stepNumber = 1
    $totalSteps = ($steps | Where-Object { -not $_.Skip }).Count
    
    foreach ($step in $steps) {
        if ($step.Skip) {
            Write-Log "[SKIP] $($step.Description) (command-line option)" "YELLOW"
            continue
        }
        
        Write-Host ""
        Write-Log "[$stepNumber/$totalSteps] $($step.Description)..." "CYAN"
        
        $args = @()
        if ($Force -and $step.Name -eq "Configure-IsotoneStack") {
            $args += "-Force"
        }
        
        $success = Invoke-InstallScript `
            -ScriptName $step.Name `
            -Description $step.Description `
            -Arguments $args `
            -Optional:$step.Optional
        
        if (!$success) {
            if ($step.Critical) {
                $allSuccess = $false
                $failedSteps += $step.Description
                Write-Log "  [CRITICAL] This is a critical step. Installation cannot continue." "ERROR"
                break
            } else {
                Write-Log "  [WARNING] Non-critical step failed, continuing..." "WARNING"
                $failedSteps += "$($step.Description) (non-critical)"
            }
        }
        
        $stepNumber++
    }
    
    Write-Host ""
    Write-Host ""
    Write-Log "================================================================" "CYAN"
    Write-Log "                    Installation Summary                        " "CYAN"
    Write-Log "================================================================" "CYAN"
    Write-Host ""
    
    if ($allSuccess) {
        Write-Log "[SUCCESS] IsotoneStack installation completed successfully!" "SUCCESS"
        Write-Host ""
        
        # Check service status
        Write-Log "Service Status:" "INFO"
        $services = @("IsotoneApache", "IsotoneMariaDB")
        foreach ($serviceName in $services) {
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            if ($service) {
                $status = if ($service.Status -eq 'Running') { "[OK]" } else { "[Stopped]" }
                $color = if ($service.Status -eq 'Running') { "SUCCESS" } else { "YELLOW" }
                Write-Log "  $status $serviceName - $($service.Status)" $color
            }
        }
        
        Write-Host ""
        Write-Log "Access Points:" "INFO"
        Write-Log "  Web Root:      http://localhost/" "CYAN"
        Write-Log "  phpMyAdmin:    http://localhost/phpmyadmin/" "CYAN"
        Write-Log "  phpLiteAdmin:  http://localhost/phpliteadmin/" "CYAN"
        Write-Log "  SQLite:        http://localhost/sqlite/" "CYAN"
        Write-Log "  MariaDB:     localhost:3306" "CYAN"
        Write-Log "  SQLite DB:   C:\isotone\sqlite\" "CYAN"
        
        Write-Host ""
        Write-Log "Installation Paths:" "INFO"
        Write-Log "  Root:        $isotonePath" "DEBUG"
        Write-Log "  Web Files:   $isotonePath\www" "DEBUG"
        Write-Log "  Logs:        $isotonePath\logs" "DEBUG"
        Write-Log "  Config:      $isotonePath\config" "DEBUG"
        
        Write-Host ""
        Write-Log "To start services manually:" "INFO"
        Write-Log "  Start-IsotoneStack.bat" "DEBUG"
        Write-Host ""
        Write-Log "To stop services manually:" "INFO"
        Write-Log "  Stop-IsotoneStack.bat" "DEBUG"
        
    } else {
        Write-Log "[ERROR] Installation completed with errors" "ERROR"
        Write-Host ""
        
        if ($failedSteps.Count -gt 0) {
            Write-Log "Failed steps:" "ERROR"
            foreach ($failed in $failedSteps) {
                Write-Log "  - $failed" "ERROR"
            }
        }
        
        Write-Host ""
        Write-Log "Please check the log file for details:" "WARNING"
        Write-Log "  $logFile" "YELLOW"
        
        Write-Host ""
        Write-Log "You can try running the installation again with:" "INFO"
        Write-Log "  INSTALL.bat -Force" "DEBUG"
    }
    
    Write-Host ""
    Write-Log "================================================================" "INFO"
    Write-Log "Installation log saved to:" "INFO"
    Write-Log "$logFile" "DEBUG"
    Write-Log "================================================================" "INFO"
    Write-Host ""
    
    if (!$allSuccess) {
        exit 1
    }
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Installation failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}