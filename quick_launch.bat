@echo off
REM IsotoneStack Quick Launcher
REM Provides quick access to all IsotoneStack functions

title IsotoneStack Quick Launch
color 0A

:MENU
cls
echo ============================================
echo        IsotoneStack Quick Launcher
echo ============================================
echo.
echo   1. Start All Services
echo   2. Stop All Services
echo   3. Restart Services
echo   4. Check Service Status
echo   5. Open Manager (Interactive)
echo   6. Open Web Server (http://localhost)
echo   7. Open phpMyAdmin
echo   8. Open IsotoneStack Folder
echo   9. View Apache Error Log
echo   0. Exit
echo.
echo ============================================
echo.

choice /C 1234567890 /N /M "Select an option (0-9): "

if %errorLevel% equ 10 goto EXIT
if %errorLevel% equ 1 goto START
if %errorLevel% equ 2 goto STOP
if %errorLevel% equ 3 goto RESTART
if %errorLevel% equ 4 goto STATUS
if %errorLevel% equ 5 goto MANAGER
if %errorLevel% equ 6 goto WEB
if %errorLevel% equ 7 goto PHPMYADMIN
if %errorLevel% equ 8 goto FOLDER
if %errorLevel% equ 9 goto LOGS

:START
cls
call "%~dp0start_services.bat"
goto MENU

:STOP
cls
call "%~dp0stop_services.bat"
goto MENU

:RESTART
cls
call "%~dp0restart_services.bat"
goto MENU

:STATUS
cls
call "%~dp0service_status.bat"
goto MENU

:MANAGER
start "" "%~dp0manager.bat"
goto MENU

:WEB
start http://localhost
echo Opening web browser to http://localhost...
timeout /t 2 >nul
goto MENU

:PHPMYADMIN
start http://localhost/phpmyadmin
echo Opening phpMyAdmin in browser...
timeout /t 2 >nul
goto MENU

:FOLDER
start explorer "%~dp0"
echo Opening IsotoneStack folder...
timeout /t 2 >nul
goto MENU

:LOGS
cls
echo ============================================
echo        Apache Error Log (Last 20 lines)
echo ============================================
echo.
if exist "%~dp0logs\apache\error.log" (
    powershell -Command "Get-Content '%~dp0logs\apache\error.log' -Tail 20"
) else (
    echo No error log found. Services may not be installed yet.
)
echo.
pause
goto MENU

:EXIT
echo.
echo Thank you for using IsotoneStack!
timeout /t 2 >nul
exit