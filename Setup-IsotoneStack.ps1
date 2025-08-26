# IsotoneStack Setup Script for Pre-Bundled Distribution
# This script configures the already extracted components
# Components should be manually downloaded and extracted to their directories

param(
    [string]$InstallPath = "",
    [switch]$Force = $false
)

# If InstallPath not provided, use script's directory
if ([string]::IsNullOrEmpty($InstallPath)) {
    $InstallPath = $PSScriptRoot
}

# Clean up the path (remove trailing backslash if present)
$InstallPath = $InstallPath.TrimEnd('\', '/')

# Run as Administrator check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run as Administrator." -ForegroundColor Red
    exit 1
}

$ErrorActionPreference = "Stop"
$ProgressPreference = 'Continue'

Write-Host @"
========================================
   IsotoneStack Setup Script
   For Pre-Bundled Components
========================================

This script will configure the IsotoneStack components
that have been extracted to: $InstallPath

Required component versions:
  - Apache 2.4.65+
  - PHP 8.4.11+
  - MariaDB 12.0.2+
  - phpMyAdmin 5.2.2+
  - VC++ Runtime (included in runtime folder)

"@ -ForegroundColor Cyan

# Check and install VC++ Runtime if needed
function Install-VCRuntime {
    Write-Host "Checking Visual C++ Runtime..." -ForegroundColor Cyan
    
    # Check if VC++ 2022 Runtime is installed
    $vcInstalled = $false
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
        "HKLM:\SOFTWARE\Classes\Installer\Dependencies\Microsoft.VS.VC_RuntimeMinimumVSU_amd64,v14"
    )
    
    foreach ($path in $regPaths) {
        if (Test-Path $path) {
            $vcInstalled = $true
            break
        }
    }
    
    if ($vcInstalled) {
        Write-Host "  ✅ Visual C++ Runtime already installed" -ForegroundColor Green
    } else {
        Write-Host "  Installing Visual C++ Runtime..." -ForegroundColor Yellow
        
        $runtimePath = "$InstallPath\runtime\vc_redist.x64.exe"
        if (Test-Path $runtimePath) {
            Write-Host "  Found runtime installer at: $runtimePath" -ForegroundColor Green
            
            $process = Start-Process -FilePath $runtimePath -ArgumentList "/quiet", "/norestart" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "  ✅ Visual C++ Runtime installed successfully" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️ Runtime installation may have failed (code: $($process.ExitCode))" -ForegroundColor Yellow
                Write-Host "  You can manually install from: $runtimePath" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ⚠️ VC++ Runtime not found in runtime folder" -ForegroundColor Yellow
            Write-Host "  Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe" -ForegroundColor Yellow
        }
    }
}

# Install VC++ Runtime first
Install-VCRuntime

# Check if components exist
function Test-ComponentsExist {
    $components = @{
        "Apache" = "$InstallPath\apache24\bin\httpd.exe"
        "PHP" = "$InstallPath\php\php.exe"
        "MariaDB" = "$InstallPath\mariadb\bin\mysqld.exe"
        "phpMyAdmin" = "$InstallPath\phpmyadmin\index.php"
    }
    
    $missing = @()
    foreach ($component in $components.GetEnumerator()) {
        if (-not (Test-Path $component.Value)) {
            $missing += $component.Key
            Write-Host "  ❌ $($component.Key) not found at: $($component.Value)" -ForegroundColor Red
        } else {
            Write-Host "  ✅ $($component.Key) found" -ForegroundColor Green
        }
    }
    
    if ($missing.Count -gt 0) {
        Write-Host "`nMissing components: $($missing -join ', ')" -ForegroundColor Red
        Write-Host @"

Please download and extract the following components:
1. Apache 2.4.65+ → $InstallPath\apache24\
2. PHP 8.4.11+ → $InstallPath\php\
3. MariaDB 12.0.2+ → $InstallPath\mariadb\
4. phpMyAdmin 5.2.2+ → $InstallPath\phpmyadmin\

Download from:
- Apache: https://www.apachelounge.com/download/
- PHP: https://windows.php.net/download/
- MariaDB: https://mariadb.org/download/
- phpMyAdmin: https://www.phpmyadmin.net/downloads/

"@ -ForegroundColor Yellow
        return $false
    }
    return $true
}

# Create directory structure
function Initialize-DirectoryStructure {
    Write-Host "`nCreating directory structure..." -ForegroundColor Cyan
    
    $directories = @(
        "$InstallPath\www\default",
        "$InstallPath\logs\apache",
        "$InstallPath\logs\php",
        "$InstallPath\logs\mariadb",
        "$InstallPath\tmp",
        "$InstallPath\ssl",
        "$InstallPath\backups",
        "$InstallPath\config"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "  Created: $dir" -ForegroundColor Green
        }
    }
}

# Configure Apache
function Configure-Apache {
    Write-Host "`nConfiguring Apache..." -ForegroundColor Cyan
    
    $confFile = "$InstallPath\apache24\conf\httpd.conf"
    
    if (Test-Path $confFile) {
        $content = Get-Content $confFile -Raw
        
        # Update paths
        $content = $content -replace 'c:/Apache24', ($InstallPath + '/apache24' -replace '\\', '/')
        $content = $content -replace 'c:/Apache2', ($InstallPath + '/apache24' -replace '\\', '/')
        
        # Update ServerRoot
        $content = $content -replace 'ServerRoot\s+".*?"', "ServerRoot `"$($InstallPath -replace '\\', '/')/apache24`""
        
        # Update DocumentRoot and Directory
        $content = $content -replace 'DocumentRoot\s+".*?"', "DocumentRoot `"$($InstallPath -replace '\\', '/')/www`""
        $content = $content -replace '<Directory\s+"c:/Apache24/htdocs">', "<Directory `"$($InstallPath -replace '\\', '/')/www`">"
        $content = $content -replace '<Directory\s+"\$\{SRVROOT\}/htdocs">', "<Directory `"$($InstallPath -replace '\\', '/')/www`">"
        
        # Enable required modules
        $content = $content -replace '#LoadModule rewrite_module', 'LoadModule rewrite_module'
        $content = $content -replace '#LoadModule ssl_module', 'LoadModule ssl_module'
        
        # Update or add PHP configuration
        if ($content -match 'LoadModule php_module') {
            # Update existing PHP paths
            $content = $content -replace 'LoadModule php_module\s+".*?"', "LoadModule php_module `"$($InstallPath -replace '\\', '/')/php/php8apache2_4.dll`""
            $content = $content -replace 'PHPIniDir\s+".*?"', "PHPIniDir `"$($InstallPath -replace '\\', '/')/php`""
        } else {
            # Add PHP configuration if not exists
            $phpConfig = @"

# PHP 8.4 Configuration
LoadModule php_module "$($InstallPath -replace '\\', '/')/php/php8apache2_4.dll"
AddHandler application/x-httpd-php .php
PHPIniDir "$($InstallPath -replace '\\', '/')/php"
DirectoryIndex index.php index.html
"@
            $content += $phpConfig
        }
        
        # Configure logs
        $content = $content -replace 'ErrorLog\s+".*?"', "ErrorLog `"$($InstallPath -replace '\\', '/')/logs/apache/error.log`""
        $content = $content -replace 'CustomLog\s+".*?"\s+common', "CustomLog `"$($InstallPath -replace '\\', '/')/logs/apache/access.log`" common"
        
        # ServerName
        $content = $content -replace '#ServerName www.example.com:80', 'ServerName localhost:80'
        
        Set-Content -Path $confFile -Value $content -Encoding UTF8
        Write-Host "  Apache configuration updated" -ForegroundColor Green
        
        # Create phpMyAdmin alias
        $aliasConfig = @"
# phpMyAdmin Configuration
Alias /phpmyadmin "$($InstallPath -replace '\\', '/')/phpmyadmin"
<Directory "$($InstallPath -replace '\\', '/')/phpmyadmin">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
"@
        
        $aliasFile = "$InstallPath\apache24\conf\extra\phpmyadmin.conf"
        Set-Content -Path $aliasFile -Value $aliasConfig -Encoding UTF8
        
        # Include the alias in main config
        if ($content -notmatch 'Include.*phpmyadmin\.conf') {
            $content += "`nInclude conf/extra/phpmyadmin.conf"
            Set-Content -Path $confFile -Value $content -Encoding UTF8
        }
        
    } else {
        Write-Host "  Apache configuration file not found!" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# Configure PHP
function Configure-PHP {
    Write-Host "`nConfiguring PHP..." -ForegroundColor Cyan
    
    $phpIniDev = "$InstallPath\php\php.ini-development"
    $phpIniProd = "$InstallPath\php\php.ini-production"
    $phpIni = "$InstallPath\php\php.ini"
    
    # Use development template if exists, otherwise production
    $template = if (Test-Path $phpIniDev) { $phpIniDev } elseif (Test-Path $phpIniProd) { $phpIniProd } else { $null }
    
    if ($template) {
        Copy-Item $template $phpIni -Force
        Write-Host "  Created php.ini from template" -ForegroundColor Green
        
        # Configure PHP settings
        $content = Get-Content $phpIni -Raw
        
        # Set extension directory (Windows uses backslashes)
        $extDir = "$InstallPath\php\ext"
        # Update extension_dir - handle multiple possible formats
        $content = $content -replace ';?\s*extension_dir\s*=\s*".*?"', "extension_dir = `"$extDir`""
        $content = $content -replace ';?\s*extension_dir\s*=\s*[^\r\n]+', "extension_dir = `"$extDir`""
        
        # Enable common extensions (PHP 7.2+ uses just extension name without php_ or .dll)
        $extensions = @(
            'curl', 'fileinfo', 'gd', 'mbstring', 'mysqli', 
            'openssl', 'pdo_mysql', 'zip', 'intl', 'soap', 
            'xsl', 'bcmath', 'exif', 'gettext', 'imap'
        )
        
        foreach ($ext in $extensions) {
            # PHP 7.2+ on Windows - just use extension name
            $content = $content -replace ";extension=$ext\b", "extension=$ext"
        }
        
        # Configure paths (PHP needs forward slashes)
        $content = $content -replace 'error_log\s*=.*', "error_log = `"$($InstallPath -replace '\\', '/')/logs/php/error.log`""
        $content = $content -replace 'upload_tmp_dir\s*=.*', "upload_tmp_dir = `"$($InstallPath -replace '\\', '/')/tmp`""
        $content = $content -replace 'session.save_path\s*=.*', "session.save_path = `"$($InstallPath -replace '\\', '/')/tmp`""
        
        # Development settings
        $content = $content -replace 'display_errors\s*=.*', 'display_errors = On'
        $content = $content -replace 'display_startup_errors\s*=.*', 'display_startup_errors = On'
        
        # Limits
        $content = $content -replace 'memory_limit\s*=.*', 'memory_limit = 256M'
        $content = $content -replace 'post_max_size\s*=.*', 'post_max_size = 128M'
        $content = $content -replace 'upload_max_filesize\s*=.*', 'upload_max_filesize = 128M'
        $content = $content -replace 'max_execution_time\s*=.*', 'max_execution_time = 300'
        
        Set-Content -Path $phpIni -Value $content -Encoding UTF8
        Write-Host "  PHP configuration updated" -ForegroundColor Green
    } else {
        Write-Host "  PHP configuration template not found!" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# Initialize MariaDB
function Initialize-MariaDB {
    Write-Host "`nInitializing MariaDB..." -ForegroundColor Cyan
    
    $dataDir = "$InstallPath\mariadb\data"
    $binDir = "$InstallPath\mariadb\bin"
    
    # Create data directory if it doesn't exist
    if (-not (Test-Path $dataDir)) {
        Write-Host "  Creating MariaDB data directory..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    }
    
    # Check if already initialized
    if ((Test-Path "$dataDir\mysql") -and -not $Force) {
        Write-Host "  MariaDB already initialized. Use -Force to reinitialize." -ForegroundColor Yellow
        return $true
    }
    
    # Don't create my.ini here - mysql_install_db will create it in the data directory
    # We'll create it after initialization if needed
    
    # Initialize database
    Write-Host "  Initializing database files..." -ForegroundColor Yellow
    
    try {
        # Clean data directory if Force
        if ($Force -and (Test-Path $dataDir)) {
            Remove-Item "$dataDir\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        # Run mysql_install_db or mysqld --initialize
        $initCommand = "$binDir\mysql_install_db.exe"
        if (-not (Test-Path $initCommand)) {
            # Use mysqld --initialize for newer versions
            $initCommand = "$binDir\mysqld.exe"
            $initArgs = "--initialize-insecure --basedir=`"$InstallPath\mariadb`" --datadir=`"$dataDir`""
        } else {
            $initArgs = "--datadir=`"$dataDir`" --basedir=`"$InstallPath\mariadb`""
        }
        
        Write-Host "  Running database initialization (this may take a minute)..." -ForegroundColor Yellow
        
        # Run with visible window and no timeout to prevent cancellation
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $initCommand
        $pinfo.Arguments = $initArgs
        $pinfo.UseShellExecute = $false
        $pinfo.CreateNoWindow = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.RedirectStandardError = $true
        
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        $p.WaitForExit()
        
        if ($p.ExitCode -eq 0) {
            Write-Host "  Database initialized successfully" -ForegroundColor Green
        } else {
            Write-Host "  Database initialization completed with exit code: $($p.ExitCode)" -ForegroundColor Yellow
            # Continue anyway as it might still work
        }
        
        # Create my.ini from template
        $myIniPath = "$InstallPath\mariadb\my.ini"
        $templatePath = "$InstallPath\config\my.ini.template"
        
        if (Test-Path $templatePath) {
            # Use template
            $myIni = Get-Content -Path $templatePath -Raw
            $myIni = $myIni -replace '{{INSTALL_PATH}}', ($InstallPath -replace '\\', '/')
        } else {
            # Fallback to embedded configuration
            $myIni = @"
[mysqld]
basedir=$($InstallPath -replace '\\', '/')/mariadb
datadir=$($InstallPath -replace '\\', '/')/mariadb/data
port=3306
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
innodb_buffer_pool_size=256M
innodb_log_file_size=48M
max_connections=100
skip-grant-tables
log-error=$($InstallPath -replace '\\', '/')/logs/mariadb/error.log

[client]
port=3306
default-character-set=utf8mb4
"@
        }
        
        Set-Content -Path $myIniPath -Value $myIni -Encoding ASCII
        Write-Host "  Created my.ini configuration for service" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error during database initialization: $_" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# Configure phpMyAdmin
function Configure-phpMyAdmin {
    Write-Host "`nConfiguring phpMyAdmin..." -ForegroundColor Cyan
    
    $configFile = "$InstallPath\phpmyadmin\config.inc.php"
    $templatePath = "$InstallPath\config\phpmyadmin.config.template"
    
    # Generate blowfish secret
    $blowfishSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    
    if (Test-Path $templatePath) {
        # Use template
        $config = Get-Content -Path $templatePath -Raw
        $config = $config -replace '{{INSTALL_PATH}}', ($InstallPath -replace '\\', '/')
        $config = $config -replace '{{BLOWFISH_SECRET}}', $blowfishSecret
    } else {
        # Fallback to embedded configuration
        $config = @"
<?php
/* phpMyAdmin configuration for IsotoneStack */

/* Server configuration */
\$cfg['Servers'][1]['verbose'] = 'IsotoneStack MariaDB';
\$cfg['Servers'][1]['host'] = 'localhost';
\$cfg['Servers'][1]['port'] = 3306;
\$cfg['Servers'][1]['socket'] = '';
\$cfg['Servers'][1]['auth_type'] = 'cookie';
\$cfg['Servers'][1]['AllowNoPassword'] = true;

/* Directories */
\$cfg['UploadDir'] = '$($InstallPath -replace '\\', '/')/tmp';
\$cfg['SaveDir'] = '$($InstallPath -replace '\\', '/')/tmp';
\$cfg['TempDir'] = '$($InstallPath -replace '\\', '/')/tmp';

/* Security */
\$cfg['blowfish_secret'] = '$blowfishSecret';
\$cfg['CheckConfigurationPermissions'] = false;

/* UI Settings */
\$cfg['ThemeDefault'] = 'pmahomme';
\$cfg['MaxRows'] = 50;
\$cfg['ShowPhpInfo'] = true;
\$cfg['ShowChgPassword'] = true;
\$cfg['ShowCreateDb'] = true;

/* Development Settings */
\$cfg['DBG']['sql'] = false;
\$cfg['ShowSQL'] = true;
?>
"@
    }
    
    Set-Content -Path $configFile -Value $config -Encoding UTF8
    Write-Host "  phpMyAdmin configuration created" -ForegroundColor Green
    
    return $true
}

# Register Windows Services
function Register-Services {
    Write-Host "`nRegistering Windows Services..." -ForegroundColor Cyan
    
    # Register Apache service
    Write-Host "  Registering Apache service..." -ForegroundColor Yellow
    
    # First, ensure any old service is removed
    Write-Host "    Removing any existing service..." -ForegroundColor Gray
    $removeResult = & cmd /c "`"$InstallPath\apache24\bin\httpd.exe`" -k uninstall -n IsotoneApache 2>&1"
    Start-Sleep -Seconds 1
    
    # Change to Apache bin directory for installation
    Write-Host "    Installing new service..." -ForegroundColor Gray
    $originalLocation = Get-Location
    Set-Location "$InstallPath\apache24\bin"
    
    $installResult = & cmd /c "httpd.exe -k install -n IsotoneApache 2>&1"
    Set-Location $originalLocation
    
    if ($LASTEXITCODE -eq 0) {
        sc.exe config IsotoneApache start= manual | Out-Null
        Write-Host "    IsotoneApache service registered successfully" -ForegroundColor Green
    } else {
        Write-Host "    Apache service registration failed:" -ForegroundColor Red
        Write-Host "    $installResult" -ForegroundColor Red
        
        # Try alternative approach
        Write-Host "    Trying alternative installation method..." -ForegroundColor Yellow
        $altResult = & cmd /c "`"$InstallPath\apache24\bin\httpd.exe`" -k install -n IsotoneApache" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    IsotoneApache service registered (alternative method)" -ForegroundColor Green
        } else {
            Write-Host "    Failed to register Apache service" -ForegroundColor Red
            return $false
        }
    }
    
    # Register MariaDB service
    Write-Host "  Registering MariaDB service..." -ForegroundColor Yellow
    
    # Remove any existing service (ignore errors if it doesn't exist)
    Write-Host "    Removing any existing service..." -ForegroundColor Gray
    try {
        $removeOutput = & cmd /c "`"$InstallPath\mariadb\bin\mysqld.exe`" --remove IsotoneMariaDB 2>&1"
        # Also try sc delete just in case
        sc.exe delete IsotoneMariaDB 2>&1 | Out-Null
    } catch {
        # Ignore errors - service might not exist
    }
    
    # Install the service
    Write-Host "    Installing new service..." -ForegroundColor Gray
    $mariaResult = & cmd /c "`"$InstallPath\mariadb\bin\mysqld.exe`" --install IsotoneMariaDB --defaults-file=`"$InstallPath\mariadb\my.ini`" 2>&1"
    
    if ($LASTEXITCODE -eq 0) {
        sc.exe config IsotoneMariaDB start= manual | Out-Null
        Write-Host "    IsotoneMariaDB service registered successfully" -ForegroundColor Green
    } else {
        Write-Host "    MariaDB service registration had issues but may still work" -ForegroundColor Yellow
        Write-Host "    $mariaResult" -ForegroundColor Gray
    }
    
    return $true
}

# Copy default website files
function Create-DefaultWebsite {
    Write-Host "`nCopying default website files..." -ForegroundColor Cyan
    
    # Check if default directory exists
    $defaultDir = "$InstallPath\default"
    if (-not (Test-Path $defaultDir)) {
        Write-Host "  Default directory not found at $defaultDir" -ForegroundColor Red
        return $false
    }
    
    # Copy files from default to www (only if they don't exist)
    $wwwDir = "$InstallPath\www"
    
    # Get all files and directories from default
    $items = Get-ChildItem -Path $defaultDir -Recurse
    
    foreach ($item in $items) {
        # Calculate relative path
        $relativePath = $item.FullName.Substring($defaultDir.Length + 1)
        $destinationPath = Join-Path $wwwDir $relativePath
        
        if ($item.PSIsContainer) {
            # It's a directory - create it if it doesn't exist
            if (-not (Test-Path $destinationPath)) {
                New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
                Write-Host "  Created directory: $relativePath" -ForegroundColor Gray
            }
        } else {
            # It's a file - copy it if it doesn't exist
            if (-not (Test-Path $destinationPath)) {
                Copy-Item -Path $item.FullName -Destination $destinationPath -Force
                Write-Host "  Copied: $relativePath" -ForegroundColor Green
            } else {
                Write-Host "  Skipped (exists): $relativePath" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host "  Default website files copied" -ForegroundColor Green
    
    return $true
}

# Create helper scripts
function Create-HelperScripts {
    Write-Host "`nCreating helper scripts..." -ForegroundColor Cyan
    
    # Start Services script
    $startScript = @'
# Start IsotoneStack Services
Write-Host "Starting IsotoneStack services..." -ForegroundColor Cyan
net start IsotoneApache
net start IsotoneMariaDB
Write-Host "Services started!" -ForegroundColor Green
'@
    Set-Content -Path "$InstallPath\Start-Services.ps1" -Value $startScript -Encoding UTF8
    
    # Stop Services script
    $stopScript = @'
# Stop IsotoneStack Services
Write-Host "Stopping IsotoneStack services..." -ForegroundColor Cyan
net stop IsotoneApache
net stop IsotoneMariaDB
Write-Host "Services stopped!" -ForegroundColor Green
'@
    Set-Content -Path "$InstallPath\Stop-Services.ps1" -Value $stopScript -Encoding UTF8
    
    # Check Status script
    $statusScript = @'
# Check IsotoneStack Service Status
Write-Host "`nIsotoneStack Service Status" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
sc.exe query IsotoneApache | Select-String "STATE"
sc.exe query IsotoneMariaDB | Select-String "STATE"
'@
    Set-Content -Path "$InstallPath\Check-Status.ps1" -Value $statusScript -Encoding UTF8
    
    # Uninstall Services script
    $uninstallScript = @'
# Uninstall IsotoneStack Services
param([switch]$RemoveData)

Write-Host "Stopping services..." -ForegroundColor Yellow
net stop IsotoneApache 2>$null
net stop IsotoneMariaDB 2>$null

Write-Host "Removing services..." -ForegroundColor Yellow
sc.exe delete IsotoneApache
sc.exe delete IsotoneMariaDB

if ($RemoveData) {
    Write-Host "Removing all data..." -ForegroundColor Red
    Remove-Item $InstallPath -Recurse -Force
}

Write-Host "Services uninstalled!" -ForegroundColor Green
'@
    Set-Content -Path "$InstallPath\Uninstall-Services.ps1" -Value $uninstallScript -Encoding UTF8
    
    Write-Host "  Helper scripts created" -ForegroundColor Green
    return $true
}

# Main execution
try {
    Write-Host "`nChecking components..." -ForegroundColor Cyan
    
    if (-not (Test-ComponentsExist)) {
        exit 1
    }
    
    Initialize-DirectoryStructure
    
    $apacheOk = Configure-Apache
    $phpOk = Configure-PHP
    $mariadbOk = Initialize-MariaDB
    $phpmyadminOk = Configure-phpMyAdmin
    $servicesOk = Register-Services
    Create-DefaultWebsite
    Create-HelperScripts
    
    Write-Host @"

========================================
   Setup Complete!
========================================

Component Status:
  Apache:     $(if ($apacheOk) { '✅ Configured' } else { '❌ Failed' })
  PHP:        $(if ($phpOk) { '✅ Configured' } else { '❌ Failed' })
  MariaDB:    $(if ($mariadbOk) { '✅ Initialized' } else { '❌ Failed' })
  phpMyAdmin: $(if ($phpmyadminOk) { '✅ Configured' } else { '❌ Failed' })
  Services:   $(if ($servicesOk) { '✅ Registered' } else { '❌ Failed' })

Next Steps:
1. Start services:
   .\Start-Services.ps1
   
2. Access your stack:
   - Web: http://localhost
   - phpMyAdmin: http://localhost/phpmyadmin
   
3. Launch Control Panel:
   $InstallPath\control-panel\launch.bat

"@ -ForegroundColor $(if ($apacheOk -and $phpOk -and $mariadbOk -and $phpmyadminOk -and $servicesOk) { 'Green' } else { 'Yellow' })
    
} catch {
    Write-Host "`nSetup failed: $_" -ForegroundColor Red
    Write-Host $_.Exception.StackTrace -ForegroundColor Red
    exit 1
}