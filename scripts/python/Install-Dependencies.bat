@echo off
REM ==================================================================
REM Install-Dependencies.bat - Install Python dependencies for Control Panel
REM Located in scripts/python for better organization
REM ==================================================================
title Install Dependencies - IsotoneStack Control Panel

REM Get the directory of this script (scripts/python folder)
set SCRIPT_DIR=%~dp0
if "%SCRIPT_DIR:~-1%"=="\" set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

REM Get isotone root (parent of parent of scripts/python folder)
for %%I in ("%SCRIPT_DIR%\..\..") do set ISOTONE_PATH=%%~fI

REM Derive script name from batch file name
set SCRIPT_NAME=%~n0
set SCRIPT_PATH=%SCRIPT_DIR%\%SCRIPT_NAME%.py
set PYTHON_EXE=%ISOTONE_PATH%\python\python.exe

REM Check if the Python script exists
if not exist "%SCRIPT_PATH%" (
    echo [ERROR] Python script not found: %SCRIPT_PATH%
    pause
    exit /b 1
)

echo.
echo === %SCRIPT_NAME% ===
echo.

REM Check for embedded Python first (ALWAYS prefer this)
if exist "%PYTHON_EXE%" (
    echo [SUCCESS] Found embedded Python: %PYTHON_EXE%
    REM Use embedded Python
    "%PYTHON_EXE%" "%SCRIPT_PATH%" %*
) else (
    REM Fallback to system Python with warning
    echo [WARNING] Embedded Python not found at %PYTHON_EXE%
    echo [WARNING] Using system Python instead
    echo.
    
    REM Check if system Python exists
    where python >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] No Python found!
        echo Please download Python to: %ISOTONE_PATH%\python
        echo Or install Python system-wide
        pause
        exit /b 1
    )
    
    python "%SCRIPT_PATH%" %*
)

REM Keep window open on error
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Script failed with error code: %errorlevel%
    pause
)