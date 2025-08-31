@echo off
REM ==================================================================
REM _Template.ps1.bat - Template batch launcher for PowerShell scripts
REM Use this template when creating new PowerShell script launchers
REM ==================================================================

REM Get paths
set SCRIPT_DIR=%~dp0
if "%SCRIPT_DIR:~-1%"=="\" set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
for %%I in ("%SCRIPT_DIR%\..") do set ISOTONE_PATH=%%~fI

REM Set PowerShell paths - prefer portable PowerShell
set PWSH_PATH=%ISOTONE_PATH%\pwsh
set PWSH_EXE=%PWSH_PATH%\pwsh.exe

REM Get the PowerShell script name (same as batch file name but with .ps1 extension)
set SCRIPT_NAME=%~n0
set PS_SCRIPT=%SCRIPT_DIR%\%SCRIPT_NAME%.ps1

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo [ERROR] PowerShell script not found: %PS_SCRIPT%
    pause
    exit /b 1
)

REM Check for portable PowerShell first
if exist "%PWSH_EXE%" (
    REM Use portable PowerShell 7
    "%PWSH_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
) else (
    REM Fall back to system PowerShell
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
)

REM Check exit code
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Script failed with exit code %errorlevel%
    pause
    exit /b %errorlevel%
)