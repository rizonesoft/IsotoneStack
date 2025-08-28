@echo off
REM Batch launcher for Install-VCRedist.ps1
REM Installs Visual C++ Redistributables required for PHP 8.4

echo ========================================
echo Visual C++ Redistributable Installer
echo ========================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires Administrator privileges.
    echo.
    echo Requesting elevation...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

REM Run the PowerShell script with portable PowerShell
cd /d "%~dp0\.."
if exist "pwsh\pwsh.exe" (
    pwsh\pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "scripts\Install-VCRedist.ps1" %*
) else if exist "C:\isotone\pwsh\pwsh.exe" (
    C:\isotone\pwsh\pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "scripts\Install-VCRedist.ps1" %*
) else (
    echo [ERROR] Portable PowerShell not found!
    echo Please ensure IsotoneStack is properly installed.
    pause
    exit /b 1
)

pause