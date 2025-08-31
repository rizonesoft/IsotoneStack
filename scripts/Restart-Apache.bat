@echo off
:: IsotoneStack - Restart Apache Service
:: Batch launcher for Restart-Apache.ps1

setlocal enabledelayedexpansion

:: Get parent directory (isotone root)
for %%I in ("%~dp0..") do set "ISOTONE_ROOT=%%~fI"

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Requesting Administrator privileges...
    
    :: Create temporary VBScript for elevation
    set "TEMP_VBS=%TEMP%\restart_apache_elevate.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) > "!TEMP_VBS!"
    echo UAC.ShellExecute "cmd.exe", "/c """"%~f0"" %*""", "", "runas", 1 >> "!TEMP_VBS!"
    
    :: Run VBScript to elevate
    cscript //nologo "!TEMP_VBS!"
    del "!TEMP_VBS!" >nul 2>&1
    exit /b
)

:: Running with admin rights
cd /d "%ISOTONE_ROOT%"

:: Check if portable PowerShell exists
if not exist "%ISOTONE_ROOT%\pwsh\pwsh.exe" (
    echo [ERROR] Portable PowerShell not found at: %ISOTONE_ROOT%\pwsh\pwsh.exe
    echo Please ensure IsotoneStack is properly installed.
    pause
    exit /b 1
)

:: Execute PowerShell script with portable PowerShell
echo.
"%ISOTONE_ROOT%\pwsh\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "%ISOTONE_ROOT%\scripts\Restart-Apache.ps1" %*

:: Check exit code
if %errorLevel% neq 0 (
    echo.
    echo [ERROR] Script execution failed with exit code: %errorLevel%
    pause
    exit /b %errorLevel%
)

:: Success - brief pause to see the results
timeout /t 3 /nobreak >nul 2>&1
exit /b 0