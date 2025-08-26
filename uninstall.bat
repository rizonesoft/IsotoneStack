@echo off
REM Uninstall IsotoneStack

echo ============================================
echo    IsotoneStack Uninstaller
echo ============================================
echo.
echo WARNING: This will uninstall IsotoneStack services.
echo.
echo Choose an option:
echo   1. Uninstall services only (keep files)
echo   2. Complete removal (delete all files)
echo   3. Cancel
echo.

choice /C 123 /N /M "Select option (1-3): "

if %errorLevel% equ 3 (
    echo.
    echo Uninstall cancelled.
    pause
    exit /b
)

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo This uninstaller requires Administrator privileges.
    echo Attempting to elevate...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

if %errorLevel% equ 1 (
    echo.
    echo Uninstalling services only...
    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0control-panel\uninstall.ps1"
) else if %errorLevel% equ 2 (
    echo.
    echo Performing complete removal...
    echo.
    echo ARE YOU SURE? This will delete all IsotoneStack files!
    echo Press Ctrl+C to cancel or any other key to continue...
    pause >nul
    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0control-panel\uninstall.ps1" -RemoveData
)

echo.
echo Uninstall complete.
pause