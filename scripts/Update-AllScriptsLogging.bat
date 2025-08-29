@echo off
REM Update-AllScriptsLogging.bat
REM Launcher for Update-AllScriptsLogging.ps1
REM Updates all scripts to use the new settings-based logging system

setlocal enabledelayedexpansion

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Get parent directory (isotone root)
for %%i in ("%SCRIPT_DIR%") do set "ISOTONE_PATH=%%~dpi"
set "ISOTONE_PATH=%ISOTONE_PATH:~0,-1%"

REM Set paths
set "PWSH_PATH=%ISOTONE_PATH%\pwsh"
set "PWSH_EXE=%PWSH_PATH%\pwsh.exe"
set "PS1_SCRIPT=%SCRIPT_DIR%\Update-AllScriptsLogging.ps1"

REM Check if portable PowerShell exists
if not exist "%PWSH_EXE%" (
    echo [ERROR] Portable PowerShell not found at: %PWSH_EXE%
    echo Please ensure IsotoneStack is properly installed
    pause
    exit /b 1
)

REM Check if PS1 script exists
if not exist "%PS1_SCRIPT%" (
    echo [ERROR] PowerShell script not found: %PS1_SCRIPT%
    pause
    exit /b 1
)

REM Run the PowerShell script with all arguments passed through
echo Updating all scripts to use new logging system...
"%PWSH_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%PS1_SCRIPT%" %*

REM Capture exit code
set "EXIT_CODE=%ERRORLEVEL%"

REM Return the exit code
exit /b %EXIT_CODE%