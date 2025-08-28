@echo off
REM ==================================================================
REM Process Configuration Templates
REM ==================================================================
title Process Configuration Templates - IsotoneStack
color 0E

echo ============================================
echo    Process Configuration Templates
echo ============================================
echo.

set INSTALL_PATH_BS=C:\isotone
set INSTALL_PATH=C:/isotone

REM Derive other paths
set APACHE_PATH=%INSTALL_PATH%/apache24
set APACHE_PATH_BS=%INSTALL_PATH_BS%\apache24
set PHP_PATH=%INSTALL_PATH%/php
set PHP_PATH_BS=%INSTALL_PATH_BS%\php
set MARIADB_PATH=%INSTALL_PATH%/mariadb
set MARIADB_PATH_BS=%INSTALL_PATH_BS%\mariadb
set PHPMYADMIN_PATH=%INSTALL_PATH%/phpmyadmin
set PHPMYADMIN_PATH_BS=%INSTALL_PATH_BS%\phpmyadmin
set WWW_PATH=%INSTALL_PATH%/www
set WWW_PATH_BS=%INSTALL_PATH_BS%\www

REM Network settings
set SERVER_NAME=localhost
set SERVER_PORT=80
set MYSQL_PORT=3306
set ADMIN_EMAIL=admin@localhost

echo [Configuration Variables]
echo INSTALL_PATH:       %INSTALL_PATH%
echo INSTALL_PATH_BS:    %INSTALL_PATH_BS%
echo APACHE_PATH:        %APACHE_PATH%
echo PHP_PATH:           %PHP_PATH%
echo MARIADB_PATH:       %MARIADB_PATH%
echo SERVER_NAME:        %SERVER_NAME%
echo.

REM Process Apache configuration
if exist "%INSTALL_PATH_BS%\config\httpd.conf.template" (
    echo Processing httpd.conf.template...
    powershell -Command ^
        "$content = Get-Content '%INSTALL_PATH_BS%\config\httpd.conf.template'; ^
         $content = $content ^
            -replace '\{\{INSTALL_PATH\}\}', '%INSTALL_PATH%' ^
            -replace '\{\{INSTALL_PATH_BS\}\}', '%INSTALL_PATH_BS%' ^
            -replace '\{\{APACHE_PATH\}\}', '%APACHE_PATH%' ^
            -replace '\{\{PHP_PATH\}\}', '%PHP_PATH%' ^
            -replace '\{\{WWW_PATH\}\}', '%WWW_PATH%' ^
            -replace '\{\{SERVER_NAME\}\}', '%SERVER_NAME%' ^
            -replace '\{\{SERVER_PORT\}\}', '%SERVER_PORT%' ^
            -replace '\{\{ADMIN_EMAIL\}\}', '%ADMIN_EMAIL%'; ^
         Set-Content '%APACHE_PATH_BS%\conf\httpd.conf' $content"
    echo [OK] Processed httpd.conf
)

REM Process PHP configuration
if exist "%INSTALL_PATH_BS%\config\php.ini.template" (
    echo Processing php.ini.template...
    powershell -Command ^
        "$content = Get-Content '%INSTALL_PATH_BS%\config\php.ini.template'; ^
         $content = $content ^
            -replace '\{\{INSTALL_PATH\}\}', '%INSTALL_PATH%' ^
            -replace '\{\{INSTALL_PATH_BS\}\}', '%INSTALL_PATH_BS%' ^
            -replace '\{\{PHP_PATH\}\}', '%PHP_PATH%' ^
            -replace '\{\{PHP_PATH_BS\}\}', '%PHP_PATH_BS%'; ^
         Set-Content '%PHP_PATH_BS%\php.ini' $content"
    echo [OK] Processed php.ini
)

REM Process MariaDB configuration
if exist "%INSTALL_PATH_BS%\config\my.ini.template" (
    echo Processing my.ini.template...
    powershell -Command ^
        "$content = Get-Content '%INSTALL_PATH_BS%\config\my.ini.template'; ^
         $content = $content ^
            -replace '\{\{INSTALL_PATH\}\}', '%INSTALL_PATH%' ^
            -replace '\{\{MARIADB_PATH\}\}', '%MARIADB_PATH%' ^
            -replace '\{\{MYSQL_PORT\}\}', '%MYSQL_PORT%'; ^
         Set-Content '%MARIADB_PATH_BS%\my.ini' $content"
    echo [OK] Processed my.ini
)

echo.
echo ============================================
echo    Template Processing Complete
echo ============================================
echo.
pause