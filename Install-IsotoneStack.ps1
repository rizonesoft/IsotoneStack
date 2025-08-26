# IsotoneStack Installation Script
# Installs Apache, PHP, MariaDB, and phpMyAdmin with latest stable versions
# Default installation path: C:\isotone

param(
    [string]$InstallPath = "C:\isotone",
    [switch]$SkipVCRedist = $false,
    [switch]$Force = $false
)

# Run as Administrator check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run as Administrator." -ForegroundColor Red
    exit 1
}

$ErrorActionPreference = "Stop"
$ProgressPreference = 'Continue'

# Define versions and URLs (Latest stable as of 2025)
$VERSIONS = @{
    Apache = @{
        Version = "2.4.62"
        Url = "https://www.apachelounge.com/download/VS17/binaries/httpd-2.4.62-241007-win64-VS17.zip"
        Folder = "apache24"
    }
    PHP = @{
        Version = "8.3.15"
        Url = "https://windows.php.net/downloads/releases/php-8.3.15-Win32-vs16-x64.zip"
        Folder = "php"
    }
    MariaDB = @{
        Version = "11.4.4"
        Url = "https://archive.mariadb.org/mariadb-11.4.4/winx64-packages/mariadb-11.4.4-winx64.zip"
        Folder = "mariadb"
    }
    PhpMyAdmin = @{
        Version = "5.2.1"
        Url = "https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip"
        Folder = "phpmyadmin"
    }
    VCRedist = @{
        Url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
    }
}

# Create directory structure
function Initialize-DirectoryStructure {
    param([string]$BasePath)
    
    Write-Host "Creating directory structure..." -ForegroundColor Green
    
    $directories = @(
        $BasePath,
        "$BasePath\apache24",
        "$BasePath\php",
        "$BasePath\mariadb",
        "$BasePath\phpmyadmin",
        "$BasePath\control-panel",
        "$BasePath\logs",
        "$BasePath\logs\apache",
        "$BasePath\logs\php",
        "$BasePath\logs\mariadb",
        "$BasePath\tmp",
        "$BasePath\ssl",
        "$BasePath\backups",
        "$BasePath\config",
        "$BasePath\www",
        "$BasePath\www\default",
        "$BasePath\downloads"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "  Created: $dir"
        }
    }
}

# Check and install VC++ Redistributable
function Install-VCRedist {
    Write-Host "Checking for Visual C++ Redistributable..." -ForegroundColor Green
    
    $vcRedistInstalled = $false
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64"
    )
    
    foreach ($path in $registryPaths) {
        if (Test-Path $path) {
            $installed = Get-ItemProperty $path -ErrorAction SilentlyContinue
            if ($installed.Installed -eq 1) {
                $vcRedistInstalled = $true
                break
            }
        }
    }
    
    if (-not $vcRedistInstalled -and -not $SkipVCRedist) {
        Write-Host "  Downloading Visual C++ Redistributable..." -ForegroundColor Yellow
        $vcPath = "$InstallPath\downloads\vc_redist.x64.exe"
        Invoke-WebRequest -Uri $VERSIONS.VCRedist.Url -OutFile $vcPath -UseBasicParsing
        
        Write-Host "  Installing Visual C++ Redistributable..." -ForegroundColor Yellow
        Start-Process -FilePath $vcPath -ArgumentList "/quiet", "/norestart" -Wait
        Write-Host "  Visual C++ Redistributable installed successfully" -ForegroundColor Green
    } else {
        Write-Host "  Visual C++ Redistributable already installed or skipped" -ForegroundColor Green
    }
}

# Download and extract function
function Download-AndExtract {
    param(
        [string]$Url,
        [string]$DestinationPath,
        [string]$ComponentName
    )
    
    Write-Host "Downloading $ComponentName..." -ForegroundColor Green
    $downloadPath = "$InstallPath\downloads\$ComponentName.zip"
    
    try {
        # Download with progress
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $downloadPath -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        Write-Host "  Extracting $ComponentName..." -ForegroundColor Yellow
        
        # Extract using built-in Windows functionality
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, "$InstallPath\temp_extract")
        
        # Move to correct location
        $extractedItems = Get-ChildItem "$InstallPath\temp_extract" -Directory
        if ($extractedItems.Count -eq 1) {
            # Single root folder in archive
            Get-ChildItem "$InstallPath\temp_extract\$($extractedItems[0].Name)" | Move-Item -Destination $DestinationPath -Force
        } else {
            # Multiple items in root
            Get-ChildItem "$InstallPath\temp_extract" | Move-Item -Destination $DestinationPath -Force
        }
        
        # Cleanup
        Remove-Item "$InstallPath\temp_extract" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $downloadPath -Force
        
        Write-Host "  $ComponentName installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error installing $ComponentName: $_" -ForegroundColor Red
        throw
    }
}

# Install Apache
function Install-Apache {
    Write-Host "`nInstalling Apache ${VERSIONS.Apache.Version}..." -ForegroundColor Cyan
    
    $apachePath = "$InstallPath\apache24"
    if (Test-Path "$apachePath\bin\httpd.exe") {
        if (-not $Force) {
            Write-Host "  Apache already installed. Use -Force to reinstall." -ForegroundColor Yellow
            return
        }
        Stop-Service -Name "IsotoneApache" -ErrorAction SilentlyContinue
        & "$apachePath\bin\httpd.exe" -k uninstall -n "IsotoneApache" 2>$null
    }
    
    Download-AndExtract -Url $VERSIONS.Apache.Url -DestinationPath $apachePath -ComponentName "Apache"
    
    # Configure Apache
    Write-Host "  Configuring Apache..." -ForegroundColor Yellow
    $confFile = "$apachePath\conf\httpd.conf"
    $confContent = Get-Content $confFile -Raw
    
    # Update paths
    $confContent = $confContent -replace 'c:/Apache24', ($apachePath -replace '\\', '/')
    $confContent = $confContent -replace '#ServerName www.example.com:80', 'ServerName localhost:80'
    $confContent = $confContent -replace 'DocumentRoot ".*?"', "DocumentRoot `"$($InstallPath -replace '\\', '/')/www/default`""
    $confContent = $confContent -replace '<Directory "c:/Apache24/htdocs">', "<Directory `"$($InstallPath -replace '\\', '/')/www/default`">"
    
    # Enable PHP module (will be configured later)
    $phpConfig = @"

# PHP Configuration
LoadModule php_module "$($InstallPath -replace '\\', '/')/php/php8apache2_4.dll"
AddHandler application/x-httpd-php .php
PHPIniDir "$($InstallPath -replace '\\', '/')/php"
DirectoryIndex index.php index.html
"@
    
    $confContent += $phpConfig
    Set-Content -Path $confFile -Value $confContent -Force
    
    # Install as Windows Service
    Write-Host "  Installing Apache as Windows Service..." -ForegroundColor Yellow
    & "$apachePath\bin\httpd.exe" -k install -n "IsotoneApache"
}

# Install PHP
function Install-PHP {
    Write-Host "`nInstalling PHP ${VERSIONS.PHP.Version}..." -ForegroundColor Cyan
    
    $phpPath = "$InstallPath\php"
    if (Test-Path "$phpPath\php.exe") {
        if (-not $Force) {
            Write-Host "  PHP already installed. Use -Force to reinstall." -ForegroundColor Yellow
            return
        }
    }
    
    Download-AndExtract -Url $VERSIONS.PHP.Url -DestinationPath $phpPath -ComponentName "PHP"
    
    # Configure PHP
    Write-Host "  Configuring PHP..." -ForegroundColor Yellow
    $phpIniDev = "$phpPath\php.ini-development"
    $phpIni = "$phpPath\php.ini"
    
    if (Test-Path $phpIniDev) {
        Copy-Item $phpIniDev $phpIni -Force
    }
    
    $iniContent = Get-Content $phpIni -Raw
    
    # Update configuration
    $iniContent = $iniContent -replace ';extension_dir = "ext"', "extension_dir = `"$phpPath\ext`""
    $iniContent = $iniContent -replace ';extension=curl', 'extension=curl'
    $iniContent = $iniContent -replace ';extension=fileinfo', 'extension=fileinfo'
    $iniContent = $iniContent -replace ';extension=gd', 'extension=gd'
    $iniContent = $iniContent -replace ';extension=mbstring', 'extension=mbstring'
    $iniContent = $iniContent -replace ';extension=mysqli', 'extension=mysqli'
    $iniContent = $iniContent -replace ';extension=openssl', 'extension=openssl'
    $iniContent = $iniContent -replace ';extension=pdo_mysql', 'extension=pdo_mysql'
    $iniContent = $iniContent -replace ';extension=zip', 'extension=zip'
    
    # Set paths
    $iniContent = $iniContent -replace 'upload_tmp_dir =.*', "upload_tmp_dir = `"$InstallPath\tmp`""
    $iniContent = $iniContent -replace 'session.save_path =.*', "session.save_path = `"$InstallPath\tmp`""
    $iniContent = $iniContent -replace 'error_log =.*', "error_log = `"$InstallPath\logs\php\error.log`""
    
    Set-Content -Path $phpIni -Value $iniContent -Force
    
    # Add PHP to PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*$phpPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$phpPath", "Machine")
        Write-Host "  Added PHP to system PATH" -ForegroundColor Green
    }
}

# Install MariaDB
function Install-MariaDB {
    Write-Host "`nInstalling MariaDB ${VERSIONS.MariaDB.Version}..." -ForegroundColor Cyan
    
    $mariadbPath = "$InstallPath\mariadb"
    if (Test-Path "$mariadbPath\bin\mysqld.exe") {
        if (-not $Force) {
            Write-Host "  MariaDB already installed. Use -Force to reinstall." -ForegroundColor Yellow
            return
        }
        Stop-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
        & "$mariadbPath\bin\mysqld.exe" --remove "IsotoneMariaDB" 2>$null
    }
    
    Download-AndExtract -Url $VERSIONS.MariaDB.Url -DestinationPath $mariadbPath -ComponentName "MariaDB"
    
    # Initialize database
    Write-Host "  Initializing MariaDB database..." -ForegroundColor Yellow
    
    # Create my.ini configuration
    $myIniContent = @"
[mysqld]
datadir=$InstallPath/mariadb/data
port=3306
innodb_buffer_pool_size=256M
innodb_log_file_size=48M
max_connections=100
key_buffer_size=16M
log-error=$InstallPath/logs/mariadb/error.log
pid-file=$InstallPath/mariadb/data/mysqld.pid
socket=$InstallPath/tmp/mysql.sock
basedir=$InstallPath/mariadb

[client]
port=3306
socket=$InstallPath/tmp/mysql.sock

[mysql]
default-character-set=utf8mb4
"@
    Set-Content -Path "$mariadbPath\my.ini" -Value $myIniContent -Force
    
    # Initialize data directory
    & "$mariadbPath\bin\mysql_install_db.exe" --datadir="$mariadbPath\data" --service="IsotoneMariaDB" --password="isotone_admin"
    
    # Install as Windows Service
    Write-Host "  Installing MariaDB as Windows Service..." -ForegroundColor Yellow
    & "$mariadbPath\bin\mysqld.exe" --install "IsotoneMariaDB" --defaults-file="$mariadbPath\my.ini"
}

# Install phpMyAdmin
function Install-PhpMyAdmin {
    Write-Host "`nInstalling phpMyAdmin ${VERSIONS.PhpMyAdmin.Version}..." -ForegroundColor Cyan
    
    $pmaPath = "$InstallPath\phpmyadmin"
    if (Test-Path "$pmaPath\index.php") {
        if (-not $Force) {
            Write-Host "  phpMyAdmin already installed. Use -Force to reinstall." -ForegroundColor Yellow
            return
        }
    }
    
    Download-AndExtract -Url $VERSIONS.PhpMyAdmin.Url -DestinationPath $pmaPath -ComponentName "phpMyAdmin"
    
    # Configure phpMyAdmin
    Write-Host "  Configuring phpMyAdmin..." -ForegroundColor Yellow
    $configSample = "$pmaPath\config.sample.inc.php"
    $config = "$pmaPath\config.inc.php"
    
    if (Test-Path $configSample) {
        $configContent = Get-Content $configSample -Raw
        
        # Generate blowfish secret
        $blowfishSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
        $configContent = $configContent -replace "\['blowfish_secret'\] = ''", "['blowfish_secret'] = '$blowfishSecret'"
        
        # Set temp directory
        $configContent += "`n`$cfg['TempDir'] = '$InstallPath/tmp';"
        
        Set-Content -Path $config -Value $configContent -Force
    }
    
    # Create Apache alias configuration
    $aliasConf = @"
Alias /phpmyadmin "$($InstallPath -replace '\\', '/')/phpmyadmin"
<Directory "$($InstallPath -replace '\\', '/')/phpmyadmin">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Require all granted
</Directory>
"@
    Set-Content -Path "$InstallPath\apache24\conf\extra\phpmyadmin.conf" -Value $aliasConf -Force
    
    # Include in main Apache config
    $httpdConf = Get-Content "$InstallPath\apache24\conf\httpd.conf" -Raw
    if ($httpdConf -notlike "*phpmyadmin.conf*") {
        $httpdConf += "`nInclude conf/extra/phpmyadmin.conf"
        Set-Content -Path "$InstallPath\apache24\conf\httpd.conf" -Value $httpdConf -Force
    }
}

# Create control panel scripts
function Create-ControlPanel {
    Write-Host "`nCreating control panel scripts..." -ForegroundColor Cyan
    
    # Start script
    $startScript = @'
# IsotoneStack Start Script
Write-Host "Starting IsotoneStack services..." -ForegroundColor Green

$services = @("IsotoneApache", "IsotoneMariaDB")

foreach ($service in $services) {
    try {
        Start-Service -Name $service -ErrorAction Stop
        Write-Host "  Started: $service" -ForegroundColor Green
    } catch {
        Write-Host "  Failed to start: $service - $_" -ForegroundColor Red
    }
}

Write-Host "`nServices started. Access points:" -ForegroundColor Green
Write-Host "  Web Server: http://localhost" -ForegroundColor Cyan
Write-Host "  phpMyAdmin: http://localhost/phpmyadmin" -ForegroundColor Cyan
Write-Host "  MariaDB: localhost:3306" -ForegroundColor Cyan
'@
    Set-Content -Path "$InstallPath\control-panel\start.ps1" -Value $startScript -Force
    
    # Stop script
    $stopScript = @'
# IsotoneStack Stop Script
Write-Host "Stopping IsotoneStack services..." -ForegroundColor Yellow

$services = @("IsotoneApache", "IsotoneMariaDB")

foreach ($service in $services) {
    try {
        Stop-Service -Name $service -ErrorAction Stop
        Write-Host "  Stopped: $service" -ForegroundColor Green
    } catch {
        Write-Host "  Failed to stop: $service - $_" -ForegroundColor Red
    }
}
'@
    Set-Content -Path "$InstallPath\control-panel\stop.ps1" -Value $stopScript -Force
    
    # Restart script
    $restartScript = @'
# IsotoneStack Restart Script
Write-Host "Restarting IsotoneStack services..." -ForegroundColor Yellow

& "$PSScriptRoot\stop.ps1"
Start-Sleep -Seconds 2
& "$PSScriptRoot\start.ps1"
'@
    Set-Content -Path "$InstallPath\control-panel\restart.ps1" -Value $restartScript -Force
    
    # Status script
    $statusScript = @'
# IsotoneStack Status Script
Write-Host "IsotoneStack Service Status:" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

$services = @("IsotoneApache", "IsotoneMariaDB")

foreach ($service in $services) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc) {
        $status = $svc.Status
        $color = if ($status -eq "Running") { "Green" } else { "Red" }
        Write-Host "  $service : $status" -ForegroundColor $color
    } else {
        Write-Host "  $service : Not Installed" -ForegroundColor Red
    }
}

Write-Host "`nInstallation Info:" -ForegroundColor Cyan
Write-Host "  Install Path: C:\isotone" -ForegroundColor Gray
Write-Host "  Apache Version: 2.4.62" -ForegroundColor Gray
Write-Host "  PHP Version: 8.3.15" -ForegroundColor Gray
Write-Host "  MariaDB Version: 11.4.4" -ForegroundColor Gray
Write-Host "  phpMyAdmin Version: 5.2.1" -ForegroundColor Gray
'@
    Set-Content -Path "$InstallPath\control-panel\status.ps1" -Value $statusScript -Force
    
    # Uninstall script
    $uninstallScript = @'
# IsotoneStack Uninstall Script
param([switch]$RemoveData = $false)

Write-Host "Uninstalling IsotoneStack services..." -ForegroundColor Red

# Stop services
& "$PSScriptRoot\stop.ps1"

# Remove services
Write-Host "`nRemoving Windows services..." -ForegroundColor Yellow

try {
    & "C:\isotone\apache24\bin\httpd.exe" -k uninstall -n "IsotoneApache"
    Write-Host "  Removed Apache service" -ForegroundColor Green
} catch {
    Write-Host "  Failed to remove Apache service" -ForegroundColor Red
}

try {
    & "C:\isotone\mariadb\bin\mysqld.exe" --remove "IsotoneMariaDB"
    Write-Host "  Removed MariaDB service" -ForegroundColor Green
} catch {
    Write-Host "  Failed to remove MariaDB service" -ForegroundColor Red
}

if ($RemoveData) {
    Write-Host "`nWARNING: This will delete all data! Press Ctrl+C to cancel..." -ForegroundColor Red
    Start-Sleep -Seconds 5
    Remove-Item -Path "C:\isotone" -Recurse -Force
    Write-Host "All IsotoneStack files removed." -ForegroundColor Green
} else {
    Write-Host "`nServices uninstalled. Files preserved at C:\isotone" -ForegroundColor Yellow
    Write-Host "Run with -RemoveData to completely remove all files." -ForegroundColor Yellow
}
'@
    Set-Content -Path "$InstallPath\control-panel\uninstall.ps1" -Value $uninstallScript -Force
}

# Create default website
function Create-DefaultWebsite {
    Write-Host "`nCreating default website..." -ForegroundColor Cyan
    
    $indexContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IsotoneStack - Development Environment</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 800px;
            width: 100%;
        }
        h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.2em;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .info-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        .info-card h3 {
            color: #667eea;
            margin-bottom: 10px;
        }
        .info-card p {
            color: #666;
            font-size: 0.9em;
        }
        .links {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
        }
        .links a {
            display: inline-block;
            padding: 10px 20px;
            background: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-right: 10px;
            margin-bottom: 10px;
            transition: background 0.3s;
        }
        .links a:hover {
            background: #5a67d8;
        }
        .php-info {
            background: #f0f0f0;
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 IsotoneStack</h1>
        <p class="subtitle">Your Windows Development Environment is Ready!</p>
        
        <div class="info-grid">
            <div class="info-card">
                <h3>Apache</h3>
                <p>Version: 2.4.62<br>Port: 80</p>
            </div>
            <div class="info-card">
                <h3>PHP</h3>
                <p>Version: <?php echo phpversion(); ?><br>Status: Active</p>
            </div>
            <div class="info-card">
                <h3>MariaDB</h3>
                <p>Version: 11.4.4<br>Port: 3306</p>
            </div>
            <div class="info-card">
                <h3>phpMyAdmin</h3>
                <p>Version: 5.2.1<br>Ready to use</p>
            </div>
        </div>
        
        <div class="php-info">
            <strong>PHP Configuration Test:</strong><br>
            <?php
            echo "PHP is working correctly!<br>";
            echo "Server Software: " . $_SERVER['SERVER_SOFTWARE'] . "<br>";
            echo "Document Root: " . $_SERVER['DOCUMENT_ROOT'] . "<br>";
            echo "Current Time: " . date('Y-m-d H:i:s');
            ?>
        </div>
        
        <div class="links">
            <h3>Quick Links:</h3>
            <a href="/phpmyadmin">phpMyAdmin</a>
            <a href="/info.php">PHP Info</a>
        </div>
        
        <p style="margin-top: 30px; color: #999; font-size: 0.9em;">
            Installation Path: C:\isotone | 
            Control Panel: C:\isotone\control-panel
        </p>
    </div>
</body>
</html>
'@
    Set-Content -Path "$InstallPath\www\default\index.php" -Value $indexContent -Force
    
    # Create phpinfo page
    $phpInfoContent = @'
<?php
phpinfo();
?>
'@
    Set-Content -Path "$InstallPath\www\default\info.php" -Value $phpInfoContent -Force
}

# Main installation process
function Main {
    Write-Host @"
========================================
   IsotoneStack Installation Script
   Installing to: $InstallPath
========================================
"@ -ForegroundColor Cyan

    try {
        # Initialize directory structure
        Initialize-DirectoryStructure -BasePath $InstallPath
        
        # Check and install prerequisites
        Install-VCRedist
        
        # Install components
        Install-Apache
        Install-PHP
        Install-MariaDB
        Install-PhpMyAdmin
        
        # Create control panel and default content
        Create-ControlPanel
        Create-DefaultWebsite
        
        Write-Host @"

========================================
   Installation Complete!
========================================

Installation Path: $InstallPath

Installed Components:
  - Apache 2.4.62
  - PHP 8.3.15
  - MariaDB 11.4.4
  - phpMyAdmin 5.2.1

Control Panel Scripts:
  - Start:    $InstallPath\control-panel\start.ps1
  - Stop:     $InstallPath\control-panel\stop.ps1
  - Restart:  $InstallPath\control-panel\restart.ps1
  - Status:   $InstallPath\control-panel\status.ps1
  
To start the services, run:
  & "$InstallPath\control-panel\start.ps1"
  
Access Points:
  - Web Server: http://localhost
  - phpMyAdmin: http://localhost/phpmyadmin
  - Database: localhost:3306 (user: root, pass: isotone_admin)

"@ -ForegroundColor Green

    } catch {
        Write-Host "`nInstallation failed: $_" -ForegroundColor Red
        Write-Host $_.Exception.StackTrace -ForegroundColor Red
        exit 1
    }
}

# Run main function
Main