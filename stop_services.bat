@echo off
REM Stop IsotoneStack Services

echo Stopping IsotoneStack services...
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires Administrator privileges.
    echo Attempting to elevate...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0control-panel\stop.ps1"

echo.
echo Services stopped. Press any key to exit...
pause >nul