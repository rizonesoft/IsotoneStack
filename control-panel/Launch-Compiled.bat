@echo off
REM ==================================================================
REM Launch-Compiled.bat - Launcher for compiled Control Panel
REM Use Launch.bat to run the Python script version
REM ==================================================================
title IsotoneStack Control Panel (Compiled)
color 0A

REM Get paths
set SCRIPT_DIR=%~dp0
if "%SCRIPT_DIR:~-1%"=="\" set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

echo ============================================
echo    IsotoneStack Control Panel (Compiled)
echo ============================================
echo.

REM Check for single-file EXE first (preferred)
set EXE_PATH=%SCRIPT_DIR%\dist\IsotoneControlPanel.exe
if exist "%EXE_PATH%" (
    echo Launching single-file executable...
    start "" "%EXE_PATH%"
    timeout /t 2 /nobreak >nul
    exit /b 0
)

REM Check for folder-based EXE
set EXE_PATH=%SCRIPT_DIR%\dist\IsotoneControlPanel\IsotoneControlPanel.exe
if exist "%EXE_PATH%" (
    echo Launching folder-based executable...
    start "" "%EXE_PATH%"
    timeout /t 2 /nobreak >nul
    exit /b 0
)

REM No compiled version found
echo [ERROR] No compiled executable found!
echo.
echo Please build the executable first using:
echo   Build-ControlPanel.bat
echo.
echo Or run the Python script version using:
echo   Launch.bat
echo.
pause
exit /b 1