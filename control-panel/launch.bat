@echo off
REM IsotoneStack Control Panel GUI Launcher

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
    echo Python is not installed or not in PATH.
    echo Please install Python 3.11 or later from https://python.org
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    echo.
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install/upgrade requirements
echo Checking dependencies...
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo.
echo Starting IsotoneStack Control Panel...
echo.

REM Run the application
python main.py

REM If the app crashes, keep window open
if %errorLevel% neq 0 (
    echo.
    echo ============================================
    echo    Application crashed!
    echo    Check the logs folder for details.
    echo ============================================
    pause
)