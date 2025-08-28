@echo off
:: Setup-Development.bat - Launcher for Setup-Development.ps1
:: Sets up development environment with symlinks to component directories

setlocal EnableDelayedExpansion

:: Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"
:: Remove trailing backslash
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
:: Get parent directory (isotone root)
set "ISOTONE_PATH=%SCRIPT_DIR%\.."

:: Convert to absolute path
pushd "%ISOTONE_PATH%"
set "ISOTONE_PATH=%CD%"
popd

:: Check for portable PowerShell 7
set "PWSH_EXE=%ISOTONE_PATH%\pwsh\pwsh.exe"

:: Check for Administrator privileges and self-elevate if needed
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges for symbolic links...
    powershell -Command "Start-Process '%~f0' -Verb RunAs -ArgumentList '%*' -WorkingDirectory '%~dp0'"
    exit /b
)

echo.
echo === IsotoneStack Development Setup ===
echo.
echo [OK] Running with Administrator privileges
echo.

if exist "%PWSH_EXE%" (
    "%PWSH_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Setup-Development.ps1" %*
) else (
    echo [INFO] PowerShell 7 not found, using system PowerShell
    echo.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Setup-Development.ps1" %*
)

:: Check exit code
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Development setup failed. Please check the error messages above.
    pause
    exit /b %ERRORLEVEL%
)

pause
exit /b %ERRORLEVEL%