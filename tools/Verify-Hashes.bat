@echo off
setlocal EnableDelayedExpansion
REM ==================================================================
REM IsotoneStack Hash Verification Tool
REM ==================================================================
title IsotoneStack Hash Verification
color 0E

echo ============================================
echo    IsotoneStack Hash Verification Tool
echo ============================================
echo.
echo This tool creates and verifies file hashes
echo.

if "%1"=="" goto :menu
if "%1"=="create" goto :create_mode
if "%1"=="verify" goto :verify_mode
if "%1"=="help" goto :help
goto :single_file

:menu
echo Select an option:
echo   1. Create hashes for downloaded files
echo   2. Verify hashes of downloaded files
echo   3. Check hash of a single file
echo   4. Generate hash manifest
echo   5. Exit
echo.
set /p choice=Enter choice (1-5): 

if "%choice%"=="1" goto :create_hashes
if "%choice%"=="2" goto :verify_hashes
if "%choice%"=="3" goto :single_file_prompt
if "%choice%"=="4" goto :generate_manifest
if "%choice%"=="5" exit /b
goto :menu

:create_hashes
echo.
echo Creating hashes for IsotoneStack downloads...
echo ============================================
echo.

REM Set to parent directory (tools script is in tools folder)
set ISOTONE_PATH=%~dp0..
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%
set DOWNLOADS_PATH=%ISOTONE_PATH%\downloads

if not exist "%DOWNLOADS_PATH%" (
    echo [ERROR] Downloads folder not found
    pause
    goto :menu
)

REM Create hash file
set HASH_FILE=%ISOTONE_PATH%\downloads\hashes.txt
echo IsotoneStack Component Hashes > "%HASH_FILE%"
echo Generated: %date% %time% >> "%HASH_FILE%"
echo ============================================ >> "%HASH_FILE%"
echo. >> "%HASH_FILE%"

REM Process each downloaded file
for %%F in ("%DOWNLOADS_PATH%\*.zip" "%DOWNLOADS_PATH%\*.exe" "%DOWNLOADS_PATH%\*.7z") do (
    if exist "%%F" (
        echo Processing: %%~nxF
        
        REM Calculate SHA256 hash using certutil
        for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%%F" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
            set "hash=%%H"
            set "hash=!hash: =!"
            echo %%~nxF: !hash!
            echo %%~nxF: !hash! >> "%HASH_FILE%"
        )
    )
)

echo.
echo Hashes saved to: %HASH_FILE%
echo.
pause
goto :menu

:verify_hashes
echo.
echo Verifying IsotoneStack downloads...
echo ============================================
echo.

REM Expected hashes (update these with actual values)
set "apache24.zip=PENDING"
set "php.zip=PENDING"
set "mariadb.zip=PENDING"
set "phpmyadmin.zip=PENDING"

REM Set to parent directory (tools script is in tools folder)
set ISOTONE_PATH=%~dp0..
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%
set DOWNLOADS_PATH=%ISOTONE_PATH%\downloads
set VERIFIED=0
set FAILED=0

REM Verify Apache
if exist "%DOWNLOADS_PATH%\apache24.zip" (
    echo Verifying Apache...
    call :verify_file "%DOWNLOADS_PATH%\apache24.zip" "%apache24.zip%" "Apache 2.4.65"
)

REM Verify PHP
if exist "%DOWNLOADS_PATH%\php.zip" (
    echo Verifying PHP...
    call :verify_file "%DOWNLOADS_PATH%\php.zip" "%php.zip%" "PHP 8.4.11"
)

REM Verify MariaDB
if exist "%DOWNLOADS_PATH%\mariadb.zip" (
    echo Verifying MariaDB...
    call :verify_file "%DOWNLOADS_PATH%\mariadb.zip" "%mariadb.zip%" "MariaDB 11.4.4"
)

REM Verify phpMyAdmin
if exist "%DOWNLOADS_PATH%\phpmyadmin.zip" (
    echo Verifying phpMyAdmin...
    call :verify_file "%DOWNLOADS_PATH%\phpmyadmin.zip" "%phpmyadmin.zip%" "phpMyAdmin 5.2.2"
)

echo.
echo ============================================
echo Verification Results:
echo   Verified: %VERIFIED%
echo   Failed:   %FAILED%
echo ============================================
echo.
pause
goto :menu

:verify_file
set "file=%~1"
set "expected=%~2"
set "name=%~3"

if "%expected%"=="PENDING" (
    echo   [SKIP] No hash available for %name%
    exit /b
)

REM Calculate actual hash
for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%file%" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
    set "actual=%%H"
    set "actual=!actual: =!"
    
    if "!actual!"=="%expected%" (
        echo   [OK] %name% hash verified
        set /a VERIFIED+=1
    ) else (
        echo   [FAIL] %name% hash mismatch!
        echo     Expected: %expected%
        echo     Actual:   !actual!
        set /a FAILED+=1
    )
    exit /b
)
exit /b

:single_file_prompt
echo.
set /p filepath=Enter file path: 
goto :process_single

:single_file
set filepath=%1

:process_single
if not exist "%filepath%" (
    echo [ERROR] File not found: %filepath%
    pause
    exit /b 1
)

echo.
echo File: %filepath%
echo ============================================
echo.

echo SHA256:
certutil -hashfile "%filepath%" SHA256 | findstr /v "CertUtil"
echo.

echo MD5:
certutil -hashfile "%filepath%" MD5 | findstr /v "CertUtil"
echo.

echo SHA1:
certutil -hashfile "%filepath%" SHA1 | findstr /v "CertUtil"
echo.

if "%1"=="" pause
exit /b

:generate_manifest
echo.
echo Generating hash manifest...
echo ============================================
echo.

REM Create comprehensive manifest
set MANIFEST=%ISOTONE_PATH%\HASHES.md
(
    echo # IsotoneStack Component Hashes
    echo.
    echo Generated: %date% %time%
    echo.
    echo ## Downloaded Files
    echo.
    echo ^| File ^| SHA256 ^| Size ^|
    echo ^|---^|---^|---^|
) > "%MANIFEST%"

REM Set to parent directory (tools script is in tools folder)
set ISOTONE_PATH=%~dp0..
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%
set DOWNLOADS_PATH=%ISOTONE_PATH%\downloads

for %%F in ("%DOWNLOADS_PATH%\*.zip" "%DOWNLOADS_PATH%\*.exe") do (
    if exist "%%F" (
        echo Processing: %%~nxF
        
        REM Get file size
        set size=%%~zF
        set /a "size_mb=!size! / 1048576"
        
        REM Get SHA256 hash
        for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%%F" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
            set "hash=%%H"
            set "hash=!hash: =!"
            echo ^| %%~nxF ^| !hash! ^| !size_mb! MB ^| >> "%MANIFEST%"
        )
    )
)

echo.
echo ## Verification Commands
echo. >> "%MANIFEST%"
echo ```batch >> "%MANIFEST%"
echo REM To verify a file: >> "%MANIFEST%"
echo certutil -hashfile filename SHA256 >> "%MANIFEST%"
echo ``` >> "%MANIFEST%"

echo.
echo Manifest saved to: %MANIFEST%
echo.
pause
goto :menu

:create_mode
REM Called with "create" parameter - batch mode
echo Creating hashes for all downloads...
call :create_hashes
exit /b

:verify_mode
REM Called with "verify" parameter - batch mode
call :verify_hashes
exit /b

:help
echo.
echo Usage: Verify-Hashes.bat [command] [file]
echo.
echo Commands:
echo   create         Create hashes for all downloaded files
echo   verify         Verify hashes of downloaded files
echo   help           Show this help message
echo   [filepath]     Calculate hashes for a single file
echo.
echo Examples:
echo   Verify-Hashes.bat                           (Interactive menu)
echo   Verify-Hashes.bat create                    (Create all hashes)
echo   Verify-Hashes.bat verify                    (Verify all hashes)
echo   Verify-Hashes.bat C:\isotone\downloads\php.zip  (Single file)
echo.
pause
exit /b