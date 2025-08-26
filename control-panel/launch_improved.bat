@echo off
REM IsotoneStack Control Panel GUI Launcher - Improved Version
REM Handles dependency issues gracefully

title IsotoneStack Control Panel
color 0A

echo ============================================
echo    IsotoneStack Control Panel
echo    Modern GUI for Service Management
echo ============================================
echo.

REM Check for Python
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH.
    echo.
    echo Please install Python 3.11 or later from:
    echo https://python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation!
    echo.
    pause
    exit /b 1
)

REM Get Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo Found Python %PYTHON_VERSION%
echo.

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    if %errorLevel% neq 0 (
        echo [ERROR] Failed to create virtual environment.
        echo Try running: python -m pip install --user virtualenv
        pause
        exit /b 1
    )
    echo Virtual environment created successfully.
    echo.
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat
if %errorLevel% neq 0 (
    echo [ERROR] Failed to activate virtual environment.
    pause
    exit /b 1
)

REM Upgrade pip first (separately and visibly)
echo Updating pip to latest version...
python -m pip install --upgrade pip
if %errorLevel% equ 0 (
    echo [OK] pip upgraded successfully
    echo.
) else (
    echo [WARNING] Could not upgrade pip, continuing with current version
    echo.
)

REM Install/upgrade requirements one by one to handle errors better
echo Installing dependencies...
echo.

REM Core requirements that must be installed
set CORE_PACKAGES=customtkinter psutil Pillow pystray PyYAML python-dotenv colorlog requests

for %%p in (%CORE_PACKAGES%) do (
    echo Installing %%p...
    python -m pip install --upgrade %%p --quiet
    if !errorLevel! neq 0 (
        echo [WARNING] Issue installing %%p, trying without upgrade...
        python -m pip install %%p --quiet
    )
)

REM Try to install pywin32 (might fail on some systems)
echo Installing Windows-specific packages...
python -m pip install pywin32 --quiet 2>nul
if %errorLevel% neq 0 (
    echo [WARNING] pywin32 installation failed - some features may be limited
)

REM Install PyMySQL for database connectivity
echo Installing database connector...
python -m pip install PyMySQL --quiet 2>nul

echo.
echo All critical dependencies installed.
echo.
echo Starting IsotoneStack Control Panel...
echo.

REM Run the application
python main.py

REM If the app crashes, show detailed error
if %errorLevel% neq 0 (
    echo.
    echo ============================================
    echo    Application crashed!
    echo ============================================
    echo.
    echo Possible solutions:
    echo   1. Make sure all IsotoneStack services are installed
    echo   2. Run this launcher as Administrator
    echo   3. Check the logs folder for details
    echo   4. Try running: python -m pip install -r requirements.txt
    echo.
    echo If issues persist, try the setup script: setup_first_time.bat
    echo.
    pause
)