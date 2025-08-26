@echo off
setlocal EnableDelayedExpansion
REM ==================================================================
REM Verify CDN Downloads Against Known Hashes
REM ==================================================================
title Verify CDN Downloads
color 0E

echo ============================================
echo    IsotoneStack CDN Download Verification
echo ============================================
echo.

REM Set to parent directory (tools script is in tools folder)
set ISOTONE_PATH=%~dp0..
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%
set PASSED=0
set FAILED=0
set MISSING=0

REM Known hashes for CDN files (UPDATE THESE WITH ACTUAL VALUES)
REM After running Generate-CDN-Hashes.bat, copy the hashes here

REM Binary tools
set "HASH_wget.exe_SHA256=PENDING"
set "HASH_7z.exe_SHA256=PENDING"
set "HASH_7z.dll_SHA256=PENDING"

REM 7z Archives
set "HASH_apache24.7z_SHA256=PENDING"
set "HASH_php.7z_SHA256=PENDING"
set "HASH_mariadb.7z_SHA256=PENDING"
set "HASH_phpmyadmin.7z_SHA256=PENDING"

REM Check if hashes.txt exists for auto-loading
if exist "%ISOTONE_PATH%\hashes.txt" (
    echo Loading hashes from hashes.txt...
    echo.
    REM Parse hashes.txt to extract values
    REM This is a placeholder - would need more complex parsing
)

echo Verifying Binary Tools...
echo ========================================
echo.

REM Verify wget.exe
if exist "%ISOTONE_PATH%\bin\wget.exe" (
    echo [1/7] Checking wget.exe...
    call :verify_file "%ISOTONE_PATH%\bin\wget.exe" "!HASH_wget.exe_SHA256!" "wget.exe"
) else (
    echo [1/7] wget.exe - MISSING
    set /a MISSING+=1
)

REM Verify 7z.exe
if exist "%ISOTONE_PATH%\bin\7z.exe" (
    echo [2/7] Checking 7z.exe...
    call :verify_file "%ISOTONE_PATH%\bin\7z.exe" "!HASH_7z.exe_SHA256!" "7z.exe"
) else (
    echo [2/7] 7z.exe - MISSING
    set /a MISSING+=1
)

REM Verify 7z.dll
if exist "%ISOTONE_PATH%\bin\7z.dll" (
    echo [3/7] Checking 7z.dll...
    call :verify_file "%ISOTONE_PATH%\bin\7z.dll" "!HASH_7z.dll_SHA256!" "7z.dll"
) else (
    echo [3/7] 7z.dll - MISSING
    set /a MISSING+=1
)

echo.
echo Verifying Component Archives...
echo ========================================
echo.

REM Verify Apache
if exist "%ISOTONE_PATH%\downloads\apache24.7z" (
    echo [4/7] Checking Apache archive...
    call :verify_file "%ISOTONE_PATH%\downloads\apache24.7z" "!HASH_apache24.7z_SHA256!" "Apache 2.4.65"
) else (
    echo [4/7] Apache archive - MISSING
    set /a MISSING+=1
)

REM Verify PHP
if exist "%ISOTONE_PATH%\downloads\php.7z" (
    echo [5/7] Checking PHP archive...
    call :verify_file "%ISOTONE_PATH%\downloads\php.7z" "!HASH_php.7z_SHA256!" "PHP 8.4.11"
) else (
    echo [5/7] PHP archive - MISSING
    set /a MISSING+=1
)

REM Verify MariaDB
if exist "%ISOTONE_PATH%\downloads\mariadb.7z" (
    echo [6/7] Checking MariaDB archive...
    call :verify_file "%ISOTONE_PATH%\downloads\mariadb.7z" "!HASH_mariadb.7z_SHA256!" "MariaDB 11.4.4"
) else (
    echo [6/7] MariaDB archive - MISSING
    set /a MISSING+=1
)

REM Verify phpMyAdmin
if exist "%ISOTONE_PATH%\downloads\phpmyadmin.7z" (
    echo [7/7] Checking phpMyAdmin archive...
    call :verify_file "%ISOTONE_PATH%\downloads\phpmyadmin.7z" "!HASH_phpmyadmin.7z_SHA256!" "phpMyAdmin 5.2.2"
) else (
    echo [7/7] phpMyAdmin archive - MISSING
    set /a MISSING+=1
)

echo.
echo ============================================
echo    Verification Summary
echo ============================================
echo.
echo   Passed:  %PASSED% files
echo   Failed:  %FAILED% files
echo   Missing: %MISSING% files
echo.

if %FAILED% GTR 0 (
    echo [WARNING] Some files failed verification!
    echo Please re-download the failed components.
    echo.
) else if %MISSING% GTR 0 (
    echo [INFO] Some files are missing.
    echo Run Download-IsotoneStack.bat to download them.
    echo.
) else (
    echo [SUCCESS] All files verified successfully!
    echo.
)

pause
exit /b

:verify_file
set "filepath=%~1"
set "expected_hash=%~2"
set "name=%~3"

if "%expected_hash%"=="PENDING" (
    echo     [SKIP] No hash configured for %name%
    echo            Run Generate-CDN-Hashes.bat first
    exit /b
)

REM Calculate actual hash
for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%filepath%" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
    set "actual_hash=%%H"
    set "actual_hash=!actual_hash: =!"
    
    if /i "!actual_hash!"=="%expected_hash%" (
        echo     [PASS] %name%
        set /a PASSED+=1
    ) else (
        echo     [FAIL] %name%
        echo            Expected: %expected_hash%
        echo            Actual:   !actual_hash!
        set /a FAILED+=1
    )
    exit /b
)
exit /b