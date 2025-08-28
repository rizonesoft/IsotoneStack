@echo off
:: Configure-IsotoneStack.bat - Launcher for Configure-IsotoneStack.ps1
:: Configures bundled Apache, PHP, MariaDB and phpMyAdmin components using template files

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

echo.
echo === IsotoneStack Component Configuration ===
echo.

if exist "%PWSH_EXE%" (
    "%PWSH_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Configure-IsotoneStack.ps1" %*
) else (
    echo [WARNING] PowerShell 7 not found at %PWSH_EXE%
    echo [WARNING] Using system PowerShell instead
    echo.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Configure-IsotoneStack.ps1" %*
)

:: Check exit code
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Configuration failed. Please check the error messages above.
    pause
    exit /b %ERRORLEVEL%
)

pause
exit /b %ERRORLEVEL%