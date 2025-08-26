@echo off
REM IsotoneStack Installation Tester

title IsotoneStack Installation Test
color 0D

echo ============================================
echo     IsotoneStack Installation Test
echo ============================================
echo.

echo Checking components...
echo.

REM Check Apache
echo -^> Apache:
if exist "%~dp0apache24\bin\httpd.exe" (
    echo    [OK] Apache binary found
    "%~dp0apache24\bin\httpd.exe" -v 2>nul | findstr /C:"Server version"
) else (
    echo    [FAIL] Apache not installed
)
echo.

REM Check PHP
echo -^> PHP:
if exist "%~dp0php\php.exe" (
    echo    [OK] PHP binary found
    "%~dp0php\php.exe" -v 2>nul | findstr /C:"PHP"
) else (
    echo    [FAIL] PHP not installed
)
echo.

REM Check MariaDB
echo -^> MariaDB:
if exist "%~dp0mariadb\bin\mysql.exe" (
    echo    [OK] MariaDB binary found
    "%~dp0mariadb\bin\mysql.exe" --version 2>nul
) else (
    echo    [FAIL] MariaDB not installed
)
echo.

REM Check phpMyAdmin
echo -^> phpMyAdmin:
if exist "%~dp0phpmyadmin\index.php" (
    echo    [OK] phpMyAdmin found
) else (
    echo    [FAIL] phpMyAdmin not installed
)
echo.

REM Check services
echo Checking Windows services...
echo.

sc query IsotoneApache >nul 2>&1
if %errorLevel% equ 0 (
    echo    [OK] Apache service registered
    for /f "tokens=4" %%a in ('sc query IsotoneApache ^| findstr STATE') do echo    Status: %%a
) else (
    echo    [FAIL] Apache service not registered
)
echo.

sc query IsotoneMariaDB >nul 2>&1
if %errorLevel% equ 0 (
    echo    [OK] MariaDB service registered
    for /f "tokens=4" %%a in ('sc query IsotoneMariaDB ^| findstr STATE') do echo    Status: %%a
) else (
    echo    [FAIL] MariaDB service not registered
)
echo.

REM Test web server
echo Testing web server response...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost' -UseBasicParsing -TimeoutSec 2; Write-Host '   [OK] Web server responding (Status: '$r.StatusCode')' -ForegroundColor Green } catch { Write-Host '   [FAIL] Web server not responding' -ForegroundColor Red }"
echo.

REM Check ports
echo Checking port availability...
netstat -an | findstr :80 >nul 2>&1
if %errorLevel% equ 0 (
    echo    Port 80 (HTTP): IN USE
) else (
    echo    Port 80 (HTTP): AVAILABLE
)

netstat -an | findstr :3306 >nul 2>&1
if %errorLevel% equ 0 (
    echo    Port 3306 (MySQL): IN USE
) else (
    echo    Port 3306 (MySQL): AVAILABLE
)
echo.

echo ============================================
echo          Test Complete
echo ============================================
echo.
pause