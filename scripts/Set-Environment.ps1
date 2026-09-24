# Set-Environment.ps1
# Sets PATH environment variables for IsotoneStack components
# Adds PHP, MariaDB, Apache, and utility tools to the session or user PATH

param(
    [switch]$Permanent,       # Also set User environment variable (persists across sessions)
    [string]$PHPVersion,      # Specify PHP version (e.g., "8.4.15"), defaults to latest
    [switch]$Verbose
)

#Requires -Version 5.1

# Get script locations using portable paths (no hardcoded paths)
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$pwshPath = Join-Path $isotonePath "pwsh"
$logsPath = Join-Path $isotonePath "logs\isotone"

# Define component paths
$paths = @{
    Root     = $isotonePath
    Scripts  = $scriptPath
    Pwsh     = $pwshPath
    Apache   = Join-Path $isotonePath "apache24"
    PHP      = Join-Path $isotonePath "php"
    MariaDB  = Join-Path $isotonePath "mariadb"
    Bin      = Join-Path $isotonePath "bin"
    Composer = Join-Path $isotonePath "composer"
    Python   = Join-Path $isotonePath "python"
}

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel  = "INFO"
        maxLogSizeMB     = 10
        maxLogAgeDays    = 30
        verbose          = $false
        cleanupEnabled   = $true
        logToFile        = $true
        logToConsole     = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs   = $true
    }
    php     = @{
        defaultVersion = ""  # Empty means auto-detect latest
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
        if ($loadedSettings.php -and $loadedSettings.php.defaultVersion) {
            $settings.php.defaultVersion = $loadedSettings.php.defaultVersion
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

if ($Verbose) {
    $logLevel = "DEBUG"
}
elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true
}
else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if too large
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
        Remove-Item -Force
    }
}

# Log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

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
                "ERROR" { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO" { Write-Host $Message -ForegroundColor White }
                "DEBUG" { Write-Host $Message -ForegroundColor Gray }
                "CYAN" { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW" { Write-Host $Message -ForegroundColor Yellow }
                default { Write-Host $Message }
            }
        }
    }
}

# Function to detect active PHP version from Apache httpd.conf
function Get-ActivePHPVersion {
    $httpdConf = Join-Path $paths.Apache "conf\httpd.conf"
    
    if (Test-Path $httpdConf) {
        try {
            $content = Get-Content -Path $httpdConf -Raw
            # Match LoadModule php_module "...php/VERSION/php8apache2_4.dll"
            if ($content -match 'LoadModule\s+php_module\s+"[^"]*[/\\]php[/\\](\d+\.\d+\.\d+)[/\\]php8apache2_4\.dll"') {
                return $matches[1]
            }
            # Also try PHPIniDir pattern
            if ($content -match 'PHPIniDir\s+"[^"]*[/\\]php[/\\](\d+\.\d+\.\d+)"') {
                return $matches[1]
            }
        }
        catch {
            Write-Log "  [WARNING] Could not parse httpd.conf for PHP version" "WARNING"
        }
    }
    
    return $null
}

# Function to find PHP version path
function Get-PHPVersionPath {
    param([string]$RequestedVersion)
    
    $phpBase = $paths.PHP
    
    # Get available PHP versions
    $versions = Get-ChildItem -Path $phpBase -Directory -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
    Sort-Object { [Version]$_.Name } -Descending
    
    if ($versions.Count -eq 0) {
        Write-Log "[WARNING] No PHP versions found in $phpBase" "WARNING"
        return $null
    }
    
    # Priority 1: Use explicitly requested version
    if ($RequestedVersion) {
        $match = $versions | Where-Object { $_.Name -eq $RequestedVersion }
        if ($match) {
            return $match.FullName
        }
        
        # Try partial match (e.g., "8.4" matches "8.4.15")
        $match = $versions | Where-Object { $_.Name -like "$RequestedVersion*" } | Select-Object -First 1
        if ($match) {
            return $match.FullName
        }
        
        Write-Log "[WARNING] PHP version $RequestedVersion not found" "WARNING"
    }
    
    # Priority 2: Use active version from Apache config (set by iso-control/Switch-PHPVersion)
    $activeVersion = Get-ActivePHPVersion
    if ($activeVersion) {
        $match = $versions | Where-Object { $_.Name -eq $activeVersion }
        if ($match) {
            Write-Log "  Using active PHP version from Apache config: $activeVersion" "DEBUG"
            return $match.FullName
        }
    }
    
    # Priority 3: Use configured default version from settings
    if ($settings.php.defaultVersion) {
        $match = $versions | Where-Object { $_.Name -eq $settings.php.defaultVersion }
        if ($match) {
            return $match.FullName
        }
    }
    
    # Priority 4: Fall back to latest
    Write-Log "  Defaulting to latest PHP version" "DEBUG"
    return $versions[0].FullName
}

# Function to add path to environment
function Add-ToPath {
    param(
        [string]$NewPath,
        [string]$Target = "Process"  # Process, User, or Machine
    )
    
    if (-not (Test-Path $NewPath)) {
        return $false
    }
    
    # Get current PATH
    if ($Target -eq "User") {
        # Read directly from registry to avoid issues
        $regPath = "HKCU:\Environment"
        $currentPath = (Get-ItemProperty -Path $regPath -Name PATH -ErrorAction SilentlyContinue).PATH
        if (-not $currentPath) { $currentPath = "" }
    }
    else {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", $Target)
        if (-not $currentPath) { $currentPath = "" }
    }
    
    # Check if already in PATH (case-insensitive)
    $pathParts = $currentPath -split ';' | Where-Object { $_ -ne '' }
    $normalizedNew = $NewPath.TrimEnd('\').ToLower()
    $alreadyExists = $pathParts | Where-Object { $_.TrimEnd('\').ToLower() -eq $normalizedNew }
    
    if ($alreadyExists) {
        Write-Log "  Already in PATH: $NewPath" "DEBUG"
        return $true
    }
    
    # Add to beginning of PATH
    $newPathValue = "$NewPath;$currentPath"
    
    if ($Target -eq "User") {
        # Write directly to registry (faster, no WM_SETTINGCHANGE broadcast that can hang)
        Set-ItemProperty -Path "HKCU:\Environment" -Name PATH -Value $newPathValue -Type ExpandString
    }
    else {
        [Environment]::SetEnvironmentVariable("PATH", $newPathValue, $Target)
    }
    
    return $true
}

# Main script logic
try {
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    if ($Verbose) {
        Write-Log "Parameters: Permanent=$Permanent, PHPVersion=$PHPVersion, Verbose=$Verbose" "DEBUG"
    }
    
    Write-Host ""
    Write-Log "=== IsotoneStack Environment Setup ===" "MAGENTA"
    if ($Verbose) {
        Write-Log "IsotoneStack Path: $isotonePath" "DEBUG"
    }
    Write-Host ""
    
    $addedPaths = @()
    $mode = if ($Permanent) { "User" } else { "Process" }
    
    if ($Permanent) {
        Write-Log "Mode: Permanent (User environment)" "CYAN"
    }
    else {
        Write-Log "Mode: Session only (current process)" "CYAN"
    }
    Write-Host ""
    
    # =========================================================
    # Add PHP to PATH
    # =========================================================
    Write-Log "Configuring PHP..." "INFO"
    $phpPath = Get-PHPVersionPath -RequestedVersion $PHPVersion
    
    if ($phpPath -and (Test-Path $phpPath)) {
        $phpVersion = Split-Path -Leaf $phpPath
        if (Add-ToPath -NewPath $phpPath -Target $mode) {
            Write-Log "  [OK] PHP $phpVersion added to PATH" "SUCCESS"
            $addedPaths += $phpPath
        }
        
        # Also add to current session if setting permanently
        if ($Permanent) {
            Add-ToPath -NewPath $phpPath -Target "Process" | Out-Null
        }
    }
    else {
        Write-Log "  [WARNING] PHP not found, skipping" "WARNING"
    }
    
    # =========================================================
    # Add MariaDB to PATH
    # =========================================================
    Write-Log "Configuring MariaDB..." "INFO"
    $mariadbBin = Join-Path $paths.MariaDB "bin"
    
    if (Test-Path $mariadbBin) {
        if (Add-ToPath -NewPath $mariadbBin -Target $mode) {
            Write-Log "  [OK] MariaDB bin added to PATH" "SUCCESS"
            $addedPaths += $mariadbBin
        }
        
        if ($Permanent) {
            Add-ToPath -NewPath $mariadbBin -Target "Process" | Out-Null
        }
    }
    else {
        Write-Log "  [WARNING] MariaDB bin not found, skipping" "WARNING"
    }
    
    # =========================================================
    # Add Apache to PATH
    # =========================================================
    Write-Log "Configuring Apache..." "INFO"
    $apacheBin = Join-Path $paths.Apache "bin"
    
    if (Test-Path $apacheBin) {
        if (Add-ToPath -NewPath $apacheBin -Target $mode) {
            Write-Log "  [OK] Apache bin added to PATH" "SUCCESS"
            $addedPaths += $apacheBin
        }
        
        if ($Permanent) {
            Add-ToPath -NewPath $apacheBin -Target "Process" | Out-Null
        }
    }
    else {
        Write-Log "  [WARNING] Apache bin not found, skipping" "WARNING"
    }
    
    # =========================================================
    # Add utilities (bin folder) to PATH
    # =========================================================
    Write-Log "Configuring utilities..." "INFO"
    
    if (Test-Path $paths.Bin) {
        if (Add-ToPath -NewPath $paths.Bin -Target $mode) {
            Write-Log "  [OK] Utilities (7z, nssm, wget) added to PATH" "SUCCESS"
            $addedPaths += $paths.Bin
        }
        
        if ($Permanent) {
            Add-ToPath -NewPath $paths.Bin -Target "Process" | Out-Null
        }
    }
    
    # =========================================================
    # Add PowerShell to PATH
    # =========================================================
    Write-Log "Configuring PowerShell..." "INFO"
    
    if (Test-Path $paths.Pwsh) {
        if (Add-ToPath -NewPath $paths.Pwsh -Target $mode) {
            Write-Log "  [OK] Portable PowerShell added to PATH" "SUCCESS"
            $addedPaths += $paths.Pwsh
        }
        
        if ($Permanent) {
            Add-ToPath -NewPath $paths.Pwsh -Target "Process" | Out-Null
        }
    }
    
    # =========================================================
    # Add Composer to PATH (if exists)
    # =========================================================
    $composerExe = Join-Path $paths.Composer "composer.phar"
    if (Test-Path $composerExe) {
        Write-Log "Configuring Composer..." "INFO"
        if (Add-ToPath -NewPath $paths.Composer -Target $mode) {
            Write-Log "  [OK] Composer added to PATH" "SUCCESS"
            $addedPaths += $paths.Composer
        }
        
        if ($Permanent) {
            Add-ToPath -NewPath $paths.Composer -Target "Process" | Out-Null
        }
    }
    
    # =========================================================
    # Add Python to PATH (if exists)
    # =========================================================
    $pythonExe = Join-Path $paths.Python "python.exe"
    if (Test-Path $pythonExe) {
        Write-Log "Configuring Python..." "INFO"
        if (Add-ToPath -NewPath $paths.Python -Target $mode) {
            Write-Log "  [OK] Python added to PATH" "SUCCESS"
            $addedPaths += $paths.Python
        }
        
        if ($Permanent) {
            Add-ToPath -NewPath $paths.Python -Target "Process" | Out-Null
        }
    }
    
    # =========================================================
    # Summary
    # =========================================================
    Write-Host ""
    Write-Log "============================================" "CYAN"
    Write-Log "    Environment Setup Summary" "CYAN"
    Write-Log "============================================" "CYAN"
    Write-Host ""
    
    if ($addedPaths.Count -gt 0) {
        Write-Log "[OK] Added $($addedPaths.Count) paths to $mode PATH:" "SUCCESS"
        foreach ($p in $addedPaths) {
            Write-Log "  - $p" "INFO"
        }
        
        Write-Host ""
        
        if ($Permanent) {
            Write-Log "Changes are permanent and will persist across sessions." "INFO"
            Write-Log "Open a new terminal to use the updated PATH." "INFO"
        }
        else {
            Write-Log "Changes apply to this session only." "INFO"
            Write-Log "Use -Permanent to make changes persist." "INFO"
        }
    }
    else {
        Write-Log "[WARNING] No paths were added to PATH" "WARNING"
    }
    
    # Test commands
    Write-Host ""
    Write-Log "Quick verification:" "CYAN"
    
    # Test PHP
    $phpTest = Get-Command php -ErrorAction SilentlyContinue
    if ($phpTest) {
        $phpVer = & php -r "echo PHP_VERSION;" 2>$null
        Write-Log "  [OK] php: $phpVer" "SUCCESS"
    }
    else {
        Write-Log "  [--] php: not available" "DEBUG"
    }
    
    # Test MySQL/MariaDB
    $mysqlTest = Get-Command mysql -ErrorAction SilentlyContinue
    if ($mysqlTest) {
        Write-Log "  [OK] mysql: available" "SUCCESS"
    }
    else {
        Write-Log "  [--] mysql: not available" "DEBUG"
    }
    
    Write-Host ""
    Write-Log "Environment setup completed successfully" "SUCCESS" -AlwaysLog
    if ($Verbose) {
        Write-Log "Log file: $logFile" "DEBUG"
    }
}
catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Environment setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
finally {
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
        Remove-Item -Force -ErrorAction SilentlyContinue
    }
}
