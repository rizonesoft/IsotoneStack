# Switch-PHPVersion.ps1
# Switches the active PHP version and restarts Apache

param(
    [Parameter(Mandatory=$true)]
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
        "ERROR"   { Write-Host $Message -ForegroundColor Red }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        default   { Write-Host $Message }
    }
}

try {
    Write-Log "========================================" "INFO"
    Write-Log "PHP Version Switch Started" "INFO"
    Write-Log "Target Version: $Version" "INFO"
    Write-Log "========================================" "INFO"
    Write-Host ""

    # Verify PHP version exists
    $phpVersionPath = Join-Path $isotonePath "php\$Version"
    if (!(Test-Path $phpVersionPath)) {
        Write-Log "[ERROR] PHP version $Version not found at: $phpVersionPath" "ERROR"
        exit 1
    }

    # Verify required files exist
    $phpExe = Join-Path $phpVersionPath "php.exe"
    $phpDll = Join-Path $phpVersionPath "php8apache2_4.dll"
    $phpIni = Join-Path $phpVersionPath "php.ini"

    if (!(Test-Path $phpExe)) {
        Write-Log "[ERROR] php.exe not found in $Version" "ERROR"
        exit 1
    }

    if (!(Test-Path $phpDll)) {
        Write-Log "[ERROR] php8apache2_4.dll not found in $Version" "ERROR"
        exit 1
    }

    Write-Log "[OK] PHP $Version files verified" "SUCCESS"

    # Update Apache httpd.conf
    Write-Host ""
    Write-Log "Updating Apache configuration..." "INFO"
    
    $httpdConf = Join-Path $isotonePath "apache24\conf\httpd.conf"
    if (!(Test-Path $httpdConf)) {
        Write-Log "[ERROR] httpd.conf not found at: $httpdConf" "ERROR"
        exit 1
    }

    # Read httpd.conf
    $content = Get-Content -Path $httpdConf -Raw
    $installPathFS = $isotonePath.Replace('\', '/')

    # Update PHP module path, dependency LoadFile, and PHPIniDir
    $phpLoadFileLine = "LoadFile `"$installPathFS/php/$Version/libsodium.dll`""
    $phpModuleLine = "LoadModule php_module `"$installPathFS/php/$Version/php8apache2_4.dll`""
    $phpIniDirLine = "PHPIniDir `"$installPathFS/php/$Version`""

    # Replace existing PHP configuration
    if ($content -match 'LoadFile "[^"]*/libsodium\.dll"') {
        $content = $content -replace 'LoadFile "[^"]*/libsodium\.dll"', $phpLoadFileLine
    } elseif ($content -match 'LoadModule php_module') {
        $content = $content -replace '(LoadModule php_module "[^"]*php8apache2_4\.dll")', "$phpLoadFileLine`r`n$1"
    }
    $content = $content -replace 'LoadModule php_module ".*?php8apache2_4\.dll"', $phpModuleLine
    $content = $content -replace 'PHPIniDir ".*?"', $phpIniDirLine

    # If the lines don't exist, add them before the Include directives
    if ($content -notmatch "LoadModule php_module") {
        Write-Log "[WARNING] LoadModule php_module not found - adding it" "WARNING"
        $insertPoint = $content.IndexOf("Include conf/extra/")
        if ($insertPoint -gt 0) {
            $beforeInclude = $content.Substring(0, $insertPoint)
            $afterInclude = $content.Substring($insertPoint)
            $phpConfig = @"

# PHP $Version Configuration
$phpLoadFileLine
$phpModuleLine
AddHandler application/x-httpd-php .php
$phpIniDirLine
DirectoryIndex index.php index.html

"@
            $content = $beforeInclude + $phpConfig + $afterInclude
        }
    }

    # Write updated configuration
    Set-Content -Path $httpdConf -Value $content -Encoding UTF8
    Write-Log "[OK] Apache configuration updated to PHP $Version" "SUCCESS"

    # Check if php.ini exists, if not create from template
    if (!(Test-Path $phpIni)) {
        Write-Log "[WARNING] php.ini not found, creating from template..." "WARNING"
        $phpIniDev = Join-Path $phpVersionPath "php.ini-development"
        if (Test-Path $phpIniDev) {
            Copy-Item -Path $phpIniDev -Destination $phpIni -Force
            Write-Log "[OK] php.ini created from php.ini-development" "SUCCESS"
        }
    }

    # Restart Apache if not skipped
    if (-not $NoRestart) {
        Write-Host ""
        Write-Log "Checking Apache service..." "INFO"
        
        # Check for Apache service
        $apacheService = Get-Service -Name "IsotoneApache*" -ErrorAction SilentlyContinue
        
        if ($apacheService) {
            $serviceName = $apacheService.Name
            Write-Log "Found Apache service: $serviceName" "INFO"
            
            if ($apacheService.Status -eq "Running") {
                Write-Log "Stopping Apache..." "INFO"
                Stop-Service -Name $serviceName -Force
                Start-Sleep -Seconds 2
                Write-Log "[OK] Apache stopped" "SUCCESS"
                
                Write-Log "Starting Apache..." "INFO"
                Start-Service -Name $serviceName
                Start-Sleep -Seconds 2
                Write-Log "[OK] Apache started with PHP $Version" "SUCCESS"
            } else {
                Write-Log "[INFO] Apache is not running - no restart needed" "INFO"
            }
        } else {
            Write-Log "[WARNING] Apache service not found - please restart manually" "WARNING"
            Write-Log "You can start Apache using Start-Services.ps1" "INFO"
        }
    } else {
        Write-Log "[INFO] Restart skipped - please restart Apache manually" "INFO"
    }

    Write-Host ""
    Write-Log "========================================" "INFO"
    Write-Log "PHP Version Switch Complete!" "SUCCESS"
    Write-Log "Active Version: PHP $Version" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    Write-Log "========================================" "INFO"
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
