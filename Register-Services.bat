@echo off
REM IsotoneStack Service Registration Script
REM Registers Apache and MariaDB as Windows services

title IsotoneStack Service Registration
color 0E

echo ============================================
echo    IsotoneStack Service Registration
echo ============================================
echo.

REM Check for Administrator privileges and self-elevate if needed
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)

echo [OK] Running with Administrator privileges
echo.

REM Set installation path (use current directory)
set ISOTONE_PATH=%~dp0
REM Remove trailing backslash
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%

REM Check if Apache exists
if not exist "%ISOTONE_PATH%\apache24\bin\httpd.exe" (
    echo [ERROR] Apache not found at %ISOTONE_PATH%\apache24\bin\httpd.exe
    pause
    exit /b 1
)

REM Check if MariaDB exists (check for both mariadbd.exe and mysqld.exe)
if exist "%ISOTONE_PATH%\mariadb\bin\mariadbd.exe" (
    set MARIADB_EXE=mariadbd.exe
    set MARIADB_PATH=%ISOTONE_PATH%\mariadb\bin\mariadbd.exe
) else if exist "%ISOTONE_PATH%\mariadb\bin\mysqld.exe" (
    set MARIADB_EXE=mysqld.exe
    set MARIADB_PATH=%ISOTONE_PATH%\mariadb\bin\mysqld.exe
) else (
    echo [ERROR] MariaDB not found at %ISOTONE_PATH%\mariadb\bin\
    echo        Looking for mariadbd.exe or mysqld.exe
    pause
    exit /b 1
)

REM Register Apache Service
echo ============================================
echo    Registering Apache Service
echo ============================================
echo.

REM First, try to remove any existing service
echo Removing any existing Apache service...
"%ISOTONE_PATH%\apache24\bin\httpd.exe" -k uninstall -n IsotoneApache >nul 2>&1
sc delete IsotoneApache >nul 2>&1

echo.
echo Installing Apache service...
cd /d "%ISOTONE_PATH%\apache24\bin"
httpd.exe -k install -n IsotoneApache -f "%ISOTONE_PATH%\apache24\conf\httpd.conf"

if %errorLevel% equ 0 (
    echo [OK] Apache service installed
    sc config IsotoneApache start= demand >nul
    echo [OK] Apache service set to manual start
) else (
    echo [ERROR] Failed to install Apache service
    echo.
    echo Trying alternative method...
    "%ISOTONE_PATH%\apache24\bin\httpd.exe" -k install -n IsotoneApache -f "%ISOTONE_PATH%\apache24\conf\httpd.conf"
    if %errorLevel% equ 0 (
        echo [OK] Apache service installed (alternative method)
    ) else (
        echo [FAILED] Could not install Apache service
    )
)

REM Register MariaDB Service
echo.
echo ============================================
echo    Registering MariaDB Service
echo ============================================
echo.

REM First, try to remove any existing service
echo Removing any existing MariaDB service...
"%MARIADB_PATH%" --remove IsotoneMariaDB >nul 2>&1
sc delete IsotoneMariaDB >nul 2>&1

echo.
echo Installing MariaDB service...

REM Check if my.ini exists
if not exist "%ISOTONE_PATH%\mariadb\my.ini" (
    echo [INFO] Creating MariaDB configuration...
    
    REM Create necessary directories
    if not exist "%ISOTONE_PATH%\mariadb\data" mkdir "%ISOTONE_PATH%\mariadb\data"
    if not exist "%ISOTONE_PATH%\logs\mariadb" mkdir "%ISOTONE_PATH%\logs\mariadb"
    if not exist "%ISOTONE_PATH%\tmp" mkdir "%ISOTONE_PATH%\tmp"
    
    REM Check if template exists
    if exist "%ISOTONE_PATH%\config\my.ini.template" (
        echo [INFO] Using configuration template...
        powershell -Command "(Get-Content '%ISOTONE_PATH%\config\my.ini.template') -replace '{{INSTALL_PATH}}', '%ISOTONE_PATH:\=/%' | Set-Content '%ISOTONE_PATH%\mariadb\my.ini'"
    ) else (
        REM Fallback to creating directly
        (
            echo [mysqld]
            echo basedir=%ISOTONE_PATH:\=/%/mariadb
            echo datadir=%ISOTONE_PATH:\=/%/mariadb/data
            echo port=3306
            echo character-set-server=utf8mb4
            echo collation-server=utf8mb4_unicode_ci
            echo max_connections=100
            echo innodb_buffer_pool_size=256M
            echo innodb_log_file_size=48M
            echo skip-grant-tables
            echo log_error=%ISOTONE_PATH:\=/%/logs/mariadb/error.log
            echo.
            echo [client]
            echo port=3306
            echo default-character-set=utf8mb4
        ) > "%ISOTONE_PATH%\mariadb\my.ini"
    )
    echo [OK] MariaDB configuration created
)

"%MARIADB_PATH%" --install IsotoneMariaDB --defaults-file="%ISOTONE_PATH%\mariadb\my.ini"

if %errorLevel% equ 0 (
    echo [OK] MariaDB service installed
    sc config IsotoneMariaDB start= demand >nul
    echo [OK] MariaDB service set to manual start
) else (
    echo [WARNING] MariaDB service installation had issues
    echo          You may need to initialize the database first
)

REM Summary
echo.
echo ============================================
echo    Service Registration Summary
echo ============================================
echo.

sc query IsotoneApache >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] IsotoneApache service is registered
) else (
    echo [FAILED] IsotoneApache service is NOT registered
)

sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] IsotoneMariaDB service is registered
) else (
    echo [FAILED] IsotoneMariaDB service is NOT registered
)

echo.
echo ============================================
echo    Next Steps
echo ============================================
echo.
echo To start services:
echo   net start IsotoneApache
echo   net start IsotoneMariaDB
echo.
echo Or use:
echo   Start-Services.bat
echo.
pause
exit /b