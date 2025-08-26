@echo off
echo ============================================
echo    Clean Reinstall for IsotoneStack
echo ============================================
echo.
echo This will clean and reinstall the configuration files
echo for the current directory: %~dp0
echo.
echo Press Ctrl+C to cancel or
pause

set ISOTONE_PATH=%~dp0
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%

echo.
echo Step 1: Stopping services...
net stop IsotoneApache 2>nul
net stop IsotoneMariaDB 2>nul

echo.
echo Step 2: Unregistering services...
sc delete IsotoneApache 2>nul
sc delete IsotoneMariaDB 2>nul

echo.
echo Step 3: Cleaning configuration files...
if exist "%ISOTONE_PATH%\php\php.ini" del "%ISOTONE_PATH%\php\php.ini"
if exist "%ISOTONE_PATH%\mariadb\my.ini" del "%ISOTONE_PATH%\mariadb\my.ini"
if exist "%ISOTONE_PATH%\mariadb\data" (
    echo Removing MariaDB data directory...
    rmdir /s /q "%ISOTONE_PATH%\mariadb\data"
)

echo.
echo Step 4: Running setup script...
cd /d "%ISOTONE_PATH%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { $env:ISOTONE_PATH='%ISOTONE_PATH%'; & '.\Setup-IsotoneStack.ps1' }"

echo.
echo ============================================
echo    Reinstallation Complete
echo ============================================
echo.
echo Now try starting the services:
echo   Start-Services.bat
echo.
pause