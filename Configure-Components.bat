@echo off
REM ============================================
REM IsotoneStack Component Configuration Script
REM ============================================
REM This script configures Apache, PHP, MariaDB and phpMyAdmin

title IsotoneStack Component Configuration
color 0E
cls

echo.
echo ============================================
echo    IsotoneStack Component Configuration
echo ============================================
echo.

REM Check current directory
set ISOTONE_PATH=%~dp0
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%
echo Installation Directory: %ISOTONE_PATH%
echo.

REM Check for required components
echo Checking components...
echo.

set MISSING=0

if not exist "%ISOTONE_PATH%\apache24\bin\httpd.exe" (
    echo   [MISSING] Apache - Please run Download-IsotoneStack.bat first
    set MISSING=1
) else (
    echo   [OK] Apache found
)

if not exist "%ISOTONE_PATH%\php\php.exe" (
    echo   [MISSING] PHP - Please run Download-IsotoneStack.bat first
    set MISSING=1
) else (
    echo   [OK] PHP found
)

if not exist "%ISOTONE_PATH%\mariadb\bin\mariadbd.exe" (
    if not exist "%ISOTONE_PATH%\mariadb\bin\mysqld.exe" (
        echo   [MISSING] MariaDB - Please run Download-IsotoneStack.bat first
        set MISSING=1
    ) else (
        echo   [OK] MariaDB found
    )
) else (
    echo   [OK] MariaDB found
)

if not exist "%ISOTONE_PATH%\phpmyadmin\index.php" (
    echo   [MISSING] phpMyAdmin - Please run Download-IsotoneStack.bat first
    set MISSING=1
) else (
    echo   [OK] phpMyAdmin found
)

echo.

if %MISSING% == 1 (
    echo ============================================
    echo    Components Missing!
    echo ============================================
    echo.
    echo Please run Download-IsotoneStack.bat first to download
    echo and extract all required components.
    echo.
    pause
    exit /b 1
)

echo ============================================
echo    Configuring Components
echo ============================================
echo.
echo This will configure:
echo   1. Setup www folder with default content
echo   2. Apache httpd.conf (DocumentRoot to www)
echo   3. PHP php.ini
echo   4. MariaDB my.ini
echo   5. phpMyAdmin config.inc.php
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

REM Setup www folder with default content
echo.
echo [1/5] Setting up www folder...
if not exist "%ISOTONE_PATH%\www" mkdir "%ISOTONE_PATH%\www"

REM Copy default content to www
if exist "%ISOTONE_PATH%\default" (
    echo   Copying default content to www...
    xcopy "%ISOTONE_PATH%\default\*" "%ISOTONE_PATH%\www\" /E /H /Y >nul
    echo   [OK] Default content copied to www folder
) else (
    echo   [WARNING] Default folder not found, creating basic index.php
    (
        echo ^<?php
        echo echo "IsotoneStack is running!";
        echo phpinfo^(^);
        echo ?^>
    ) > "%ISOTONE_PATH%\www\index.php"
)

REM Configure Apache
echo [2/5] Configuring Apache...
if exist "%ISOTONE_PATH%\config\httpd.conf.template" (
    echo   Using httpd.conf.template from config folder...
    
    REM Replace template placeholders and copy in one step
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); (Get-Content '%ISOTONE_PATH%\config\httpd.conf.template') -replace '{{INSTALL_PATH}}', \"$path\" -replace 'C:/isotone', \"$path\" | Set-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf'"
    
    echo   [OK] Apache configuration applied from template
) else (
    echo   Creating Apache configuration...
    
    REM Backup original config
    if not exist "%ISOTONE_PATH%\apache24\conf\httpd.conf.backup" (
        copy "%ISOTONE_PATH%\apache24\conf\httpd.conf" "%ISOTONE_PATH%\apache24\conf\httpd.conf.backup" >nul
    )
    
    REM Update ServerRoot - handle both c:/Apache24 and C:/Apache24 patterns
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); (Get-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf') -replace '(?i)c:/Apache24', \"$path/apache24\" | Set-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf'"
    
    REM Update DocumentRoot and Directory directives to point to www folder
    REM First update DocumentRoot (handles various formats)
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); (Get-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf') -replace 'DocumentRoot \"[^\"]*\"', \"DocumentRoot \`\"$path/www\`\"\" | Set-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf'"
    
    REM Then update the corresponding Directory directive (looking for the main document root directory)
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); $content = Get-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf' -Raw; $content -replace '<Directory \"[^\"]*htdocs[^\"]*\">', \"<Directory \`\"$path/www\`\">\" | Set-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf'"
    
    REM Also update any references to apache24/htdocs
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); (Get-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf') -replace \"$path/apache24/htdocs\", \"$path/www\" | Set-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf'"
    
    REM Enable PHP module (check if not already added)
    findstr /C:"LoadModule php_module" "%ISOTONE_PATH%\apache24\conf\httpd.conf" >nul
    if errorlevel 1 (
        powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); Add-Content '%ISOTONE_PATH%\apache24\conf\httpd.conf' \"`n# PHP Configuration`nLoadModule php_module \`\"$path/php/php8apache2_4.dll\`\"`nAddHandler application/x-httpd-php .php`nPHPIniDir \`\"$path/php\`\"`nDirectoryIndex index.php index.html\""
    )
    
    echo   [OK] Apache configured for PHP and www folder
)

REM Configure PHP
echo [3/5] Configuring PHP...
if exist "%ISOTONE_PATH%\config\php.ini.template" (
    echo   Using php.ini.template from config folder...
    
    REM Replace template placeholders and copy in one step
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); (Get-Content '%ISOTONE_PATH%\config\php.ini.template') -replace '{{INSTALL_PATH}}', \"$path\" -replace 'C:/isotone', \"$path\" | Set-Content '%ISOTONE_PATH%\php\php.ini'"
    
    echo   [OK] PHP configuration applied from template
) else if exist "%ISOTONE_PATH%\php\php.ini-development" (
    copy /Y "%ISOTONE_PATH%\php\php.ini-development" "%ISOTONE_PATH%\php\php.ini" >nul
    
    REM Enable common extensions
    powershell -Command "(Get-Content '%ISOTONE_PATH%\php\php.ini') -replace ';extension=curl', 'extension=curl' | Set-Content '%ISOTONE_PATH%\php\php.ini'"
    powershell -Command "(Get-Content '%ISOTONE_PATH%\php\php.ini') -replace ';extension=fileinfo', 'extension=fileinfo' | Set-Content '%ISOTONE_PATH%\php\php.ini'"
    powershell -Command "(Get-Content '%ISOTONE_PATH%\php\php.ini') -replace ';extension=gd', 'extension=gd' | Set-Content '%ISOTONE_PATH%\php\php.ini'"
    powershell -Command "(Get-Content '%ISOTONE_PATH%\php\php.ini') -replace ';extension=mbstring', 'extension=mbstring' | Set-Content '%ISOTONE_PATH%\php\php.ini'"
    powershell -Command "(Get-Content '%ISOTONE_PATH%\php\php.ini') -replace ';extension=mysqli', 'extension=mysqli' | Set-Content '%ISOTONE_PATH%\php\php.ini'"
    powershell -Command "(Get-Content '%ISOTONE_PATH%\php\php.ini') -replace ';extension=openssl', 'extension=openssl' | Set-Content '%ISOTONE_PATH%\php\php.ini'"
    powershell -Command "(Get-Content '%ISOTONE_PATH%\php\php.ini') -replace ';extension=pdo_mysql', 'extension=pdo_mysql' | Set-Content '%ISOTONE_PATH%\php\php.ini'"
    
    REM Set extension directory with dynamic path
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); (Get-Content '%ISOTONE_PATH%\php\php.ini') -replace '; extension_dir = \"ext\"', \"extension_dir = \`\"$path/php/ext\`\"\" | Set-Content '%ISOTONE_PATH%\php\php.ini'"
    
    echo   [OK] PHP configured with common extensions
) else (
    echo   [WARNING] php.ini not found, using defaults
)

REM Configure MariaDB
echo [4/5] Configuring MariaDB...

REM Create required directories
if not exist "%ISOTONE_PATH%\mariadb\data" mkdir "%ISOTONE_PATH%\mariadb\data"
if not exist "%ISOTONE_PATH%\logs\mariadb" mkdir "%ISOTONE_PATH%\logs\mariadb"
if not exist "%ISOTONE_PATH%\tmp" mkdir "%ISOTONE_PATH%\tmp"

REM Use template if available, otherwise create from template file
if exist "%ISOTONE_PATH%\config\my.ini.template" (
    echo   Using my.ini.template from config folder...
    
    REM Copy template and replace ALL placeholders (my.ini goes in MariaDB root, not data directory)
    REM Replace both {{INSTALL_PATH}} and C:/isotone patterns
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); (Get-Content '%ISOTONE_PATH%\config\my.ini.template') -replace '{{INSTALL_PATH}}', \"$path\" -replace 'C:/isotone', \"$path\" | Set-Content '%ISOTONE_PATH%\mariadb\my.ini'"
    
    echo   [OK] MariaDB configuration applied from template
) else (
    echo   Creating MariaDB configuration...
    
    REM Create my.ini with dynamic paths (in MariaDB root directory)
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); @('[mysqld]', \"basedir=$path/mariadb\", \"datadir=$path/mariadb/data\", 'port=3306', 'character-set-server=utf8mb4', 'collation-server=utf8mb4_unicode_ci', 'max_connections=100', 'innodb_buffer_pool_size=128M', '', '[client]', 'port=3306', 'default-character-set=utf8mb4') | Out-File -FilePath '%ISOTONE_PATH%\mariadb\my.ini' -Encoding ASCII"
    
    echo   [OK] MariaDB configuration created
)

REM Initialize MariaDB data directory if needed
if not exist "%ISOTONE_PATH%\mariadb\data\mysql" (
    echo   Initializing MariaDB data directory...
    cd /d "%ISOTONE_PATH%\mariadb\bin"
    if exist "mariadb-install-db.exe" (
        mariadb-install-db.exe --datadir="%ISOTONE_PATH%\mariadb\data" --default-user
    ) else if exist "mysql_install_db.exe" (
        mysql_install_db.exe --datadir="%ISOTONE_PATH%\mariadb\data" --default-user
    )
    cd /d "%ISOTONE_PATH%"
    echo   [OK] MariaDB data directory initialized
)

REM Configure phpMyAdmin
echo [5/5] Configuring phpMyAdmin...
if exist "%ISOTONE_PATH%\config\phpmyadmin.config.template" (
    echo   Using phpmyadmin.config.template from config folder...
    
    REM Replace template placeholders and copy in one step
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); (Get-Content '%ISOTONE_PATH%\config\phpmyadmin.config.template') -replace '{{INSTALL_PATH}}', \"$path\" -replace 'C:/isotone', \"$path\" | Set-Content '%ISOTONE_PATH%\phpmyadmin\config.inc.php'"
    
    REM Create tmp directory for phpMyAdmin
    if not exist "%ISOTONE_PATH%\phpmyadmin\tmp" mkdir "%ISOTONE_PATH%\phpmyadmin\tmp"
    
    echo   [OK] phpMyAdmin configuration applied from template
) else if not exist "%ISOTONE_PATH%\phpmyadmin\config.inc.php" (
    echo   Creating phpMyAdmin configuration...
    
    REM Create basic config.inc.php
    (
        echo ^<?php
        echo $cfg['blowfish_secret'] = 'IsotoneStack32CharacterSecretKey123456789012';
        echo.
        echo $i = 0;
        echo $i++;
        echo.
        echo $cfg['Servers'][$i]['verbose'] = 'IsotoneStack MariaDB';
        echo $cfg['Servers'][$i]['host'] = 'localhost';
        echo $cfg['Servers'][$i]['port'] = 3306;
        echo $cfg['Servers'][$i]['socket'] = '';
        echo $cfg['Servers'][$i]['auth_type'] = 'cookie';
        echo $cfg['Servers'][$i]['AllowNoPassword'] = true;
        echo.
        echo $cfg['UploadDir'] = '';
        echo $cfg['SaveDir'] = '';
        echo $cfg['TempDir'] = '%ISOTONE_PATH:\=/%/phpmyadmin/tmp';
        echo.
        echo $cfg['DefaultLang'] = 'en';
        echo $cfg['ServerDefault'] = 1;
        echo ?^>
    ) > "%ISOTONE_PATH%\phpmyadmin\config.inc.php"
    
    REM Create tmp directory for phpMyAdmin
    if not exist "%ISOTONE_PATH%\phpmyadmin\tmp" mkdir "%ISOTONE_PATH%\phpmyadmin\tmp"
    
    echo   [OK] phpMyAdmin configured
) else (
    echo   [OK] phpMyAdmin configuration exists
)

REM Create Apache alias for phpMyAdmin
echo.
echo Creating phpMyAdmin alias in Apache...
if not exist "%ISOTONE_PATH%\apache24\conf\extra\httpd-phpmyadmin.conf" (
    REM Create alias with dynamic paths
    powershell -Command "$path='%ISOTONE_PATH%'.Replace('\','/'); @('Alias /phpmyadmin \"' + $path + '/phpmyadmin\"', '', '<Directory \"' + $path + '/phpmyadmin\">', '    Options Indexes FollowSymLinks', '    AllowOverride All', '    Require all granted', '</Directory>') | Out-File -FilePath '%ISOTONE_PATH%\apache24\conf\extra\httpd-phpmyadmin.conf' -Encoding ASCII"
    
    REM Add include to httpd.conf if not already there
    findstr /C:"httpd-phpmyadmin.conf" "%ISOTONE_PATH%\apache24\conf\httpd.conf" >nul
    if errorlevel 1 (
        echo Include conf/extra/httpd-phpmyadmin.conf >> "%ISOTONE_PATH%\apache24\conf\httpd.conf"
    )
    
    echo   [OK] phpMyAdmin alias created
) else (
    echo   [OK] phpMyAdmin alias exists
)

echo.
echo ============================================
echo    Configuration Complete!
echo ============================================
echo.
echo All components have been configured successfully.
echo.
echo Configuration files:
echo   Apache:     apache24\conf\httpd.conf
echo   PHP:        php\php.ini
echo   MariaDB:    mariadb\my.ini
echo   phpMyAdmin: phpmyadmin\config.inc.php
echo.
echo Next steps:
echo   1. Run Register-Services.bat to register Windows services
echo   2. Run Start-Services.bat to start the services
echo   3. Access http://localhost to verify installation
echo.
pause