@echo off
REM Quick launcher to open phpMyAdmin in default browser

start http://localhost/phpmyadmin
echo Opening phpMyAdmin in your default browser...
echo.
echo Default credentials:
echo   Username: root
echo   Password: isotone_admin
echo.
timeout /t 5 >nul