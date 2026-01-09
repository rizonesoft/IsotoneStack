# Configure-IsotoneStack.ps1
# Configures bundled Apache, PHP, MariaDB and phpMyAdmin components
# Uses template files from the config folder with variable replacement

param(
    [string]$PhpVersion = "",   # Specific PHP version to use (e.g., "8.4.11")
    [switch]$Force,
    [switch]$SkipMariaDBInit,
    [switch]$Verbose,    # Enable verbose output
    [switch]$Debug       # Enable debug output
)

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$configPath = Join-Path $isotonePath "config"
$logsPath = Join-Path $isotonePath "logs\isotone"

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logsPath "$scriptName`_$timestamp.log"

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

try {
    # Start logging
    Write-Log "========================================" "INFO"
    Write-Log "IsotoneStack Configuration Started" "INFO"
    Write-Log "Script: $scriptName" "INFO"
    Write-Log "Installation Directory: $isotonePath" "INFO"
    Write-Log "Parameters: Force=$Force, SkipMariaDBInit=$SkipMariaDBInit" "INFO"
    Write-Log "========================================" "INFO"

    Write-Host ""
    Write-Log "=== IsotoneStack Component Configuration ===" "MAGENTA"
    Write-Log "Installation Directory: $isotonePath" "INFO"
    Write-Host ""

    # Check for required components
    Write-Log "Checking components..." "CYAN"
    $missingComponents = $false

    # Check Apache
    if (!(Test-Path "$isotonePath\apache24\bin\httpd.exe")) {
        Write-Log "  [MISSING] Apache - Component not found in apache24 folder" "ERROR"
        $missingComponents = $true
    } else {
        Write-Log "  [OK] Apache found" "SUCCESS"
    }

    # Check PHP (detect all versions)
    $phpVersions = Get-ChildItem -Path "$isotonePath\php" -Directory -ErrorAction SilentlyContinue | 
                   Where-Object { Test-Path (Join-Path $_.FullName "php.exe") }
    
    if ($phpVersions.Count -eq 0) {
        Write-Log "  [MISSING] PHP - No PHP versions found in php folder" "ERROR"
        $missingComponents = $true
    } else {
        Write-Log "  [OK] Found $($phpVersions.Count) PHP version(s):" "SUCCESS"
        foreach ($ver in $phpVersions) {
            Write-Log "      - PHP $($ver.Name)" "DEBUG"
        }
        # Set default version: use parameter if provided, otherwise use latest
        if ($PhpVersion -and ($phpVersions.Name -contains $PhpVersion)) {
            $defaultPhpVersion = $PhpVersion
            Write-Log "  [INFO] Using specified PHP version: $defaultPhpVersion" "INFO"
        } else {
            $defaultPhpVersion = ($phpVersions | Sort-Object Name -Descending | Select-Object -First 1).Name
            if ($PhpVersion) {
                Write-Log "  [WARNING] Specified PHP version '$PhpVersion' not found, using: $defaultPhpVersion" "WARNING"
            } else {
                Write-Log "  [INFO] Default PHP version: $defaultPhpVersion" "INFO"
            }
        }
    }
    
    # Check MariaDB
    if (!(Test-Path "$isotonePath\mariadb\bin\mariadbd.exe") -and !(Test-Path "$isotonePath\mariadb\bin\mysqld.exe")) {
        Write-Log "  [MISSING] MariaDB - Component not found in mariadb folder" "ERROR"
        $missingComponents = $true
    } else {
        Write-Log "  [OK] MariaDB found" "SUCCESS"
    }

    # Check phpMyAdmin
    if (!(Test-Path "$isotonePath\phpmyadmin\index.php")) {
        Write-Log "  [MISSING] phpMyAdmin - Component not found in phpmyadmin folder" "ERROR"
        $missingComponents = $true
    } else {
        Write-Log "  [OK] phpMyAdmin found" "SUCCESS"
    }
    
    # Check phpLiteAdmin (optional but recommended)
    if (!(Test-Path "$isotonePath\phpliteadmin\phpliteadmin.php")) {
        Write-Log "  [INFO] phpLiteAdmin - Not found (optional component)" "INFO"
    } else {
        Write-Log "  [OK] phpLiteAdmin found" "SUCCESS"
    }
    

    if ($missingComponents) {
        Write-Host ""
        Write-Log "=== Components Missing! ===" "ERROR"
        Write-Log "Please ensure all bundled components are properly extracted to their respective folders." "ERROR"
        Write-Host ""
        Write-Log "Configuration aborted due to missing components" "ERROR"
        exit 1
    }

    Write-Host ""
    Write-Log "=== Configuring Components ===" "CYAN"
    Write-Host ""
    Write-Log "This will configure:" "INFO"
    Write-Log "  1. Setup www folder with default content" "DEBUG"
    Write-Log "  2. Apache httpd.conf (from config\apache\httpd.conf)" "DEBUG"
    Write-Log "  3. PHP php.ini (from config\php\php.ini)" "DEBUG"
    Write-Log "  4. MariaDB my.ini (from config\mariadb\my.ini)" "DEBUG"
    Write-Log "  5. phpMyAdmin config.inc.php (from config\phpmyadmin\config.inc.php)" "DEBUG"
    Write-Host ""

    # Function to replace template variables
    function Replace-TemplateVariables {
        param(
            [string]$Content,
            [string]$InstallPath,
            [string]$PhpVersion = ""
        )
        
        # Convert to forward slashes for {{INSTALL_PATH}}
        $installPathFS = $InstallPath.Replace('\', '/')
        # Keep backslashes for {{INSTALL_PATH_BS}}
        $installPathBS = $InstallPath
        
        # Get current year for {{YEAR}}
        $currentYear = (Get-Date).Year
        
        $Content = $Content -replace '{{INSTALL_PATH}}', $installPathFS
        $Content = $Content -replace '{{INSTALL_PATH_BS}}', $installPathBS
        $Content = $Content -replace '{{YEAR}}', $currentYear
        
        # Replace PHP version if provided
        if ($PhpVersion) {
            $Content = $Content -replace '{{PHP_VERSION}}', $PhpVersion
        }
        
        # Also replace hardcoded paths
        $Content = $Content -replace 'C:/isotone', $installPathFS
        $Content = $Content -replace 'C:\\isotone', $installPathBS
        
        return $Content
    }

    # Step 1: Setup www and SQLite folders
    Write-Log "[1/7] Setting up www and SQLite folders..." "YELLOW"

    $wwwPath = Join-Path $isotonePath "www"
    if (!(Test-Path $wwwPath)) {
        New-Item -Path $wwwPath -ItemType Directory -Force | Out-Null
        Write-Log "  Created www directory" "DEBUG"
    }

    # Check for default content
    $defaultPath = Join-Path $isotonePath "default"
    if (Test-Path $defaultPath) {
        Write-Log "  Copying default content to www..." "DEBUG"
        Copy-Item -Path "$defaultPath\*" -Destination $wwwPath -Recurse -Force
        Write-Log "  [OK] Default content copied to www folder" "SUCCESS"
    } else {
        # Create basic index.php if it doesn't exist
        $indexPath = Join-Path $wwwPath "index.php"
        if (!(Test-Path $indexPath)) {
            Write-Log "  Creating basic index.php..." "DEBUG"
            $phpContent = @"
<?php
echo "<h1>IsotoneStack is running!</h1>";
echo "<p>PHP Version: " . phpversion() . "</p>";
phpinfo();
?>
"@
            Set-Content -Path $indexPath -Value $phpContent -Encoding UTF8
            Write-Log "  [OK] Created basic index.php" "SUCCESS"
        } else {
            Write-Log "  [OK] www folder already contains content" "SUCCESS"
        }
    }

    # Step 2: Configure Apache
    Write-Log "[2/7] Configuring Apache..." "YELLOW"

    # Create Apache log directory
    $apacheLogDir = Join-Path $isotonePath "logs\apache"
    if (!(Test-Path $apacheLogDir)) {
        New-Item -Path $apacheLogDir -ItemType Directory -Force | Out-Null
        Write-Log "  Created Apache log directory" "DEBUG"
    }

    # Copy all extra config files from template
    $extraTemplateDir = Join-Path $configPath "apache\extra"
    $extraConfigDir = Join-Path $isotonePath "apache24\conf\extra"
    if (Test-Path $extraTemplateDir) {
        if (!(Test-Path $extraConfigDir)) {
            New-Item -Path $extraConfigDir -ItemType Directory -Force | Out-Null
        }
        $extraFiles = Get-ChildItem -Path $extraTemplateDir -Filter "*.conf"
        foreach ($file in $extraFiles) {
            $content = Get-Content -Path $file.FullName -Raw
            $content = Replace-TemplateVariables -Content $content -InstallPath $isotonePath
            $targetFile = Join-Path $extraConfigDir $file.Name
            Set-Content -Path $targetFile -Value $content -Encoding ASCII
            Write-Log "  Copied $($file.Name) to conf/extra/" "DEBUG"
        }
    }

    $apacheTemplate = Join-Path $configPath "apache\httpd.conf"
    $apacheConfig = Join-Path $isotonePath "apache24\conf\httpd.conf"

    if (Test-Path $apacheTemplate) {
        Write-Log "  Using httpd.conf from config folder..." "DEBUG"
        
        # Backup original if not already backed up
        $apacheBackup = "$apacheConfig.backup"
        if (!(Test-Path $apacheBackup) -and (Test-Path $apacheConfig)) {
            Copy-Item -Path $apacheConfig -Destination $apacheBackup -Force
            Write-Log "  Created backup: httpd.conf.backup" "DEBUG"
        }
        
        # Read template and replace variables
        $content = Get-Content -Path $apacheTemplate -Raw
        $content = Replace-TemplateVariables -Content $content -InstallPath $isotonePath -PhpVersion $defaultPhpVersion
        
        # Write configuration
        Set-Content -Path $apacheConfig -Value $content -Encoding UTF8
        Write-Log "  [OK] Apache configuration applied from template with PHP $defaultPhpVersion" "SUCCESS"
    } else {
        Write-Log "  [WARNING] httpd.conf not found in config\apache\" "WARNING"
        Write-Log "  Attempting basic configuration..." "DEBUG"
        
        if (Test-Path $apacheConfig) {
            # Backup original
            $apacheBackup = "$apacheConfig.backup"
            if (!(Test-Path $apacheBackup)) {
                Copy-Item -Path $apacheConfig -Destination $apacheBackup -Force
                Write-Log "  Created backup: httpd.conf.backup" "DEBUG"
            }
            
            # Update ServerRoot and DocumentRoot
            $content = Get-Content -Path $apacheConfig -Raw
            $installPathFS = $isotonePath.Replace('\', '/')
            
            $content = $content -replace '(?i)c:/Apache24', "$installPathFS/apache24"
            $content = $content -replace 'DocumentRoot "[^"]*"', "DocumentRoot `"$installPathFS/www`""
            $content = $content -replace '<Directory "[^"]*htdocs[^"]*">', "<Directory `"$installPathFS/www`">"
            
            # Add PHP configuration if not present
            if ($content -notmatch "LoadModule php_module") {
                $phpConfig = @"

# PHP Configuration
LoadModule php_module "$installPathFS/php/$defaultPhpVersion/php8apache2_4.dll"
AddHandler application/x-httpd-php .php
PHPIniDir "$installPathFS/php/$defaultPhpVersion"
DirectoryIndex index.php index.html
"@
                $content += $phpConfig
                Write-Log "  Added PHP configuration to Apache" "DEBUG"
            }
            
            Set-Content -Path $apacheConfig -Value $content -Encoding UTF8
            Write-Log "  [OK] Basic Apache configuration applied" "SUCCESS"
        }
    }

    # Step 3: Configure PHP (all versions)
    Write-Log "[3/7] Configuring PHP versions..." "YELLOW"

    # Get all PHP versions
    $phpVersions = Get-ChildItem -Path "$isotonePath\php" -Directory -ErrorAction SilentlyContinue | 
                   Where-Object { Test-Path (Join-Path $_.FullName "php.exe") }

    if ($phpVersions.Count -gt 0) {
        $phpTemplate = Join-Path $configPath "php\php.ini"
        
        foreach ($phpVer in $phpVersions) {
            Write-Log "  Configuring PHP $($phpVer.Name)..." "INFO"
            $phpConfig = Join-Path $phpVer.FullName "php.ini"
            
            if (Test-Path $phpTemplate) {
                Write-Log "    Using php.ini from config folder..." "DEBUG"
                
                # Read template and replace variables
                $content = Get-Content -Path $phpTemplate -Raw
                $content = Replace-TemplateVariables -Content $content -InstallPath $isotonePath
                
                # Replace version-specific paths
                $versionPathBS = $phpVer.FullName
                $content = $content -replace 'extension_dir = ".*?"', "extension_dir = `"$versionPathBS\ext`""
                
                # Write configuration
                Set-Content -Path $phpConfig -Value $content -Encoding UTF8
                Write-Log "    [OK] php.ini created for $($phpVer.Name)" "SUCCESS"
            } else {
                # Use development template if available
                $phpDev = Join-Path $phpVer.FullName "php.ini-development"
                if (Test-Path $phpDev -and !(Test-Path $phpConfig)) {
                    Write-Log "    Using php.ini-development..." "DEBUG"
                    Copy-Item -Path $phpDev -Destination $phpConfig -Force
                    
                    # Enable common extensions
                    $content = Get-Content -Path $phpConfig -Raw
                    $content = $content -replace ';extension=curl', 'extension=curl'
                    $content = $content -replace ';extension=fileinfo', 'extension=fileinfo'
                    $content = $content -replace ';extension=gd', 'extension=gd'
                    $content = $content -replace ';extension=mbstring', 'extension=mbstring'
                    $content = $content -replace ';extension=mysqli', 'extension=mysqli'
                    $content = $content -replace ';extension=openssl', 'extension=openssl'
                    $content = $content -replace ';extension=pdo_mysql', 'extension=pdo_mysql'
                    $content = $content -replace ';extension=sodium', 'extension=sodium'
                    $content = $content -replace ';extension=sqlite3', 'extension=sqlite3'
                    $content = $content -replace ';extension=pdo_sqlite', 'extension=pdo_sqlite'
                    
                    # Set extension directory
                    $versionPathBS = $phpVer.FullName
                    $content = $content -replace '; extension_dir = "ext"', "extension_dir = `"$versionPathBS\ext`""
                    
                    Set-Content -Path $phpConfig -Value $content -Encoding UTF8
                    Write-Log "    [OK] php.ini created with common extensions for $($phpVer.Name)" "SUCCESS"
                } elseif (Test-Path $phpConfig) {
                    Write-Log "    [OK] php.ini already exists for $($phpVer.Name)" "SUCCESS"
                } else {
                    Write-Log "    [WARNING] No php.ini template available for $($phpVer.Name)" "WARNING"
                }
            }
        }
        
        Write-Log "  [OK] All PHP versions configured" "SUCCESS"
    } else {
        Write-Log "  [WARNING] No PHP versions found to configure" "WARNING"
    }

    # Step 4: Configure MariaDB
    Write-Log "[4/7] Configuring MariaDB..." "YELLOW"

    # Create required directories
    $mariadbDirs = @(
        (Join-Path $isotonePath "mariadb\data"),
        (Join-Path $isotonePath "logs\mariadb"),
        (Join-Path $isotonePath "tmp")
    )

    foreach ($dir in $mariadbDirs) {
        if (!(Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-Log "  Created directory: $dir" "DEBUG"
        }
    }

    $mariadbTemplate = Join-Path $configPath "mariadb\my.ini"
    $mariadbConfig = Join-Path $isotonePath "mariadb\my.ini"

    if (Test-Path $mariadbTemplate) {
        Write-Log "  Using my.ini from config folder..." "DEBUG"
        
        # Read template and replace variables
        $content = Get-Content -Path $mariadbTemplate -Raw
        $content = Replace-TemplateVariables -Content $content -InstallPath $isotonePath
        
        # Write configuration (my.ini goes in MariaDB root, not data directory)
        Set-Content -Path $mariadbConfig -Value $content -Encoding UTF8
        Write-Log "  [OK] MariaDB configuration applied from template" "SUCCESS"
    } else {
        Write-Log "  [WARNING] my.ini not found in config\mariadb\" "WARNING"
        Write-Log "  Creating basic MariaDB configuration..." "DEBUG"
        
        $installPathFS = $isotonePath.Replace('\', '/')
        $mariadbContent = @"
[mysqld]
basedir=$installPathFS/mariadb
datadir=$installPathFS/mariadb/data
port=3306
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
max_connections=100
innodb_buffer_pool_size=128M
log-error=$installPathFS/logs/mariadb/error.log

[client]
port=3306
default-character-set=utf8mb4
"@
        Set-Content -Path $mariadbConfig -Value $mariadbContent -Encoding ASCII
        Write-Log "  [OK] Basic MariaDB configuration created" "SUCCESS"
    }

    # Initialize MariaDB data directory if needed
    $mysqlDataDir = Join-Path $isotonePath "mariadb\data\mysql"
    if (!(Test-Path $mysqlDataDir) -and !$SkipMariaDBInit) {
        Write-Log "  Initializing MariaDB data directory..." "INFO"
        
        $mariadbBin = Join-Path $isotonePath "mariadb\bin"
        $dataDir = Join-Path $isotonePath "mariadb\data"
        
        Push-Location $mariadbBin
        
        try {
            if (Test-Path "mariadb-install-db.exe") {
                & .\mariadb-install-db.exe --datadir="$dataDir" --default-user 2>&1 | Out-String | ForEach-Object {
                    Write-Log $_ "DEBUG"
                }
            } elseif (Test-Path "mysql_install_db.exe") {
                & .\mysql_install_db.exe --datadir="$dataDir" --default-user 2>&1 | Out-String | ForEach-Object {
                    Write-Log $_ "DEBUG"
                }
            }
        } catch {
            Write-Log "  Error initializing MariaDB: $_" "ERROR"
        }
        
        Pop-Location
        
        if (Test-Path $mysqlDataDir) {
            Write-Log "  [OK] MariaDB data directory initialized" "SUCCESS"
        } else {
            Write-Log "  [WARNING] MariaDB initialization may have failed" "WARNING"
        }
    }

    # Step 5: Configure phpMyAdmin
    Write-Log "[5/7] Configuring phpMyAdmin..." "YELLOW"

    $phpmyadminTemplate = Join-Path $configPath "phpmyadmin\config.inc.php"
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"

    if (Test-Path $phpmyadminTemplate) {
        Write-Log "  Using config.inc.php from config folder..." "DEBUG"
        Write-Log "  Template path: $phpmyadminTemplate" "DEBUG"
        Write-Log "  Target path: $phpmyadminConfig" "DEBUG"
        
        # Read template and replace variables
        $content = Get-Content -Path $phpmyadminTemplate -Raw
        Write-Log "  Template size: $($content.Length) bytes" "DEBUG"
        
        $content = Replace-TemplateVariables -Content $content -InstallPath $isotonePath
        
        # Write configuration
        Set-Content -Path $phpmyadminConfig -Value $content -Encoding UTF8
        Write-Log "  Configuration written to: $phpmyadminConfig" "DEBUG"
        
        # Verify the file was written
        if (Test-Path $phpmyadminConfig) {
            $fileSize = (Get-Item $phpmyadminConfig).Length
            Write-Log "  Output file size: $fileSize bytes" "DEBUG"
        }
        
        # Create tmp directory for phpMyAdmin
        $phpmyadminTmp = Join-Path $isotonePath "phpmyadmin\tmp"
        if (!(Test-Path $phpmyadminTmp)) {
            New-Item -Path $phpmyadminTmp -ItemType Directory -Force | Out-Null
            Write-Log "  Created phpMyAdmin tmp directory" "DEBUG"
        }
        
        Write-Log "  [OK] phpMyAdmin configuration applied from template" "SUCCESS"
    } else {
        Write-Log "  [WARNING] config.inc.php not found in config\phpmyadmin\" "WARNING"
        
        if (!(Test-Path $phpmyadminConfig)) {
            Write-Log "  Creating basic phpMyAdmin configuration..." "DEBUG"
            
            $installPathFS = $isotonePath.Replace('\', '/')
            $phpmyadminContent = @"
<?php
`$cfg['blowfish_secret'] = 'IsotoneStack32CharacterSecretKey123456789012';

`$i = 0;
`$i++;

`$cfg['Servers'][`$i]['verbose'] = 'IsotoneStack MariaDB';
`$cfg['Servers'][`$i]['host'] = 'localhost';
`$cfg['Servers'][`$i]['port'] = 3306;
`$cfg['Servers'][`$i]['socket'] = '';
`$cfg['Servers'][`$i]['auth_type'] = 'cookie';
`$cfg['Servers'][`$i]['AllowNoPassword'] = true;

`$cfg['UploadDir'] = '';
`$cfg['SaveDir'] = '';
`$cfg['TempDir'] = '$installPathFS/phpmyadmin/tmp';

`$cfg['DefaultLang'] = 'en';
`$cfg['ServerDefault'] = 1;
?>
"@
            Set-Content -Path $phpmyadminConfig -Value $phpmyadminContent -Encoding UTF8
            
            # Create tmp directory
            $phpmyadminTmp = Join-Path $isotonePath "phpmyadmin\tmp"
            if (!(Test-Path $phpmyadminTmp)) {
                New-Item -Path $phpmyadminTmp -ItemType Directory -Force | Out-Null
                Write-Log "  Created phpMyAdmin tmp directory" "DEBUG"
            }
            
            Write-Log "  [OK] Basic phpMyAdmin configuration created" "SUCCESS"
        } else {
            Write-Log "  [OK] phpMyAdmin configuration already exists" "SUCCESS"
        }
    }

    # Create Apache alias for phpMyAdmin
    Write-Host ""
    Write-Log "Creating phpMyAdmin alias in Apache..." "CYAN"

    $phpmyadminAliasTemplate = Join-Path $configPath "apache\extra\httpd-phpmyadmin.conf"
    $phpmyadminAlias = Join-Path $isotonePath "apache24\conf\extra\httpd-phpmyadmin.conf"
    
    if (Test-Path $phpmyadminAliasTemplate) {
        Write-Log "  Using httpd-phpmyadmin.conf from config folder..." "DEBUG"
        
        # Read template and replace variables
        $content = Get-Content -Path $phpmyadminAliasTemplate -Raw
        $content = Replace-TemplateVariables -Content $content -InstallPath $isotonePath
        
        # Write configuration
        Set-Content -Path $phpmyadminAlias -Value $content -Encoding ASCII
        Write-Log "  [OK] phpMyAdmin alias configuration applied from template" "SUCCESS"
    } else {
        Write-Log "  [WARNING] httpd-phpmyadmin.conf not found in config\apache\extra\" "WARNING"
        
        # Fallback: create basic configuration
        if (!(Test-Path $phpmyadminAlias) -or $Force) {
            $installPathFS = $isotonePath.Replace('\', '/')
            $aliasContent = @"
Alias /phpmyadmin "$installPathFS/phpmyadmin"

<Directory "$installPathFS/phpmyadmin">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
"@
            Set-Content -Path $phpmyadminAlias -Value $aliasContent -Encoding ASCII
            Write-Log "  Created basic phpMyAdmin alias configuration" "DEBUG"
        }
        Write-Log "  [OK] phpMyAdmin alias configuration created" "SUCCESS"
    }
    
    # Add include to httpd.conf if not already there
    $apacheConfig = Join-Path $isotonePath "apache24\conf\httpd.conf"
    $configContent = Get-Content -Path $apacheConfig -Raw
    
    if ($configContent -notmatch "httpd-phpmyadmin\.conf") {
        Add-Content -Path $apacheConfig -Value "`nInclude conf/extra/httpd-phpmyadmin.conf"
        Write-Log "  Added phpMyAdmin include to httpd.conf" "DEBUG"
        Write-Log "  [OK] phpMyAdmin include added" "SUCCESS"
    } else {
        Write-Log "  [OK] phpMyAdmin include already exists in httpd.conf" "SUCCESS"
    }

    # Check if phpMyAdmin storage setup might be needed
    $pmaConfigPath = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    $pmaConfig = Get-Content -Path $pmaConfigPath -Raw
    if ($pmaConfig -match "\['pmadb'\]\s*=\s*'phpmyadmin'") {
        Write-Host ""
        Write-Log "phpMyAdmin configuration storage detected." "INFO"
        Write-Log "  Run phpmyadmin\Setup-phpMyAdmin-Storage.ps1 to configure storage tables" "YELLOW"
        Write-Log "  This enables advanced features like:" "DEBUG"
        Write-Log "    - Bookmarked queries" "DEBUG"
        Write-Log "  [INFO] phpLiteAdmin not found - skipping configuration" "INFO"
        Write-Log "  To add phpLiteAdmin later, download from phpliteadmin.org" "DEBUG"
    }

    # Step 7: Configure SQLite
    Write-Log "[7/8] Configuring SQLite..." "YELLOW"
    
    # Create SQLite directory
    $sqlitePath = Join-Path $isotonePath "sqlite"
    if (!(Test-Path $sqlitePath)) {
        New-Item -Path $sqlitePath -ItemType Directory -Force | Out-Null
        Write-Log "  Created SQLite database directory: sqlite\" "DEBUG"
    } else {
        Write-Log "  SQLite directory already exists" "DEBUG"
    }
    
    # Enable SQLite in PHP configuration if not already enabled
    $phpConfig = Join-Path $isotonePath "php\php.ini"
    if (Test-Path $phpConfig) {
        $phpContent = Get-Content -Path $phpConfig -Raw
        
        # Enable SQLite extensions
        $sqliteEnabled = $false
        if ($phpContent -match ";extension=sqlite3") {
            $phpContent = $phpContent -replace ";extension=sqlite3", "extension=sqlite3"
            $sqliteEnabled = $true
        }
        if ($phpContent -match ";extension=pdo_sqlite") {
            $phpContent = $phpContent -replace ";extension=pdo_sqlite", "extension=pdo_sqlite"
            $sqliteEnabled = $true
        }
        
        if ($sqliteEnabled) {
            Set-Content -Path $phpConfig -Value $phpContent -Encoding UTF8
            Write-Log "  Enabled SQLite extensions in PHP" "DEBUG"
        } else {
            Write-Log "  SQLite extensions already enabled in PHP" "DEBUG"
        }
    }
    
    # Create sample SQLite database
    $sampleDb = Join-Path $sqlitePath "isotone.db"
    if (!(Test-Path $sampleDb)) {
    } else {
        Write-Log "  SQLite database already exists: isotone.db" "DEBUG"
    }
    
    Write-Log "  [OK] SQLite configuration complete" "SUCCESS"
    Write-Log "  SQLite databases stored in: sqlite\" "INFO"
    Write-Log "  Access SQLite via: http://localhost/sqlite" "INFO"

    # Step 8: Create iso-control configuration
    Write-Log "[8/8] Creating iso-control configuration..." "YELLOW"
    
    $isoControlConfigPath = Join-Path $isotonePath "iso-control\config.json"
    $isoControlDir = Join-Path $isotonePath "iso-control"
    
    if (!(Test-Path $isoControlDir)) {
        New-Item -Path $isoControlDir -ItemType Directory -Force | Out-Null
        Write-Log "  Created iso-control directory" "DEBUG"
    }
    
    # Only create config if it doesn't exist (don't overwrite user settings)
    if (!(Test-Path $isoControlConfigPath)) {
        Write-Log "  Creating default configuration..." "DEBUG"
        
        $config = @{
            IsotonePath = $isotonePath
            AutoStartServices = $false
            MinimizeToTray = $false
            AutoCheckUpdates = $true
            SelectedPhpVersion = $defaultPhpVersion
            EnabledPhpExtensions = @()
        }
        
        $config | ConvertTo-Json | Set-Content -Path $isoControlConfigPath -Encoding UTF8
        Write-Log "  [OK] Created config.json with default PHP version: $defaultPhpVersion" "SUCCESS"
    } else {
        Write-Log "  [OK] config.json already exists (preserving user settings)" "SUCCESS"
    }

    # Summary
    Write-Host ""
    Write-Log "=== Configuration Complete! ===" "SUCCESS"
    Write-Host ""
    Write-Log "All components have been configured successfully." "SUCCESS"
    Write-Host ""
    Write-Log "Configuration files:" "CYAN"
    Write-Log "  Apache:       apache24\conf\httpd.conf" "DEBUG"
    Write-Log "  PHP:          php\<version>\php.ini (multi-version)" "DEBUG"
    Write-Log "  Default PHP:  $defaultPhpVersion" "INFO"
    Write-Log "  MariaDB:      mariadb\my.ini" "DEBUG"
    Write-Log "  phpMyAdmin:   phpmyadmin\config.inc.php" "DEBUG"
    Write-Log "  phpLiteAdmin: phpliteadmin\phpliteadmin.config.php" "DEBUG"
    Write-Log "  SQLite:       sqlite\*.db (database files)" "DEBUG"
    Write-Host ""
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Run Register-Services.ps1 to register Windows services" "DEBUG"
    Write-Log "  2. Run Start-Services.ps1 to start the services" "DEBUG"
    Write-Log "  3. Run phpmyadmin\Setup-phpMyAdmin-Storage.ps1 (optional) for advanced features" "DEBUG"
    Write-Log "  4. Access http://localhost to verify installation" "DEBUG"
    Write-Log "  5. Access http://localhost/phpmyadmin for MariaDB management" "DEBUG"
    Write-Log "  6. Access http://localhost/phpliteadmin for SQLite management" "DEBUG"
    Write-Log "  7. Access http://localhost/sqlite (alias to phpLiteAdmin)" "DEBUG"
    Write-Host ""
    
    Write-Log "========================================" "INFO"
    Write-Log "Configuration completed successfully" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    Write-Log "========================================" "INFO"
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Configuration failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}