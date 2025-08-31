@echo off
:: Secure-phpMyAdmin-ControlUser.bat - Launcher for PowerShell script
:: Generates and sets a secure random password for the phpMyAdmin control user

setlocal EnableDelayedExpansion

:: Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Get parent directory (isotone root)
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%i in ("%SCRIPT_DIR%") do set "ISOTONE_PATH=%%~dpi"
set "ISOTONE_PATH=%ISOTONE_PATH:~0,-1%"

:: Change to isotone directory
cd /d "%ISOTONE_PATH%"

:: Check if portable PowerShell exists
if not exist "pwsh\pwsh.exe" (
    echo [ERROR] Portable PowerShell not found at: %ISOTONE_PATH%\pwsh\pwsh.exe
    echo Please ensure IsotoneStack is properly installed.
    pause
    exit /b 1
)

:: Run PowerShell script with all arguments passed through
pwsh\pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "scripts\Secure-phpMyAdmin-ControlUser.ps1" %*

:: Check exit code
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Security update failed with exit code: %errorlevel%
    pause
    exit /b %errorlevel%
)

endlocal