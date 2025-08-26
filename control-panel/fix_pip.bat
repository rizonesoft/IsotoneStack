@echo off
REM Quick fix for pip and dependency issues

title Fix Pip and Dependencies
color 0B

echo ============================================
echo    Fixing Pip and Dependencies
echo ============================================
echo.

REM Check if venv exists
if not exist "venv" (
    echo Virtual environment not found!
    echo Please run: setup_first_time.bat
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Show current pip version
echo.
echo Current pip version:
python -m pip --version
echo.

REM Upgrade pip
echo Upgrading pip to latest version...
echo ----------------------------------------
python -m pip install --upgrade pip

REM Check if upgrade was successful
echo.
echo New pip version:
python -m pip --version
echo.

REM Upgrade setuptools and wheel
echo Upgrading setuptools and wheel...
python -m pip install --upgrade setuptools wheel

REM Reinstall core dependencies
echo.
echo Reinstalling core dependencies...
echo ----------------------------------------

set packages=customtkinter psutil Pillow pystray PyYAML colorlog requests PyMySQL python-dotenv

for %%p in (%packages%) do (
    echo Installing %%p...
    python -m pip install --upgrade %%p
)

REM Test imports
echo.
echo ----------------------------------------
echo Testing installations...
echo ----------------------------------------

python -c "import customtkinter; print('✓ CustomTkinter OK')"
python -c "import psutil; print('✓ PSUtil OK')"
python -c "import PIL; print('✓ Pillow OK')"
python -c "import pystray; print('✓ PyStray OK')"
python -c "import yaml; print('✓ PyYAML OK')"
python -c "import colorlog; print('✓ ColorLog OK')"
python -c "import requests; print('✓ Requests OK')"

echo.
echo ============================================
echo    Fix Complete!
echo ============================================
echo.
echo You can now run: launch.bat
echo.
pause