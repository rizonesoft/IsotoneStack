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
    echo [ERROR] Python is not installed or not in PATH.
    echo.
    echo Please install Python 3.11 or later from https://python.org
    echo Make sure to check "Add Python to PATH" during installation.
    echo.
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist "venv" (
    echo First time setup detected.
    echo Please run: setup_first_time.bat
    echo.
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Quick check for customtkinter
python -c "import customtkinter" 2>nul
if %errorLevel% neq 0 (
    echo.
    echo [WARNING] Dependencies not installed properly.
    echo Installing core dependencies...
    echo.
    echo Upgrading pip first...
    python -m pip install --upgrade pip
    echo.
    echo Installing required packages...
    python -m pip install customtkinter psutil Pillow pystray PyYAML colorlog requests
    echo.
)

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
    echo ============================================
    echo.
    echo Try running: setup_first_time.bat
    echo Or use: launch_improved.bat
    echo.
    pause
)