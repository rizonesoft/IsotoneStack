@echo off
REM ==================================================================
REM Build-ControlPanel.bat - Builds the IsotoneStack Control Panel EXE
REM Uses PyInstaller to create a standalone executable
REM ==================================================================
title Build Control Panel - IsotoneStack

REM Get the directory of this script (control-panel folder)
set SCRIPT_DIR=%~dp0
if "%SCRIPT_DIR:~-1%"=="\" set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

REM Get isotone root (parent of control-panel folder)
for %%I in ("%SCRIPT_DIR%\..") do set ISOTONE_PATH=%%~fI

REM Derive script name from batch file name
set SCRIPT_NAME=%~n0
set SCRIPT_PATH=%SCRIPT_DIR%\%SCRIPT_NAME%.ps1
set PWSH_EXE=%ISOTONE_PATH%\pwsh\pwsh.exe

REM Check if the PowerShell script exists
if not exist "%SCRIPT_PATH%" (
    echo [ERROR] PowerShell script not found: %SCRIPT_PATH%
    pause
    exit /b 1
)

echo.
echo === Building IsotoneStack Control Panel ===
echo.

REM Check if portable PowerShell exists
if exist "%PWSH_EXE%" (
    REM Use portable PowerShell 7
    "%PWSH_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" %*
) else (
    REM Fallback to system PowerShell with warning
    echo [WARNING] PowerShell 7 not found at %PWSH_EXE%
    echo [WARNING] Using system PowerShell instead
    echo.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" %*
)

REM Keep window open on error
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Build failed with error code: %errorlevel%
    pause
)