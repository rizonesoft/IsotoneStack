@echo off
:: INSTALL.bat - Master installation launcher for IsotoneStack
:: This script must be run as Administrator for full functionality

setlocal EnableDelayedExpansion

:: Display banner
echo.
echo ================================================================
echo                    IsotoneStack Installation
echo ================================================================
echo.

:: Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    echo.
    echo [WARNING] Administrator privileges are required for:
    echo   - Service registration
    echo   - Firewall configuration
    echo   - Auto-start setup
    echo.
    echo Press any key to request Administrator privileges...
    pause >nul
    powershell -Command "Start-Process '%~f0' %* -Verb RunAs"
    exit /b
)

echo [OK] Running with Administrator privileges
echo.

:: Get current directory (isotone root)
set "ISOTONE_PATH=%~dp0"
set "ISOTONE_PATH=%ISOTONE_PATH:~0,-1%"

:: Change to isotone directory
cd /d "%ISOTONE_PATH%"

:: Check if portable PowerShell exists
if not exist "pwsh\pwsh.exe" (
    echo [ERROR] Portable PowerShell not found at: %ISOTONE_PATH%\pwsh\pwsh.exe
    echo.
    echo IsotoneStack components appear to be missing.
    echo Please ensure you have extracted all files from the release package.
    echo.
    pause
    exit /b 1
)

:: Check if installation script exists
if not exist "scripts\Complete-Install.ps1" (
    echo [ERROR] Installation script not found at: %ISOTONE_PATH%\scripts\Complete-Install.ps1
    echo.
    echo Installation scripts appear to be missing.
    echo Please ensure you have extracted all files from the release package.
    echo.
    pause
    exit /b 1
)

:: Run PowerShell installation script with all arguments passed through
echo Starting IsotoneStack installation...
echo ----------------------------------------------------------------
echo.

pwsh\pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "scripts\Complete-Install.ps1" %*

:: Check exit code
set EXIT_CODE=%errorlevel%

if %EXIT_CODE% equ 0 (
    echo.
    echo ================================================================
    echo                  Installation Complete!
    echo ================================================================
    echo.
    echo IsotoneStack has been successfully installed.
    echo.
    echo You can now:
    echo   - Access your web server at: http://localhost/
    echo   - Access phpMyAdmin at: http://localhost/phpmyadmin/
    echo   - Place your web files in: %ISOTONE_PATH%\www
    echo.
    echo To manually control services:
    echo   - Start: scripts\Start-IsotoneStack.bat
    echo   - Stop:  scripts\Stop-IsotoneStack.bat
    echo.
) else (
    echo.
    echo ================================================================
    echo                  Installation Failed
    echo ================================================================
    echo.
    echo The installation encountered errors. Exit code: %EXIT_CODE%
    echo.
    echo Please check the log files in:
    echo   %ISOTONE_PATH%\logs\isotone\
    echo.
    echo You can try running the installation again with:
    echo   INSTALL.bat -Force
    echo.
)

echo Press any key to exit...
pause >nul

endlocal
exit /b %EXIT_CODE%