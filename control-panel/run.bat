@echo off
REM Direct launcher for IsotoneStack Control Panel

title IsotoneStack Control Panel
color 0A

echo Starting IsotoneStack Control Panel...
echo.

REM Activate virtual environment and run
call venv\Scripts\activate.bat && python main.py

if %errorLevel% neq 0 (
    echo.
    echo Application exited with error.
    pause
)