@echo off
REM IsotoneStack Log Viewer

title IsotoneStack Log Viewer
color 0E

:MENU
cls
echo ============================================
echo        IsotoneStack Log Viewer
echo ============================================
echo.
echo Select a log file to view:
echo.
echo   1. Apache Error Log
echo   2. Apache Access Log
echo   3. PHP Error Log
echo   4. MariaDB Error Log
echo   5. MariaDB Slow Query Log
echo   6. Open Logs Folder
echo   0. Exit
echo.

choice /C 1234560 /N /M "Select option (0-6): "

if %errorLevel% equ 7 goto EXIT
if %errorLevel% equ 1 goto APACHE_ERROR
if %errorLevel% equ 2 goto APACHE_ACCESS
if %errorLevel% equ 3 goto PHP_ERROR
if %errorLevel% equ 4 goto MARIADB_ERROR
if %errorLevel% equ 5 goto MARIADB_SLOW
if %errorLevel% equ 6 goto OPEN_FOLDER

:APACHE_ERROR
cls
echo ============================================
echo     Apache Error Log (Last 30 lines)
echo ============================================
echo.
if exist "%~dp0logs\apache\error.log" (
    powershell -Command "Get-Content '%~dp0logs\apache\error.log' -Tail 30"
) else (
    echo Log file not found: logs\apache\error.log
)
echo.
pause
goto MENU

:APACHE_ACCESS
cls
echo ============================================
echo     Apache Access Log (Last 30 lines)
echo ============================================
echo.
if exist "%~dp0logs\apache\access.log" (
    powershell -Command "Get-Content '%~dp0logs\apache\access.log' -Tail 30"
) else (
    echo Log file not found: logs\apache\access.log
)
echo.
pause
goto MENU

:PHP_ERROR
cls
echo ============================================
echo      PHP Error Log (Last 30 lines)
echo ============================================
echo.
if exist "%~dp0logs\php\error.log" (
    powershell -Command "Get-Content '%~dp0logs\php\error.log' -Tail 30"
) else (
    echo Log file not found: logs\php\error.log
)
echo.
pause
goto MENU

:MARIADB_ERROR
cls
echo ============================================
echo    MariaDB Error Log (Last 30 lines)
echo ============================================
echo.
if exist "%~dp0logs\mariadb\error.log" (
    powershell -Command "Get-Content '%~dp0logs\mariadb\error.log' -Tail 30"
) else (
    echo Log file not found: logs\mariadb\error.log
)
echo.
pause
goto MENU

:MARIADB_SLOW
cls
echo ============================================
echo  MariaDB Slow Query Log (Last 30 lines)
echo ============================================
echo.
if exist "%~dp0logs\mariadb\slow-query.log" (
    powershell -Command "Get-Content '%~dp0logs\mariadb\slow-query.log' -Tail 30"
) else (
    echo Log file not found: logs\mariadb\slow-query.log
)
echo.
pause
goto MENU

:OPEN_FOLDER
start explorer "%~dp0logs"
echo Opening logs folder...
timeout /t 2 >nul
goto MENU

:EXIT
exit