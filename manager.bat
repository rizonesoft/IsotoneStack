@echo off
REM IsotoneStack Interactive Manager

title IsotoneStack Manager
color 0B

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ============================================
    echo    IsotoneStack Manager
    echo ============================================
    echo.
    echo This manager requires Administrator privileges for full functionality.
    echo Some features may not work without admin rights.
    echo.
    echo Press any key to attempt elevation...
    pause >nul
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

REM Launch the interactive manager
powershell.exe -ExecutionPolicy Bypass -NoProfile -NoExit -File "%~dp0control-panel\IsotoneStack-Manager.ps1"