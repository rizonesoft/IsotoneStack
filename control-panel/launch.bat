@echo off
REM ==================================================================
REM Launch.bat - Quick launcher for Control Panel (Python script)
REM Use Launch-Compiled.bat to run the compiled executable
REM ==================================================================
title IsotoneStack Control Panel
color 0A

REM Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)

REM Get paths
set SCRIPT_DIR=%~dp0
if "%SCRIPT_DIR:~-1%"=="\" set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
for %%I in ("%SCRIPT_DIR%\..") do set ISOTONE_PATH=%%~fI

REM Set Python paths - ALWAYS prefer embedded Python
set PYTHON_PATH=%ISOTONE_PATH%\python
set PYTHON_EXE=%PYTHON_PATH%\python.exe

REM Check for control_panel.py first, then fall back to main.py
if exist "%SCRIPT_DIR%\control_panel.py" (
    set SCRIPT_FILE=control_panel.py
) else if exist "%SCRIPT_DIR%\main.py" (
    set SCRIPT_FILE=main.py
) else (
    echo [ERROR] No Python script found!
    echo Expected control_panel.py or main.py in %SCRIPT_DIR%
    pause
    exit /b 1
)

echo ============================================
echo    IsotoneStack Control Panel
echo ============================================
echo.
echo Launching %SCRIPT_FILE%...
echo.

REM Check for embedded Python first
if exist "%PYTHON_EXE%" (
    echo Using embedded Python: %PYTHON_PATH%
    "%PYTHON_EXE%" "%SCRIPT_DIR%\%SCRIPT_FILE%"
) else (
    echo [WARNING] Embedded Python not found at %PYTHON_PATH%
    echo Falling back to system Python...
    
    REM Check for system Python
    python --version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] No Python found! Please either:
        echo   1. Download Python embeddable package to %PYTHON_PATH%
        echo   2. Install Python system-wide
        echo.
        pause
        exit /b 1
    )
    
    REM Run with system Python
    python "%SCRIPT_DIR%\%SCRIPT_FILE%"
)

REM After Python exits
echo.
if errorlevel 1 (
    echo [ERROR] Control Panel failed to start
    echo.
    
    REM Check if it might be a dependency issue
    echo If you see import errors above (ModuleNotFoundError or ImportError),
    echo you need to install the required Python dependencies.
    echo.
    echo ============================================
    echo    SOLUTION: Install Dependencies
    echo ============================================
    echo.
    echo Run ONE of these commands:
    echo.
    echo Option 1 - From control-panel folder:
    echo    Install-Dependencies.bat
    echo.
    echo Option 2 - From anywhere:
    echo    %ISOTONE_PATH%\scripts\python\Install-Dependencies.bat
    echo.
    echo For development tools (optional):
    echo    Install-DevDependencies.bat
    echo.
    pause
) else (
    echo Control Panel closed.
    pause
)