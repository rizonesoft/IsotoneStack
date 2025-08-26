@echo off
REM Fix permissions for Control Panel installation
title Fix Control Panel Permissions
color 0E

echo ============================================
echo    Fix Control Panel Permissions
echo ============================================
echo.

REM Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires Administrator privileges.
    echo Restarting with Administrator rights...
    echo.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo [OK] Running with Administrator privileges
echo.

REM Fix permissions on venv directory
echo Fixing permissions on virtual environment...
icacls "%~dp0venv" /grant:r "%USERNAME%:(OI)(CI)F" /T /Q
echo [OK] Permissions fixed for venv directory
echo.

REM Remove problematic packages
echo Cleaning partial installations...
rd /s /q "%~dp0venv\Lib\site-packages\customtkinter" 2>nul
rd /s /q "%~dp0venv\Lib\site-packages\PIL" 2>nul
rd /s /q "%~dp0venv\Lib\site-packages\psutil" 2>nul
echo [OK] Cleaned partial installations
echo.

REM Reinstall packages
echo Reinstalling packages with proper permissions...
echo.

call "%~dp0venv\Scripts\activate.bat"

echo Installing customtkinter...
pip install --force-reinstall --no-cache-dir customtkinter
if %errorLevel% equ 0 (
    echo [OK] customtkinter installed
) else (
    echo [FAILED] customtkinter installation failed
)

echo.
echo Installing psutil...
pip install --force-reinstall --no-cache-dir psutil
if %errorLevel% equ 0 (
    echo [OK] psutil installed
) else (
    echo [FAILED] psutil installation failed
)

echo.
echo Installing Pillow...
pip install --force-reinstall --no-cache-dir Pillow
if %errorLevel% equ 0 (
    echo [OK] Pillow installed
) else (
    echo [FAILED] Pillow installation failed
)

echo.
echo Installing pystray...
pip install --force-reinstall --no-cache-dir pystray
if %errorLevel% equ 0 (
    echo [OK] pystray installed
) else (
    echo [FAILED] pystray installation failed
)

echo.
echo ============================================
echo    Testing Installation
echo ============================================
echo.

python -c "import customtkinter; print('[OK] customtkinter works!')" 2>nul || echo [FAILED] customtkinter
python -c "import psutil; print('[OK] psutil works!')" 2>nul || echo [FAILED] psutil
python -c "import PIL; print('[OK] Pillow works!')" 2>nul || echo [FAILED] Pillow
python -c "import pystray; print('[OK] pystray works!')" 2>nul || echo [FAILED] pystray

echo.
echo ============================================
echo    Complete!
echo ============================================
echo.
echo You can now run the Control Panel:
echo   launch.bat
echo.
pause