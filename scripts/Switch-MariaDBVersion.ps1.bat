@echo off
REM Switch-MariaDBVersion.ps1.bat
REM Launcher for Switch-MariaDBVersion.ps1

REM Check for Administrator privileges (needed for symlink creation)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' '%*' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)

REM Get the script directory
set "SCRIPT_DIR=%~dp0"
set "ISOTONE_DIR=%SCRIPT_DIR%.."

REM Use portable PowerShell
set "PWSH=%ISOTONE_DIR%\pwsh\pwsh.exe"

REM Check for version argument
if "%~1"=="" (
    echo.
    echo Usage: Switch-MariaDBVersion.ps1.bat VERSION [-NoRestart]
    echo.
    echo Available versions:
    for /d %%v in ("%ISOTONE_DIR%\mariadb\*.*.*") do (
        echo   - %%~nv%%~xv
    )
    echo.
    exit /b 1
)

REM Run the PowerShell script
"%PWSH%" -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Switch-MariaDBVersion.ps1" %*

pause
