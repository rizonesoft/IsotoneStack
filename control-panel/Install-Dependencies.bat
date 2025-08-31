@echo off
REM ==================================================================
REM Install-Dependencies.bat - Forwarder to scripts/python
REM This is a convenience shortcut - the actual script is in scripts/python
REM ==================================================================

REM Get the directory of this script (control-panel folder)
set SCRIPT_DIR=%~dp0
if "%SCRIPT_DIR:~-1%"=="\" set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

REM Get isotone root (parent of control-panel folder)
for %%I in ("%SCRIPT_DIR%\..") do set ISOTONE_PATH=%%~fI

REM Forward to the actual script in scripts/python
set TARGET_SCRIPT=%ISOTONE_PATH%\scripts\python\Install-Dependencies.bat

if not exist "%TARGET_SCRIPT%" (
    echo [ERROR] Script not found: %TARGET_SCRIPT%
    echo Please ensure IsotoneStack scripts are properly installed
    pause
    exit /b 1
)

REM Run the actual script with all arguments
call "%TARGET_SCRIPT%" %*
exit /b %errorlevel%