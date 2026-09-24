# Switch-MariaDBVersion.ps1
# Switches the active MariaDB version by updating the bin symlink

param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [switch]$NoRestart
)

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

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    
    # Also write to console
    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        default { Write-Host $Message }
    }
}

try {
    Write-Log "========================================" "INFO"
    Write-Log "MariaDB Version Switch Started" "INFO"
    Write-Log "Target Version: $Version" "INFO"
    Write-Log "========================================" "INFO"
    Write-Host ""

    # Paths
    $mariadbPath = Join-Path $isotonePath "mariadb"
    $versionPath = Join-Path $mariadbPath $Version
    $binSymlink = Join-Path $mariadbPath "bin"

    # Verify MariaDB version exists
    if (!(Test-Path $versionPath)) {
        Write-Log "[ERROR] MariaDB version $Version not found at: $versionPath" "ERROR"
        Write-Host ""
        Write-Log "Available versions:" "INFO"
        Get-ChildItem -Path $mariadbPath -Directory | Where-Object { 
            $_.Name -match '^\d+\.\d+\.\d+$' 
        } | ForEach-Object {
            Write-Log "  - $($_.Name)" "INFO"
        }
        exit 1
    }

    # Verify bin folder exists in version
    $versionBinPath = Join-Path $versionPath "bin"
    if (!(Test-Path $versionBinPath)) {
        Write-Log "[ERROR] bin folder not found in $Version at: $versionBinPath" "ERROR"
        exit 1
    }

    # Verify critical executables
    $mysqldExe = Join-Path $versionBinPath "mysqld.exe"
    $mysqlExe = Join-Path $versionBinPath "mysql.exe"

    if (!(Test-Path $mysqldExe)) {
        Write-Log "[ERROR] mysqld.exe not found in $Version" "ERROR"
        exit 1
    }

    if (!(Test-Path $mysqlExe)) {
        Write-Log "[ERROR] mysql.exe not found in $Version" "ERROR"
        exit 1
    }

    Write-Log "[OK] MariaDB $Version files verified" "SUCCESS"

    # Stop MariaDB service if running
    Write-Host ""
    Write-Log "Checking MariaDB service..." "INFO"
    
    $mariadbService = Get-Service -Name "IsotoneMariaDB*" -ErrorAction SilentlyContinue
    $wasRunning = $false
    
    if ($mariadbService) {
        $serviceName = $mariadbService.Name
        Write-Log "Found MariaDB service: $serviceName" "INFO"
        
        if ($mariadbService.Status -eq "Running") {
            $wasRunning = $true
            Write-Log "Stopping MariaDB..." "INFO"
            Stop-Service -Name $serviceName -Force
            Start-Sleep -Seconds 3
            Write-Log "[OK] MariaDB stopped" "SUCCESS"
        }
        else {
            Write-Log "[INFO] MariaDB is not running" "INFO"
        }
    }
    else {
        Write-Log "[INFO] MariaDB service not found" "INFO"
    }

    # Remove existing bin symlink or folder
    Write-Host ""
    Write-Log "Updating bin symlink..." "INFO"
    
    if (Test-Path $binSymlink) {
        $item = Get-Item $binSymlink -Force
        if ($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") {
            Write-Log "Removing existing symlink..." "INFO"
            Remove-Item $binSymlink -Force
        }
        else {
            Write-Log "[ERROR] $binSymlink exists but is not a symlink. Please remove manually." "ERROR"
            exit 1
        }
    }

    # Create new symlink (requires admin)
    try {
        New-Item -ItemType Junction -Path $binSymlink -Target $versionBinPath -Force | Out-Null
        Write-Log "[OK] Created bin junction -> $Version\bin" "SUCCESS"
    }
    catch {
        Write-Log "[ERROR] Failed to create junction: $_" "ERROR"
        Write-Log "Try running as Administrator" "WARNING"
        exit 1
    }

    # Verify symlink works
    $testExe = Join-Path $binSymlink "mysql.exe"
    if (!(Test-Path $testExe)) {
        Write-Log "[ERROR] Symlink verification failed - mysql.exe not accessible" "ERROR"
        exit 1
    }
    Write-Log "[OK] Symlink verified" "SUCCESS"

    # Update root my.ini to reference correct data directory
    Write-Host ""
    Write-Log "Checking data directory configuration..." "INFO"
    
    $majorMinor = ($Version -split '\.')[0..1] -join '.'
    $dataPath = Join-Path $mariadbPath "data\$majorMinor"
    
    if (Test-Path $dataPath) {
        Write-Log "[OK] Data directory exists: data\$majorMinor" "SUCCESS"
    }
    else {
        Write-Log "[WARNING] Data directory not found: data\$majorMinor" "WARNING"
        Write-Log "You may need to initialize the database for this version" "WARNING"
    }

    # Restart MariaDB if it was running and not skipped
    if (-not $NoRestart -and $wasRunning -and $mariadbService) {
        Write-Host ""
        Write-Log "Starting MariaDB..." "INFO"
        Start-Service -Name $serviceName
        Start-Sleep -Seconds 3
        
        $mariadbService = Get-Service -Name $serviceName
        if ($mariadbService.Status -eq "Running") {
            Write-Log "[OK] MariaDB started with version $Version" "SUCCESS"
        }
        else {
            Write-Log "[ERROR] MariaDB failed to start" "ERROR"
            Write-Log "Check logs at: $mariadbPath\data\$majorMinor\*.err" "INFO"
        }
    }
    elseif ($NoRestart -and $wasRunning) {
        Write-Log "[INFO] Restart skipped - please restart MariaDB manually" "INFO"
    }

    Write-Host ""
    Write-Log "========================================" "INFO"
    Write-Log "MariaDB Version Switch Complete!" "SUCCESS"
    Write-Log "Active Version: MariaDB $Version" "SUCCESS"
    Write-Log "Bin symlink: $binSymlink -> $versionBinPath" "INFO"
    Write-Log "Log file: $logFile" "INFO"
    Write-Log "========================================" "INFO"
    
}
catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
