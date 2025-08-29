# Unregister-Services.ps1
# Unregisters Apache and MariaDB Windows services for IsotoneStack
# Only removes service registrations - does not delete any files or data
# Requires Administrator privileges

param(
    [switch]$Force      # Force stop and removal even if services are running
)

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logsPath "$scriptName`_$timestamp.log"

# Service names
$apacheServiceName = "IsotoneApache"
$mariadbServiceName = "IsotoneMariaDB"

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
            default   { Write-Host $Message }
        }
    }
}

# Function to check if a service exists
function Test-ServiceExists {
    param([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    return $null -ne $service
}

# Function to stop a service
function Stop-ServiceSafe {
    param([string]$ServiceName)
    
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
    Write-Log "========================================" "INFO"
    Write-Log "IsotoneStack Service Unregistration Started" "INFO"
    Write-Log "Installation Directory: $isotonePath" "INFO"
    Write-Log "Parameters: Force=$Force" "INFO"
    Write-Log "========================================" "INFO"
    
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
    Write-Log "========================================" "INFO"
    Write-Log "Service unregistration completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    Write-Log "========================================" "INFO"
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Service unregistration failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}