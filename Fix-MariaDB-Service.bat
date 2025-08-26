@echo off
setlocal EnableDelayedExpansion
REM ==================================================================
REM Fix MariaDB Service Registration
REM ==================================================================
title Fix MariaDB Service Registration
color 0E

echo ============================================
echo    Fix MariaDB Service Registration
echo ============================================
echo.

REM Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)

echo [OK] Running with Administrator privileges
echo.

set ISOTONE_PATH=%~dp0
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%

echo Installation path: %ISOTONE_PATH%
echo.

REM Step 1: Check for MariaDB executable
echo [STEP 1] Checking MariaDB executable...
if exist "%ISOTONE_PATH%\mariadb\bin\mariadbd.exe" (
    set MARIADB_EXE=mariadbd.exe
    set MARIADB_PATH=%ISOTONE_PATH%\mariadb\bin\mariadbd.exe
    echo [OK] Found mariadbd.exe
) else if exist "%ISOTONE_PATH%\mariadb\bin\mysqld.exe" (
    set MARIADB_EXE=mysqld.exe
    set MARIADB_PATH=%ISOTONE_PATH%\mariadb\bin\mysqld.exe
    echo [OK] Found mysqld.exe
) else (
    echo [ERROR] No MariaDB executable found!
    pause
    exit /b 1
)
echo.

REM Step 2: Remove any existing services
echo [STEP 2] Removing any existing MariaDB services...
sc delete IsotoneMariaDB >nul 2>&1
sc delete MariaDB >nul 2>&1
sc delete MySQL >nul 2>&1
"%MARIADB_PATH%" --remove IsotoneMariaDB >nul 2>&1
"%MARIADB_PATH%" --remove MariaDB >nul 2>&1
"%MARIADB_PATH%" --remove >nul 2>&1
echo [OK] Cleanup complete
echo.

REM Step 3: Check/Create my.ini
echo [STEP 3] Checking MariaDB configuration...
if not exist "%ISOTONE_PATH%\mariadb\my.ini" (
    echo [WARNING] my.ini not found, creating one...
    (
        echo [mysqld]
        echo basedir=%ISOTONE_PATH:\=/%/mariadb
        echo datadir=%ISOTONE_PATH:\=/%/mariadb/data
        echo port=3306
        echo character-set-server=utf8mb4
        echo collation-server=utf8mb4_unicode_ci
        echo max_connections=100
        echo innodb_buffer_pool_size=128M
        echo.
        echo [client]
        echo port=3306
        echo default-character-set=utf8mb4
    ) > "%ISOTONE_PATH%\mariadb\my.ini"
    echo [OK] Created my.ini
) else (
    echo [OK] my.ini exists
)
echo.

REM Step 4: Check data directory
echo [STEP 4] Checking MariaDB data directory...
if not exist "%ISOTONE_PATH%\mariadb\data" (
    echo [INFO] Creating data directory...
    mkdir "%ISOTONE_PATH%\mariadb\data"
)

if not exist "%ISOTONE_PATH%\mariadb\data\mysql" (
    echo [WARNING] Data directory not initialized
    echo [INFO] Initializing MariaDB data directory...
    
    cd /d "%ISOTONE_PATH%\mariadb\bin"
    
    REM Try different initialization commands based on what's available
    if exist "mariadb-install-db.exe" (
        echo Using mariadb-install-db.exe...
        mariadb-install-db.exe --datadir="%ISOTONE_PATH%\mariadb\data" --password=
    ) else if exist "mysql_install_db.exe" (
        echo Using mysql_install_db.exe...
        mysql_install_db.exe --datadir="%ISOTONE_PATH%\mariadb\data" --default-user
    ) else (
        echo Using mysqld/mariadbd --initialize-insecure...
        "%MARIADB_PATH%" --initialize-insecure --datadir="%ISOTONE_PATH%\mariadb\data"
    )
    
    cd /d "%ISOTONE_PATH%"
    
    if exist "%ISOTONE_PATH%\mariadb\data\mysql" (
        echo [OK] Data directory initialized
    ) else (
        echo [WARNING] Data initialization may have failed
    )
) else (
    echo [OK] Data directory already initialized
)
echo.

REM Step 5: Install service with different methods
echo [STEP 5] Installing MariaDB service...
echo.
echo Method 1: Using --install with defaults-file...
"%MARIADB_PATH%" --install IsotoneMariaDB --defaults-file="%ISOTONE_PATH%\mariadb\my.ini"

REM Check if service was created
sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Service installed successfully with Method 1
    goto :service_config
)

echo [INFO] Method 1 failed, trying Method 2...
echo.
echo Method 2: Using --install-manual...
"%MARIADB_PATH%" --install-manual IsotoneMariaDB --defaults-file="%ISOTONE_PATH%\mariadb\my.ini"

sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Service installed successfully with Method 2
    goto :service_config
)

echo [INFO] Method 2 failed, trying Method 3...
echo.
echo Method 3: Using sc create directly...
sc create IsotoneMariaDB binPath= "\"%MARIADB_PATH%\" --defaults-file=\"%ISOTONE_PATH%\mariadb\my.ini\" IsotoneMariaDB" DisplayName= "IsotoneStack MariaDB" start= manual

sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Service installed successfully with Method 3
    goto :service_config
)

echo [ERROR] All methods failed to install service
echo.
echo Trying one more method without service name in command...
"%MARIADB_PATH%" --install IsotoneMariaDB

sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Service installed successfully with simplified command
    goto :service_config
) else (
    echo [FAILED] Could not install MariaDB service
    echo.
    echo Please try the following manually:
    echo 1. Open Command Prompt as Administrator
    echo 2. Navigate to: %ISOTONE_PATH%\mariadb\bin
    echo 3. Run: %MARIADB_EXE% --install IsotoneMariaDB
    pause
    exit /b 1
)

:service_config
REM Step 6: Configure service
echo.
echo [STEP 6] Configuring service...
sc config IsotoneMariaDB start= demand >nul
echo [OK] Service set to manual start
echo.

REM Step 7: Test starting the service
echo [STEP 7] Testing service start...
net start IsotoneMariaDB
if %errorLevel% equ 0 (
    echo [OK] MariaDB service started successfully!
    net stop IsotoneMariaDB >nul
    echo [OK] Service stopped for clean state
) else (
    echo [WARNING] Service failed to start
    echo.
    echo Checking Windows Event Log for errors...
    echo.
    wevtutil qe System /q:"*[System[Provider[@Name='Service Control Manager']]]" /f:text /c:5 | findstr /i "isotonemariadb mariadb"
    echo.
    echo Attempting manual start for debugging...
    echo.
    start /B cmd /C ""%MARIADB_PATH%" --defaults-file="%ISOTONE_PATH%\mariadb\my.ini" --console 2>&1" > "%ISOTONE_PATH%\mariadb_debug.log" 2>&1
    timeout /t 3 /nobreak >nul
    taskkill /F /IM %MARIADB_EXE% >nul 2>&1
    
    if exist "%ISOTONE_PATH%\mariadb_debug.log" (
        echo Debug output:
        echo --------------
        type "%ISOTONE_PATH%\mariadb_debug.log"
        echo --------------
        del "%ISOTONE_PATH%\mariadb_debug.log"
    )
)

echo.
echo ============================================
echo    Final Status
echo ============================================
echo.

sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% equ 0 (
    echo [SUCCESS] IsotoneMariaDB service is registered!
    echo.
    echo You can now use:
    echo   - Start-Services.bat to start all services
    echo   - net start IsotoneMariaDB to start MariaDB only
) else (
    echo [FAILED] MariaDB service registration failed
    echo.
    echo Please run Diagnose-Services.bat for more details
)

echo.
pause