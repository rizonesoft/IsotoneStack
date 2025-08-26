@echo off
REM IsotoneStack - Stop Services
title IsotoneStack Stop Services
color 0C

echo ============================================
echo    Stopping IsotoneStack Services
echo ============================================
echo.

REM Check for Administrator privileges and self-elevate if needed
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)

echo [OK] Running with Administrator privileges
echo.

echo Stopping Apache service...
net stop IsotoneApache 2>nul
if %errorLevel% equ 0 (
    echo [OK] Apache stopped successfully
) else (
    if %errorLevel% equ 2 (
        echo [INFO] Apache was not running
    ) else (
        echo [WARNING] Apache service not found or already stopped
    )
)

echo.
echo Stopping MariaDB service...
net stop IsotoneMariaDB 2>nul
if %errorLevel% equ 0 (
    echo [OK] MariaDB stopped successfully
) else (
    if %errorLevel% equ 2 (
        echo [INFO] MariaDB was not running
    ) else (
        echo [WARNING] MariaDB service not found or already stopped
    )
)

echo.
echo ============================================
echo    Service Status
echo ============================================
echo.

sc query IsotoneApache 2>nul | findstr "STATE"
if %errorLevel% neq 0 (
    echo Apache: Not installed
)

sc query IsotoneMariaDB 2>nul | findstr "STATE"
if %errorLevel% neq 0 (
    echo MariaDB: Not installed
)

echo.
echo ============================================
echo    Services Stopped
echo ============================================
echo.
pause