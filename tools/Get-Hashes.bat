@echo off
REM ==================================================================
REM Shortcut to hash tools in tools folder
REM ==================================================================
echo ============================================
echo    IsotoneStack Hash Tools
echo ============================================
echo.
echo Select a tool:
echo   1. Verify-Hashes (Interactive hash verification)
echo   2. Get-CDN-Hashes (Generate hashes for CDN)
echo   3. Get-IsotoneHashes (PowerShell hash tool)
echo   4. Exit
echo.
set /p choice=Enter choice (1-4): 

if "%choice%"=="1" (
    cd /d "%~dp0tools"
    call Verify-Hashes.bat
    cd /d "%~dp0"
) else if "%choice%"=="2" (
    cd /d "%~dp0tools"
    call Get-CDN-Hashes.bat
    cd /d "%~dp0"
) else if "%choice%"=="3" (
    cd /d "%~dp0tools"
    powershell -ExecutionPolicy Bypass -File "Get-IsotoneHashes.ps1"
    cd /d "%~dp0"
) else if "%choice%"=="4" (
    exit /b
) else (
    echo Invalid choice
    pause
)