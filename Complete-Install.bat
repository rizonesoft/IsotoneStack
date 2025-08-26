@echo off
REM ============================================
REM IsotoneStack Complete Installation Script
REM ============================================
REM This script handles the complete setup process

title IsotoneStack Installation
color 0E
cls

echo.
echo  ___           _                   ____  _             _    
echo ^|_ _^|___  ___ ^| ^|_ ___  _ __   ___/ ___^|^| ^|_ __ _  ___^| ^| __
echo  ^| ^|/ __^|/ _ \^| __/ _ \^| '_ \ / _ \___ \^| __/ _` ^|/ __^| ^|/ /
echo  ^| ^|\__ \ (_) ^| ^|^|  (_) ^| ^| ^| ^|  __/___) ^| ^|^| (_^| ^| (__^|   ^< 
echo ^|___^|___/\___/ \__\___/^|_^| ^|_^|\___)____/ \__\__,_^|\___^|_^|\_\
echo.
echo          Professional Development Environment for Windows
echo ============================================
echo.

REM Check current directory
echo Installation Directory: %~dp0
echo.

REM Check for required components
echo Checking components...
echo.

set MISSING=0

if not exist "%~dp0apache24\bin\httpd.exe" (
    echo   [MISSING] Apache - Please extract Apache to apache24\
    set MISSING=1
) else (
    echo   [OK] Apache found
)

if not exist "%~dp0php\php.exe" (
    echo   [MISSING] PHP - Please extract PHP to php\
    set MISSING=1
) else (
    echo   [OK] PHP found
)

if not exist "%~dp0mariadb\bin\mysqld.exe" (
    echo   [MISSING] MariaDB - Please extract MariaDB to mariadb\
    set MISSING=1
) else (
    echo   [OK] MariaDB found
)

if not exist "%~dp0phpmyadmin\index.php" (
    echo   [MISSING] phpMyAdmin - Please extract phpMyAdmin to phpmyadmin\
    set MISSING=1
) else (
    echo   [OK] phpMyAdmin found
)

if not exist "%~dp0runtime\vc_redist.x64.exe" (
    echo   [WARNING] VC++ Runtime installer not found in runtime\
    echo             You may need to install it manually
) else (
    echo   [OK] VC++ Runtime installer found
)

echo.

if %MISSING% == 1 (
    echo ============================================
    echo    Components Missing!
    echo ============================================
    echo.
    echo Please download and extract the following:
    echo.
    echo 1. Apache 2.4.65+ to:   %~dp0apache24\
    echo 2. PHP 8.4.11+ to:      %~dp0php\
    echo 3. MariaDB 12.0.2+ to:  %~dp0mariadb\
    echo 4. phpMyAdmin 5.2.2+ to: %~dp0phpmyadmin\
    echo.
    echo Download from:
    echo   Apache: https://www.apachelounge.com/download/
    echo   PHP:    https://windows.php.net/download/
    echo   MariaDB: https://mariadb.org/download/
    echo   phpMyAdmin: https://www.phpmyadmin.net/downloads/
    echo.
    pause
    exit /b 1
)

echo ============================================
echo    Ready to Install
echo ============================================
echo.
echo This will:
echo   1. Install VC++ Runtime (if needed)
echo   2. Configure all components
echo   3. Register Windows services
echo   4. Create helper scripts
echo   5. Set up the Control Panel
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

REM Check for Administrator privileges
echo.
echo Checking Administrator privileges...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ============================================
    echo    Administrator Privileges Required
    echo ============================================
    echo.
    echo This installer needs Administrator rights to:
    echo   - Install Windows services
    echo   - Configure system components
    echo   - Install VC++ Runtime
    echo.
    echo Restarting with Administrator privileges...
    echo.
    
    REM Create elevation script
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo [OK] Running with Administrator privileges
echo.

REM Run the main setup script
echo ============================================
echo    Running Setup Script
echo ============================================
echo.

REM Ensure we're in the right directory
cd /d "%~dp0"

REM Run PowerShell setup script
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Setup-IsotoneStack.ps1"

if %errorLevel% neq 0 (
    echo.
    echo ============================================
    echo    Setup Failed
    echo ============================================
    echo.
    echo The setup script encountered errors.
    echo Please check the messages above.
    echo.
    pause
    exit /b 1
)

REM Setup Control Panel
echo.
echo ============================================
echo    Setting Up Control Panel
echo ============================================
echo.
echo Would you like to set up the Python Control Panel? (Y/N)
set /p SETUP_CP=

if /i "%SETUP_CP%"=="Y" (
    echo.
    echo Setting up Control Panel...
    cd /d "%~dp0control-panel"
    call setup_first_time.bat
    cd /d "%~dp0"
)

REM Success message
echo.
echo ============================================
echo    Installation Complete!
echo ============================================
echo.
echo IsotoneStack has been successfully installed!
echo.
echo Quick Start Commands:
echo   Start Services:  Start-Services.ps1
echo   Stop Services:   Stop-Services.ps1
echo   Check Status:    Check-Status.ps1
echo   Control Panel:   control-panel\launch.bat
echo.
echo Access Points:
echo   Web Server:      http://localhost
echo   phpMyAdmin:      http://localhost/phpmyadmin
echo   Database:        localhost:3306
echo.
echo Default Credentials:
echo   MariaDB root:    (no password initially)
echo.
echo Thank you for choosing IsotoneStack!
echo.
pause