@echo off
REM IsotoneStack Setup - Admin Launcher (Alternative Method)
REM Uses PowerShell to self-elevate

title IsotoneStack Setup
color 0E

echo ============================================
echo    IsotoneStack Setup Launcher
echo ============================================
echo.

REM Check if we have Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    REM Already Administrator - run the setup
    echo [OK] Administrator privileges confirmed
    echo.
    echo Running IsotoneStack setup...
    echo.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-IsotoneStack.ps1"
    pause
    exit /b
)

REM Not Administrator - request elevation
echo This script requires Administrator privileges.
echo.
echo Launching with Administrator rights...
echo.

REM Use PowerShell to elevate and run the setup script
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0Setup-IsotoneStack.ps1""' -Verb RunAs"

echo.
echo Setup has been launched in an elevated window.
echo.
echo This window will close in 5 seconds...
timeout /t 5 >nul
exit