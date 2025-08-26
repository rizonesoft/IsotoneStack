@echo off
REM IsotoneStack - Start Services
title IsotoneStack Services
color 0A

echo ============================================
echo    Starting IsotoneStack Services
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

REM Check if Apache service exists
sc query IsotoneApache >nul 2>&1
if %errorLevel% equ 0 (
    echo Starting Apache service...
    net start IsotoneApache
    if %errorLevel% equ 0 (
        echo [OK] Apache started successfully
    ) else (
        echo [WARNING] Apache may already be running or failed to start
    )
) else (
    echo [ERROR] Apache service not registered. Run Register-Services.bat first
)

echo.
REM Check if MariaDB service exists
sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% equ 0 (
    echo Starting MariaDB service...
    net start IsotoneMariaDB
    if %errorLevel% equ 0 (
        echo [OK] MariaDB started successfully
    ) else (
        echo [WARNING] MariaDB may already be running or failed to start
        echo         Check Diagnose-Services.bat for details
    )
) else (
    echo [ERROR] MariaDB service not registered. Run Register-Services.bat first
)

echo.
echo ============================================
echo    Service Status
echo ============================================
echo.

sc query IsotoneApache | findstr "STATE"
sc query IsotoneMariaDB | findstr "STATE"

echo.
echo ============================================
echo    Access Points
echo ============================================
echo.
echo Web Server:  http://localhost
echo phpMyAdmin:  http://localhost/phpmyadmin
echo.
echo Opening browser...
timeout /t 2 >nul
start http://localhost

echo.
pause