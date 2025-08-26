@echo off
REM Test IsotoneStack Control Panel imports

title IsotoneStack Import Test
color 0E

echo ============================================
echo    Testing IsotoneStack Imports
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
call venv\Scripts\activate.bat

REM Run the test
python test_imports.py

echo.
pause