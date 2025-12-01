@echo off
REM Launcher for Reinitialize-MariaDB.ps1 script
REM Requires Administrator privileges

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "ISOTONE_ROOT=%SCRIPT_DIR%.."

REM Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

REM Run the PowerShell script
"%ISOTONE_ROOT%\pwsh\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Reinitialize-MariaDB.ps1"

REM Pause to see results
pause
