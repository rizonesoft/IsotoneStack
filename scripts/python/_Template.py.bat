@echo off
REM ==================================================================
REM _Template.bat - Template launcher for Python scripts
REM Copy and rename to match your .py script name
REM ==================================================================
title Script Name - IsotoneStack

REM Get the directory of this script (scripts folder)
set SCRIPT_DIR=%~dp0
if "%SCRIPT_DIR:~-1%"=="\" set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

REM Get isotone root (parent of scripts folder)
for %%I in ("%SCRIPT_DIR%\..") do set ISOTONE_PATH=%%~fI

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

REM Check if this script needs admin privileges
REM Uncomment the following lines if admin is required:
REM net session >nul 2>&1
REM if %errorlevel% neq 0 (
REM     echo Requesting Administrator privileges...
REM     powershell -Command "Start-Process '%~f0' -ArgumentList '%*' -Verb RunAs"
REM     exit /b
REM )

echo.
echo === %SCRIPT_NAME% ===
echo.

REM Check for embedded Python first (ALWAYS prefer this)
if exist "%PYTHON_EXE%" (
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
        echo Please download Python embeddable package to: %ISOTONE_PATH%\python
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