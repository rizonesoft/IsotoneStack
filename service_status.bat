@echo off
REM Check IsotoneStack Service Status

echo IsotoneStack Service Status
echo ============================
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0control-panel\status.ps1"

echo.
pause