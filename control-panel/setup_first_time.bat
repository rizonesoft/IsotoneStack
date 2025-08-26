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
python -m pip install --upgrade pip
if %errorLevel% equ 0 (
    echo   [OK] pip upgraded successfully
) else (
    echo   [WARNING] pip upgrade failed, continuing with current version
)

echo   Upgrading setuptools and wheel...
python -m pip install --upgrade setuptools wheel --quiet
echo [OK] Core packages upgraded

REM Create minimal requirements file
echo.
echo Step 6: Creating minimal requirements...
(
echo # Minimal requirements for IsotoneStack Control Panel
echo customtkinter==5.2.2
echo psutil==5.9.8
echo Pillow==10.2.0
echo pystray==0.19.5
echo PyYAML==6.0.1
echo colorlog==6.8.0
echo requests==2.31.0
echo PyMySQL==1.1.0
) > requirements_minimal.txt

REM Install packages one by one
echo.
echo Step 7: Installing required packages...
echo.

set packages=customtkinter psutil Pillow pystray PyYAML colorlog requests PyMySQL

for %%p in (%packages%) do (
    echo   Installing %%p...
    python -m pip install %%p --quiet
    if !errorLevel! equ 0 (
        echo   [OK] %%p installed
    ) else (
        echo   [WARNING] %%p failed - will retry
        python -m pip install %%p --no-deps --quiet
    )
)

REM Optional: Install pywin32 (may fail on some systems)
echo.
echo Step 8: Installing optional Windows components...
python -m pip install pywin32 --quiet 2>nul
if %errorLevel% equ 0 (
    echo [OK] Windows components installed
) else (
    echo [INFO] Windows components skipped (not critical)
)

REM Test imports
echo.
echo Step 9: Testing installation...
python -c "import customtkinter; print('[OK] CustomTkinter imported successfully')" 2>nul
if %errorLevel% neq 0 (
    echo [ERROR] CustomTkinter import failed
    echo Trying alternative installation method...
    python -m pip install customtkinter --force-reinstall --no-cache-dir
)

python -c "import psutil; print('[OK] PSUtil imported successfully')" 2>nul
if %errorLevel% neq 0 (
    echo [WARNING] PSUtil import failed - resource monitoring will be limited
)

REM Create test script
echo.
echo Step 10: Running test...
(
echo import sys
echo print(f"Python: {sys.version}"^)
echo print(f"Path: {sys.executable}"^)
echo try:
echo     import customtkinter
echo     print("CustomTkinter: OK"^)
echo except ImportError as e:
echo     print(f"CustomTkinter: FAILED - {e}"^)
echo try:
echo     import psutil
echo     print("PSUtil: OK"^)
echo except ImportError as e:
echo     print(f"PSUtil: FAILED - {e}"^)
) > test_imports.py

python test_imports.py
del test_imports.py

echo.
echo ============================================
echo    Setup Complete!
echo ============================================
echo.
echo You can now run the control panel using:
echo   launch.bat (original launcher)
echo   launch_improved.bat (improved launcher)
echo.
echo Or directly with:
echo   venv\Scripts\activate
echo   python main.py
echo.
pause