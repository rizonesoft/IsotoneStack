@echo off
REM IsotoneStack Control Panel - First Time Setup
REM Ensures clean installation of all dependencies

title IsotoneStack Control Panel Setup
color 0E

echo ============================================
echo    IsotoneStack Control Panel Setup
echo    First-Time Installation
echo ============================================
echo.
echo This script will:
echo   1. Check Python installation
echo   2. Create a fresh virtual environment
echo   3. Install all required packages
echo   4. Test the installation
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

REM Check for Python
echo.
echo Step 1: Checking Python installation...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH.
    echo.
    echo Please install Python 3.11 or later:
    echo   1. Download from https://python.org/downloads/
    echo   2. Run the installer
    echo   3. CHECK "Add Python to PATH" option!
    echo   4. Restart this script
    echo.
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [OK] Found Python %PYTHON_VERSION%

REM Remove old virtual environment if exists
if exist "venv" (
    echo.
    echo Step 2: Removing old virtual environment...
    rmdir /s /q venv 2>nul
    timeout /t 2 >nul
)

REM Create new virtual environment
echo.
echo Step 3: Creating fresh virtual environment...
python -m venv venv
if %errorLevel% neq 0 (
    echo [ERROR] Failed to create virtual environment.
    echo.
    echo Try these solutions:
    echo   1. Run as Administrator
    echo   2. Install virtualenv: python -m pip install --user virtualenv
    echo   3. Update Python to latest version
    pause
    exit /b 1
)
echo [OK] Virtual environment created

REM Activate virtual environment
echo.
echo Step 4: Activating virtual environment...
call venv\Scripts\activate.bat
if %errorLevel% neq 0 (
    echo [ERROR] Failed to activate virtual environment.
    pause
    exit /b 1
)
echo [OK] Virtual environment activated

REM Upgrade pip, setuptools, and wheel
echo.
echo Step 5: Upgrading pip and core packages...
echo   Upgrading pip to latest version...
python -m pip install --upgrade pip --no-warn-script-location
if %errorLevel% equ 0 (
    echo   [OK] pip upgraded successfully
) else (
    echo   [WARNING] pip upgrade failed, continuing with current version
)

echo   Upgrading setuptools and wheel...
python -m pip install --upgrade setuptools wheel --quiet --no-warn-script-location
echo [OK] Core packages upgraded

REM Install packages one by one with better error handling
echo.
echo Step 6: Installing required packages...
echo.

REM Install customtkinter
echo   Installing customtkinter...
python -m pip install customtkinter --no-cache-dir
if %errorLevel% neq 0 (
    echo   [RETRY] Attempting alternative installation for customtkinter...
    python -m pip install customtkinter==5.2.2 --no-deps
    python -m pip install darkdetect packaging
)

REM Install psutil
echo   Installing psutil...
python -m pip install psutil --no-cache-dir
if %errorLevel% neq 0 (
    echo   [WARNING] psutil installation failed - monitoring features will be limited
)

REM Install Pillow
echo   Installing Pillow...
python -m pip install Pillow --no-cache-dir
if %errorLevel% neq 0 (
    echo   [RETRY] Attempting alternative installation for Pillow...
    python -m pip install Pillow==10.2.0 --no-deps
)

REM Install pystray
echo   Installing pystray...
python -m pip install pystray --no-cache-dir
if %errorLevel% neq 0 (
    echo   [WARNING] pystray installation failed - system tray feature will be disabled
)

REM Install PyYAML
echo   Installing PyYAML...
python -m pip install PyYAML --no-cache-dir
if %errorLevel% neq 0 (
    echo   [RETRY] Attempting alternative installation for PyYAML...
    python -m pip install PyYAML==6.0.1 --no-deps
)

REM Install colorlog
echo   Installing colorlog...
python -m pip install colorlog --no-cache-dir
if %errorLevel% neq 0 (
    echo   [WARNING] colorlog installation failed - using standard logging
)

REM Install requests
echo   Installing requests...
python -m pip install requests --no-cache-dir
if %errorLevel% neq 0 (
    echo   [RETRY] Attempting alternative installation for requests...
    python -m pip install requests==2.31.0 --no-deps
    python -m pip install urllib3 certifi charset-normalizer idna
)

REM Install PyMySQL
echo   Installing PyMySQL...
python -m pip install PyMySQL --no-cache-dir
if %errorLevel% neq 0 (
    echo   [WARNING] PyMySQL installation failed - database features will be limited
)

REM Optional: Install pywin32 (may fail on some systems)
echo.
echo Step 7: Installing optional Windows components...
python -m pip install pywin32 --quiet 2>nul
if %errorLevel% equ 0 (
    echo [OK] Windows components installed
) else (
    echo [INFO] Windows components skipped (not critical)
)

REM Test imports
echo.
echo Step 8: Testing installation...
python -c "import customtkinter; print('  [OK] CustomTkinter imported successfully')" 2>nul
if %errorLevel% neq 0 (
    echo   [ERROR] CustomTkinter import failed
    echo   Trying one more time with force reinstall...
    python -m pip install --force-reinstall customtkinter
)

python -c "import psutil; print('  [OK] PSUtil imported successfully')" 2>nul
if %errorLevel% neq 0 (
    echo   [WARNING] PSUtil not available
)

python -c "import PIL; print('  [OK] Pillow imported successfully')" 2>nul
if %errorLevel% neq 0 (
    echo   [WARNING] Pillow not available
)

REM Final summary
echo.
echo ============================================
echo    Setup Summary
echo ============================================
echo.

REM Check which packages are actually installed
python -c "import pkg_resources; installed = {pkg.key for pkg in pkg_resources.working_set}; required = {'customtkinter', 'psutil', 'pillow', 'pystray', 'pyyaml', 'colorlog', 'requests', 'pymysql'}; found = required & installed; missing = required - installed; print(f'Installed: {len(found)}/{len(required)} packages'); [print(f'  [OK] {pkg}') for pkg in sorted(found)]; [print(f'  [MISSING] {pkg}') for pkg in sorted(missing)] if missing else None"

echo.
echo ============================================
echo    Setup Complete!
echo ============================================
echo.
echo You can now run the control panel using:
echo   launch.bat
echo.
echo Or directly with:
echo   venv\Scripts\activate
echo   python main.py
echo.
echo If packages failed to install, try:
echo   1. Run this script as Administrator
echo   2. Update Python to latest version
echo   3. Manually install with: pip install packagename
echo.
pause