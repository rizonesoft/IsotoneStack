@echo off
REM IsotoneStack - Uninstall Windows Services
title IsotoneStack Uninstall Services
color 0E

echo ============================================
echo    IsotoneStack Service Uninstaller
echo ============================================
echo.
echo WARNING: This will remove IsotoneStack services from Windows.
echo          Your files and databases will NOT be deleted.
echo.
echo Press Ctrl+C to cancel or
pause

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

REM Get current directory (remove trailing backslash)
set ISOTONE_PATH=%~dp0
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%

echo Installation Path: %ISOTONE_PATH%
echo.

echo ============================================
echo    Stopping Services
echo ============================================
echo.

REM Stop services first
echo Stopping Apache service...
net stop IsotoneApache 2>nul
if %errorLevel% equ 0 (
    echo [OK] Apache stopped
) else (
    echo [INFO] Apache was not running
)

echo.
echo Stopping MariaDB service...
net stop IsotoneMariaDB 2>nul
if %errorLevel% equ 0 (
    echo [OK] MariaDB stopped
) else (
    echo [INFO] MariaDB was not running
)

echo.
echo ============================================
echo    Uninstalling Apache Service
echo ============================================
echo.

REM Check if Apache service exists
sc query IsotoneApache >nul 2>&1
if %errorLevel% equ 0 (
    echo Removing Apache service...
    
    REM Try httpd.exe uninstall first
    if exist "%ISOTONE_PATH%\apache24\bin\httpd.exe" (
        "%ISOTONE_PATH%\apache24\bin\httpd.exe" -k uninstall -n IsotoneApache >nul 2>&1
    )
    
    REM Then use sc delete as backup
    sc delete IsotoneApache >nul 2>&1
    
    if %errorLevel% equ 0 (
        echo [OK] Apache service removed successfully
    ) else (
        echo [WARNING] Had issues removing Apache service
    )
) else (
    echo [INFO] Apache service not found
)

echo.
echo ============================================
echo    Uninstalling MariaDB Service
echo ============================================
echo.

REM Check if MariaDB service exists
sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% equ 0 (
    echo Removing MariaDB service...
    
    REM Try mysqld.exe remove first
    if exist "%ISOTONE_PATH%\mariadb\bin\mysqld.exe" (
        "%ISOTONE_PATH%\mariadb\bin\mysqld.exe" --remove IsotoneMariaDB >nul 2>&1
    )
    
    REM Then use sc delete as backup
    sc delete IsotoneMariaDB >nul 2>&1
    
    if %errorLevel% equ 0 (
        echo [OK] MariaDB service removed successfully
    ) else (
        echo [WARNING] Had issues removing MariaDB service
    )
) else (
    echo [INFO] MariaDB service not found
)

echo.
echo ============================================
echo    Cleanup Complete
echo ============================================
echo.

REM Verify services are removed
echo Verifying removal...
echo.

sc query IsotoneApache >nul 2>&1
if %errorLevel% neq 0 (
    echo [OK] Apache service successfully removed
) else (
    echo [FAILED] Apache service still exists
)

sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% neq 0 (
    echo [OK] MariaDB service successfully removed
) else (
    echo [FAILED] MariaDB service still exists
)

echo.
echo ============================================
echo    Uninstallation Complete
echo ============================================
echo.
echo IsotoneStack services have been removed.
echo.
echo Your files remain in: %ISOTONE_PATH%
echo - Websites in: %ISOTONE_PATH%\www
echo - Databases in: %ISOTONE_PATH%\mariadb\data
echo - Configurations in: respective folders
echo.
echo To reinstall services, run: Register-Services.bat
echo To completely remove IsotoneStack, delete the folder: %ISOTONE_PATH%
echo.
pause