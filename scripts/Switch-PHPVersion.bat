@echo off
REM Switch-PHPVersion.bat
REM Launcher for Switch-PHPVersion.ps1

setlocal EnableDelayedExpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Get isotone root (parent of scripts folder)
for %%I in ("%SCRIPT_DIR%") do set "ISOTONE_ROOT=%%~dpI"
set "ISOTONE_ROOT=%ISOTONE_ROOT:~0,-1%"

REM Path to portable PowerShell
set "PWSH_PATH=%ISOTONE_ROOT%\pwsh\pwsh.exe"

REM Check if portable PowerShell exists
if not exist "%PWSH_PATH%" (
    echo [ERROR] Portable PowerShell not found at: %PWSH_PATH%
    echo Please ensure pwsh folder exists in IsotoneStack root
    pause
    exit /b 1
)

REM Path to PowerShell script
set "PS_SCRIPT=%SCRIPT_DIR%\Switch-PHPVersion.ps1"

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo [ERROR] PowerShell script not found at: %PS_SCRIPT%
    pause
    exit /b 1
)

REM Check if version parameter was provided
if "%~1"=="" (
    echo Usage: Switch-PHPVersion.bat VERSION
    echo Example: Switch-PHPVersion.bat 8.4.15
    echo.
    echo Available versions:
    dir /b "%ISOTONE_ROOT%\php" 2>nul
    pause
    exit /b 1
)

REM Run PowerShell script with portable PowerShell
"%PWSH_PATH%" -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -Version "%~1"

REM Check exit code
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Script failed with error code: %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

echo.
pause
