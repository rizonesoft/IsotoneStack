@echo off
REM IsotoneStack Installation Launcher
REM This batch file runs the PowerShell installation script with proper permissions

echo ============================================
echo    IsotoneStack Installation Launcher
echo ============================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This installer requires Administrator privileges.
    echo.
    echo Right-click on install.bat and select "Run as administrator"
    echo or press any key to attempt elevation...
    pause >nul
    
    REM Attempt to elevate
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Starting IsotoneStack installation...
echo Installation path: C:\isotone
echo.
echo Components to install:
echo   - Apache 2.4.62
echo   - PHP 8.3.15
echo   - MariaDB 11.4.4
echo   - phpMyAdmin 5.2.1
echo.
echo Press any key to continue or close this window to cancel...
pause >nul

REM Run the PowerShell installation script
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0Install-IsotoneStack.ps1"

if %errorLevel% equ 0 (
    echo.
    echo ============================================
    echo    Installation completed successfully!
    echo ============================================
    echo.
    echo Next steps:
    echo   1. Run start_services.bat to start all services
    echo   2. Open http://localhost in your browser
    echo   3. Access phpMyAdmin at http://localhost/phpmyadmin
    echo.
    echo Run manager.bat for the interactive control panel
    echo.
) else (
    echo.
    echo ============================================
    echo    Installation failed!
    echo ============================================
    echo.
    echo Please check the error messages above.
    echo You may need to:
    echo   - Ensure you have internet connection
    echo   - Check if ports 80 and 3306 are free
    echo   - Disable antivirus temporarily during installation
    echo.
)

pause