# Configure-IsotoneStack.ps1
# Configures bundled Apache, PHP, MariaDB and phpMyAdmin components
# Uses template files from the config folder with variable replacement

param(
    [switch]$Force,
    [switch]$SkipMariaDBInit
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

    # Check PHP
    if (!(Test-Path "$isotonePath\php\php.exe")) {
        Write-Log "  [MISSING] PHP - Component not found in php folder" "ERROR"
        $missingComponents = $true
    } else {
        Write-Log "  [OK] PHP found" "SUCCESS"
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
            [string]$InstallPath
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

    $apacheTemplate = Join-Path $configPath "apache24\httpd.conf"
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
        $content = Replace-TemplateVariables -Content $content -InstallPath $isotonePath
        
        # Write configuration
        Set-Content -Path $apacheConfig -Value $content -Encoding UTF8
        Write-Log "  [OK] Apache configuration applied from template" "SUCCESS"
    } else {
        Write-Log "  [WARNING] httpd.conf not found in config\apache24\" "WARNING"
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
LoadModule php_module "$installPathFS/php/php8apache2_4.dll"
AddHandler application/x-httpd-php .php
PHPIniDir "$installPathFS/php"
DirectoryIndex index.php index.html
"@
                $content += $phpConfig
                Write-Log "  Added PHP configuration to Apache" "DEBUG"
            }
            
            Set-Content -Path $apacheConfig -Value $content -Encoding UTF8
            Write-Log "  [OK] Basic Apache configuration applied" "SUCCESS"
        }
    }

    # Step 3: Configure PHP
    Write-Log "[3/7] Configuring PHP..." "YELLOW"

    $phpTemplate = Join-Path $configPath "php\php.ini"
    $phpConfig = Join-Path $isotonePath "php\php.ini"

    if (Test-Path $phpTemplate) {
        Write-Log "  Using php.ini from config folder..." "DEBUG"
        
        # Read template and replace variables
        $content = Get-Content -Path $phpTemplate -Raw
        $content = Replace-TemplateVariables -Content $content -InstallPath $isotonePath
        
        # Write configuration
        Set-Content -Path $phpConfig -Value $content -Encoding UTF8
        Write-Log "  [OK] PHP configuration applied from template" "SUCCESS"
    } else {
        Write-Log "  [WARNING] php.ini not found in config\php\" "WARNING"
        
        # Use development template if available
        $phpDev = Join-Path $isotonePath "php\php.ini-development"
        if (Test-Path $phpDev) {
            Write-Log "  Using php.ini-development..." "DEBUG"
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
            
            # Set extension directory
            $installPathBS = $isotonePath
            $content = $content -replace '; extension_dir = "ext"', "extension_dir = `"$installPathBS\php\ext`""
            
            Set-Content -Path $phpConfig -Value $content -Encoding UTF8
            Write-Log "  [OK] PHP configured with common extensions" "SUCCESS"
        } else {
            Write-Log "  [WARNING] No PHP configuration template available" "WARNING"
        }
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

    $phpmyadminAlias = Join-Path $isotonePath "apache24\conf\extra\httpd-phpmyadmin.conf"
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
        Write-Log "  Created phpMyAdmin alias configuration" "DEBUG"
        
        # Add include to httpd.conf if not already there
        $apacheConfig = Join-Path $isotonePath "apache24\conf\httpd.conf"
        $configContent = Get-Content -Path $apacheConfig -Raw
        
        if ($configContent -notmatch "httpd-phpmyadmin\.conf") {
            Add-Content -Path $apacheConfig -Value "`nInclude conf/extra/httpd-phpmyadmin.conf"
            Write-Log "  Added phpMyAdmin include to httpd.conf" "DEBUG"
        }
        
        Write-Log "  [OK] phpMyAdmin alias created" "SUCCESS"
    } else {
        Write-Log "  [OK] phpMyAdmin alias already exists" "SUCCESS"
    }

    # Check if phpMyAdmin storage setup might be needed
    $pmaConfigPath = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    $pmaConfig = Get-Content -Path $pmaConfigPath -Raw
    if ($pmaConfig -match "\['pmadb'\]\s*=\s*'phpmyadmin'") {
        Write-Host ""
        Write-Log "phpMyAdmin configuration storage detected." "INFO"
        Write-Log "  Run Setup-phpMyAdmin-Storage.ps1 to configure storage tables" "YELLOW"
        Write-Log "  This enables advanced features like:" "DEBUG"
        Write-Log "    - Bookmarked queries" "DEBUG"
        Write-Log "    - SQL history" "DEBUG"
        Write-Log "    - Designer view" "DEBUG"
        Write-Log "    - User preferences" "DEBUG"
    }

    # Step 6: Configure phpLiteAdmin
    Write-Log "[6/7] Configuring phpLiteAdmin..." "YELLOW"
    
    # Check if phpLiteAdmin exists
    $phpliteadminPath = Join-Path $isotonePath "phpliteadmin\phpliteadmin.php"
    if (Test-Path $phpliteadminPath) {
        Write-Log "  phpLiteAdmin found at: phpliteadmin\phpliteadmin.php" "DEBUG"
        
        # Create Apache alias for phpLiteAdmin
        Write-Host ""
        Write-Log "Creating phpLiteAdmin alias in Apache..." "CYAN"
        $phpliteadminAlias = Join-Path $isotonePath "apache24\conf\extra\httpd-phpliteadmin.conf"
        
        if (!(Test-Path $phpliteadminAlias) -or $Force) {
            $installPathFS = $isotonePath.Replace('\', '/')
            $aliasContent = @"
# phpLiteAdmin configuration for IsotoneStack
# SQLite database management tool

Alias /phpliteadmin "$installPathFS/phpliteadmin/"
Alias /sqlite "$installPathFS/phpliteadmin/"

<Directory "$installPathFS/phpliteadmin/">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    
    # PHP settings for phpLiteAdmin
    php_admin_value upload_max_filesize 128M
    php_admin_value post_max_size 128M
    php_admin_value max_execution_time 360
    php_admin_value max_input_time 360
    php_admin_value memory_limit 256M
    
    # Security headers
    Header set X-Content-Type-Options "nosniff"
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-XSS-Protection "1; mode=block"
    
    # Directory index
    DirectoryIndex phpliteadmin.php index.php
</Directory>

# Redirect /phpliteadmin (without trailing slash) to /phpliteadmin/
RedirectMatch ^/phpliteadmin$ /phpliteadmin/
RedirectMatch ^/sqlite$ /phpliteadmin/

# Prevent access to configuration samples
<FilesMatch "\.sample\.php$">
    Require all denied
</FilesMatch>
"@
            Set-Content -Path $phpliteadminAlias -Value $aliasContent -Encoding ASCII
            Write-Log "  Created phpLiteAdmin alias configuration" "DEBUG"
            
            # Add include to httpd.conf if not already there
            $apacheConfig = Join-Path $isotonePath "apache24\conf\httpd.conf"
            $configContent = Get-Content -Path $apacheConfig -Raw
            
            if ($configContent -notmatch "httpd-phpliteadmin\.conf") {
                Add-Content -Path $apacheConfig -Value "Include conf/extra/httpd-phpliteadmin.conf"
                Write-Log "  Added phpLiteAdmin include to httpd.conf" "DEBUG"
            }
            
            Write-Log "  [OK] phpLiteAdmin alias created" "SUCCESS"
        } else {
            Write-Log "  [OK] phpLiteAdmin alias already exists" "SUCCESS"
        }
        
        # Create phpLiteAdmin configuration if it doesn't exist
        $phpliteadminConfig = Join-Path $isotonePath "phpliteadmin\phpliteadmin.config.php"
        if (!(Test-Path $phpliteadminConfig)) {
            $sqlitePath = Join-Path $isotonePath "sqlite"
            $sqlitePathFS = $sqlitePath.Replace('\', '/')
            $configContent = @"
<?php
// phpLiteAdmin configuration for IsotoneStack
// Generated by Configure-IsotoneStack.ps1

// Password for phpLiteAdmin (default: admin)
// IMPORTANT: Change this password for security!
`$password = 'admin';

// Directory where SQLite databases are stored
`$directory = '$sqlitePathFS';

// Theme (options: Default, AlternateBlue, Modern, etc.)
`$theme = 'Default';

// Language
`$language = 'en';

// Number of rows to display by default
`$rowsNum = 30;

// Maximum file size for imports (in bytes)
`$maxSavedChars = 100000;

// Enable debugging
`$debug = false;

// Custom functions
`$custom_functions = array(
    'md5', 'sha1', 'sha256', 
    'strtoupper', 'strtolower', 
    'ucfirst', 'lcfirst'
);

// Supported SQLite extensions
`$allowed_extensions = array('db', 'db3', 'sqlite', 'sqlite3');
?>
"@
            Set-Content -Path $phpliteadminConfig -Value $configContent -Encoding ASCII
            Write-Log "  Created phpLiteAdmin configuration file" "DEBUG"
            Write-Log "  [WARNING] Default password is 'admin' - please change it!" "WARNING"
        } else {
            Write-Log "  phpLiteAdmin configuration already exists" "DEBUG"
        }
        
        Write-Log "  [OK] phpLiteAdmin configuration complete" "SUCCESS"
    } else {
        Write-Log "  [INFO] phpLiteAdmin not found - skipping configuration" "INFO"
        Write-Log "  To add phpLiteAdmin later, download from phpliteadmin.org" "DEBUG"
    }

    # Step 7: Configure SQLite
    Write-Log "[7/7] Configuring SQLite..." "YELLOW"
    
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
        Write-Log "  Sample SQLite database will be created on first access" "INFO"
    } else {
        Write-Log "  SQLite database already exists: isotone.db" "DEBUG"
    }
    
    Write-Log "  [OK] SQLite configuration complete" "SUCCESS"
    Write-Log "  SQLite databases stored in: sqlite\" "INFO"
    Write-Log "  Access SQLite via: http://localhost/sqlite" "INFO"

    # Summary
    Write-Host ""
    Write-Log "=== Configuration Complete! ===" "SUCCESS"
    Write-Host ""
    Write-Log "All components have been configured successfully." "SUCCESS"
    Write-Host ""
    Write-Log "Configuration files:" "CYAN"
    Write-Log "  Apache:       apache24\conf\httpd.conf" "DEBUG"
    Write-Log "  PHP:          php\php.ini" "DEBUG"
    Write-Log "  MariaDB:      mariadb\my.ini" "DEBUG"
    Write-Log "  phpMyAdmin:   phpmyadmin\config.inc.php" "DEBUG"
    Write-Log "  phpLiteAdmin: phpliteadmin\phpliteadmin.config.php" "DEBUG"
    Write-Log "  SQLite:       sqlite\*.db (database files)" "DEBUG"
    Write-Host ""
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Run Register-Services.ps1 to register Windows services" "DEBUG"
    Write-Log "  2. Run Start-Services.ps1 to start the services" "DEBUG"
    Write-Log "  3. Run Setup-phpMyAdmin-Storage.ps1 (optional) for advanced features" "DEBUG"
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