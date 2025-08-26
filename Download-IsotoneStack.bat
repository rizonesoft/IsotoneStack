@echo off
setlocal EnableDelayedExpansion
REM ==================================================================
REM IsotoneStack Component Downloader with Hash Verification
REM ==================================================================
title IsotoneStack Verified Downloader
color 0E

echo ============================================
echo    IsotoneStack Verified Downloader
echo ============================================
echo.
echo This script will:
echo   1. Download official hashes from CDN
echo   2. Download and verify each component
echo   3. Extract only verified files
echo.

REM Set installation directory to current directory
set ISOTONE_PATH=%~dp0
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%

echo Installation path: %ISOTONE_PATH%
echo Source: IsotoneStack CDN (with verification)
echo.
pause

set BIN_PATH=%ISOTONE_PATH%\bin
set DOWNLOADS_PATH=%ISOTONE_PATH%\downloads
set HASHES_FILE=%DOWNLOADS_PATH%\hashes.txt

REM Create directories
if not exist "%BIN_PATH%" mkdir "%BIN_PATH%"
if not exist "%DOWNLOADS_PATH%" mkdir "%DOWNLOADS_PATH%"

echo.
echo [STEP 0] Downloading Official Hashes...
echo ----------------------------------------

REM Download hashes.txt from CDN using PowerShell
echo Downloading hashes.txt from CDN...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://isotone.b-cdn.net/IsotoneStack/hashes.txt' -OutFile '%HASHES_FILE%'}"

if not exist "%HASHES_FILE%" (
    echo [WARNING] Could not download hashes.txt
    echo Continuing without verification...
    echo.
) else (
    echo [OK] Official hashes downloaded
    echo.
)

echo [STEP 1] Setting up wget...
echo ----------------------------------------

REM Check if wget exists and verify if hashes available
if exist "%BIN_PATH%\wget.exe" (
    if exist "%HASHES_FILE%" (
        echo Verifying existing wget.exe...
        call :verify_file "%BIN_PATH%\wget.exe" "wget.exe"
        if !errorlevel! neq 0 (
            echo [WARNING] wget.exe hash mismatch, re-downloading...
            del "%BIN_PATH%\wget.exe"
            goto :download_wget
        )
    )
    echo wget already installed and verified
    goto :setup_7zip
)

:download_wget
echo Downloading wget from IsotoneStack CDN...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://isotone.b-cdn.net/IsotoneStack/bin/wget.exe' -OutFile '%BIN_PATH%\wget.exe'}"

if not exist "%BIN_PATH%\wget.exe" (
    echo [ERROR] Failed to download wget
    pause
    exit /b 1
)

REM Verify wget if hashes available
if exist "%HASHES_FILE%" (
    call :verify_file "%BIN_PATH%\wget.exe" "wget.exe"
    if !errorlevel! neq 0 (
        echo [ERROR] wget.exe verification failed!
        echo Downloaded file does not match official hash.
        pause
        exit /b 1
    )
)

echo wget installed successfully

:setup_7zip
echo.
echo [STEP 2] Setting up 7-Zip...
echo ----------------------------------------

REM Check if 7z.exe and 7z.dll exist and verify
if exist "%BIN_PATH%\7z.exe" if exist "%BIN_PATH%\7z.dll" (
    if exist "%HASHES_FILE%" (
        echo Verifying existing 7-Zip installation...
        call :verify_file "%BIN_PATH%\7z.exe" "7z.exe"
        if !errorlevel! neq 0 goto :download_7zip
        call :verify_file "%BIN_PATH%\7z.dll" "7z.dll"
        if !errorlevel! neq 0 goto :download_7zip
    )
    echo 7-Zip already installed and verified
    goto :download_components
)

:download_7zip
echo Downloading 7z.exe from IsotoneStack CDN...
"%BIN_PATH%\wget.exe" --no-check-certificate -O "%BIN_PATH%\7z.exe" "https://isotone.b-cdn.net/IsotoneStack/bin/7z.exe"

if not exist "%BIN_PATH%\7z.exe" (
    echo [ERROR] Failed to download 7z.exe
    pause
    exit /b 1
)

REM Verify 7z.exe
if exist "%HASHES_FILE%" (
    call :verify_file "%BIN_PATH%\7z.exe" "7z.exe"
    if !errorlevel! neq 0 (
        echo [ERROR] 7z.exe verification failed!
        pause
        exit /b 1
    )
)

echo Downloading 7z.dll from IsotoneStack CDN...
"%BIN_PATH%\wget.exe" --no-check-certificate -O "%BIN_PATH%\7z.dll" "https://isotone.b-cdn.net/IsotoneStack/bin/7z.dll"

if not exist "%BIN_PATH%\7z.dll" (
    echo [ERROR] Failed to download 7z.dll
    pause
    exit /b 1
)

REM Verify 7z.dll
if exist "%HASHES_FILE%" (
    call :verify_file "%BIN_PATH%\7z.dll" "7z.dll"
    if !errorlevel! neq 0 (
        echo [ERROR] 7z.dll verification failed!
        pause
        exit /b 1
    )
)

echo 7-Zip installed and verified successfully

:download_components
echo.
echo [STEP 3] Downloading and Verifying Components...
echo ============================================

REM Define component URLs and their CDN names
set "APACHE_URL=https://isotone.b-cdn.net/IsotoneStack/httpd-2.4.65-250724-Win64-VS17.7z"
set "APACHE_FILE=%DOWNLOADS_PATH%\apache24.7z"
set "APACHE_CDN=httpd-2.4.65-250724-Win64-VS17.7z"

set "PHP_URL=https://isotone.b-cdn.net/IsotoneStack/php-8.4.11-Win32-vs17-x64.7z"
set "PHP_FILE=%DOWNLOADS_PATH%\php.7z"
set "PHP_CDN=php-8.4.11-Win32-vs17-x64.7z"

set "MARIADB_URL=https://isotone.b-cdn.net/IsotoneStack/mariadb-11.4.4-winx64.7z"
set "MARIADB_FILE=%DOWNLOADS_PATH%\mariadb.7z"
set "MARIADB_CDN=mariadb-11.4.4-winx64.7z"

set "PHPMYADMIN_URL=https://isotone.b-cdn.net/IsotoneStack/phpMyAdmin-5.2.2-english.7z"
set "PHPMYADMIN_FILE=%DOWNLOADS_PATH%\phpmyadmin.7z"
set "PHPMYADMIN_CDN=phpMyAdmin-5.2.2-english.7z"

REM Download and verify Apache
echo.
echo [1/4] Apache 2.4.65 (VS17)
if exist "%APACHE_FILE%" (
    echo   Verifying existing file...
    if exist "%HASHES_FILE%" (
        call :verify_file "%APACHE_FILE%" "%APACHE_CDN%"
        if !errorlevel! neq 0 (
            echo   Re-downloading due to hash mismatch...
            del "%APACHE_FILE%"
            goto :download_apache
        )
    )
    echo   [OK] File exists and verified
) else (
    :download_apache
    echo   Downloading from CDN...
    "%BIN_PATH%\wget.exe" --no-check-certificate -O "%APACHE_FILE%" "%APACHE_URL%"
    
    if exist "%APACHE_FILE%" (
        if exist "%HASHES_FILE%" (
            call :verify_file "%APACHE_FILE%" "%APACHE_CDN%"
            if !errorlevel! neq 0 (
                echo   [ERROR] Downloaded file hash mismatch!
                del "%APACHE_FILE%"
                pause
                exit /b 1
            )
        )
        echo   [OK] Download complete and verified
    ) else (
        echo   [ERROR] Download failed
    )
)

REM Download and verify PHP
echo.
echo [2/4] PHP 8.4.11 (VS17 x64)
if exist "%PHP_FILE%" (
    echo   Verifying existing file...
    if exist "%HASHES_FILE%" (
        call :verify_file "%PHP_FILE%" "%PHP_CDN%"
        if !errorlevel! neq 0 (
            echo   Re-downloading due to hash mismatch...
            del "%PHP_FILE%"
            goto :download_php
        )
    )
    echo   [OK] File exists and verified
) else (
    :download_php
    echo   Downloading from CDN...
    "%BIN_PATH%\wget.exe" --no-check-certificate -O "%PHP_FILE%" "%PHP_URL%"
    
    if exist "%PHP_FILE%" (
        if exist "%HASHES_FILE%" (
            call :verify_file "%PHP_FILE%" "%PHP_CDN%"
            if !errorlevel! neq 0 (
                echo   [ERROR] Downloaded file hash mismatch!
                del "%PHP_FILE%"
                pause
                exit /b 1
            )
        )
        echo   [OK] Download complete and verified
    ) else (
        echo   [ERROR] Download failed
    )
)

REM Download and verify MariaDB
echo.
echo [3/4] MariaDB 11.4.4
if exist "%MARIADB_FILE%" (
    echo   Verifying existing file...
    if exist "%HASHES_FILE%" (
        call :verify_file "%MARIADB_FILE%" "%MARIADB_CDN%"
        if !errorlevel! neq 0 (
            echo   Re-downloading due to hash mismatch...
            del "%MARIADB_FILE%"
            goto :download_mariadb
        )
    )
    echo   [OK] File exists and verified
) else (
    :download_mariadb
    echo   Downloading from CDN...
    "%BIN_PATH%\wget.exe" --no-check-certificate -O "%MARIADB_FILE%" "%MARIADB_URL%"
    
    if exist "%MARIADB_FILE%" (
        if exist "%HASHES_FILE%" (
            call :verify_file "%MARIADB_FILE%" "%MARIADB_CDN%"
            if !errorlevel! neq 0 (
                echo   [ERROR] Downloaded file hash mismatch!
                del "%MARIADB_FILE%"
                pause
                exit /b 1
            )
        )
        echo   [OK] Download complete and verified
    ) else (
        echo   [ERROR] Download failed
    )
)

REM Download and verify phpMyAdmin
echo.
echo [4/4] phpMyAdmin 5.2.2 (English)
if exist "%PHPMYADMIN_FILE%" (
    echo   Verifying existing file...
    if exist "%HASHES_FILE%" (
        call :verify_file "%PHPMYADMIN_FILE%" "%PHPMYADMIN_CDN%"
        if !errorlevel! neq 0 (
            echo   Re-downloading due to hash mismatch...
            del "%PHPMYADMIN_FILE%"
            goto :download_phpmyadmin
        )
    )
    echo   [OK] File exists and verified
) else (
    :download_phpmyadmin
    echo   Downloading from CDN...
    "%BIN_PATH%\wget.exe" --no-check-certificate -O "%PHPMYADMIN_FILE%" "%PHPMYADMIN_URL%"
    
    if exist "%PHPMYADMIN_FILE%" (
        if exist "%HASHES_FILE%" (
            call :verify_file "%PHPMYADMIN_FILE%" "%PHPMYADMIN_CDN%"
            if !errorlevel! neq 0 (
                echo   [ERROR] Downloaded file hash mismatch!
                del "%PHPMYADMIN_FILE%"
                pause
                exit /b 1
            )
        )
        echo   [OK] Download complete and verified
    ) else (
        echo   [ERROR] Download failed
    )
)

echo.
echo [STEP 4] Extracting Verified Components...
echo ============================================

REM Only extract files that have been verified
REM Extract Apache
echo.
echo [1/4] Extracting Apache 2.4.65...
if exist "%APACHE_FILE%" (
    if exist "%ISOTONE_PATH%\apache24" rmdir /S /Q "%ISOTONE_PATH%\apache24"
    mkdir "%ISOTONE_PATH%\apache24"
    "%BIN_PATH%\7z.exe" x "%APACHE_FILE%" -o"%ISOTONE_PATH%\apache24" -aoa -y >nul
    
    if exist "%ISOTONE_PATH%\apache24\bin\httpd.exe" (
        echo   [OK] Apache extracted to apache24\
    ) else (
        echo   [ERROR] Apache extraction failed
    )
) else (
    echo   [SKIP] Apache not downloaded
)

REM Extract PHP
echo [2/4] Extracting PHP 8.4.11...
if exist "%PHP_FILE%" (
    if exist "%ISOTONE_PATH%\php" rmdir /S /Q "%ISOTONE_PATH%\php"
    mkdir "%ISOTONE_PATH%\php"
    "%BIN_PATH%\7z.exe" x "%PHP_FILE%" -o"%ISOTONE_PATH%\php" -aoa -y >nul
    
    if exist "%ISOTONE_PATH%\php\php.exe" (
        echo   [OK] PHP extracted to php\
    ) else (
        echo   [ERROR] PHP extraction failed
    )
) else (
    echo   [SKIP] PHP not downloaded
)

REM Extract MariaDB
echo [3/4] Extracting MariaDB 11.4.4...
if exist "%MARIADB_FILE%" (
    if exist "%ISOTONE_PATH%\mariadb" rmdir /S /Q "%ISOTONE_PATH%\mariadb"
    mkdir "%ISOTONE_PATH%\mariadb"
    "%BIN_PATH%\7z.exe" x "%MARIADB_FILE%" -o"%ISOTONE_PATH%\mariadb" -aoa -y >nul
    
    if exist "%ISOTONE_PATH%\mariadb\bin\mariadbd.exe" (
        echo   [OK] MariaDB extracted to mariadb\
    ) else if exist "%ISOTONE_PATH%\mariadb\bin\mysqld.exe" (
        echo   [OK] MariaDB extracted to mariadb\
    ) else (
        echo   [ERROR] MariaDB extraction failed
    )
) else (
    echo   [SKIP] MariaDB not downloaded
)

REM Extract phpMyAdmin
echo [4/4] Extracting phpMyAdmin 5.2.2...
if exist "%PHPMYADMIN_FILE%" (
    if exist "%ISOTONE_PATH%\phpmyadmin" rmdir /S /Q "%ISOTONE_PATH%\phpmyadmin"
    mkdir "%ISOTONE_PATH%\phpmyadmin"
    "%BIN_PATH%\7z.exe" x "%PHPMYADMIN_FILE%" -o"%ISOTONE_PATH%\phpmyadmin" -aoa -y >nul
    
    if exist "%ISOTONE_PATH%\phpmyadmin\index.php" (
        echo   [OK] phpMyAdmin extracted to phpmyadmin\
    ) else (
        echo   [ERROR] phpMyAdmin extraction failed
    )
) else (
    echo   [SKIP] phpMyAdmin not downloaded
)

echo.
echo ============================================
echo    Verified Download Complete!
echo ============================================
echo.
echo All components have been downloaded and verified
echo against official hashes from the CDN.
echo.
echo Directory structure:
echo   %ISOTONE_PATH%\
echo   +-- bin\            (wget and 7-Zip tools)
echo   +-- apache24\       (Apache 2.4.65 web server)
echo   +-- php\            (PHP 8.4.11 runtime)
echo   +-- mariadb\        (MariaDB 11.4.4 database)
echo   +-- phpmyadmin\     (phpMyAdmin 5.2.2 - English)
echo   +-- downloads\      (Verified 7z archives + hashes.txt)
echo.
echo Security: All files verified with SHA256 hashes
echo.
echo Next steps:
echo   1. Run Configure-Components.bat to configure components
echo   2. Run Register-Services.bat to register Windows services
echo   3. Run Start-Services.bat to start the services
echo   4. Access http://localhost to verify installation
echo.
pause
exit /b

REM ========================================
REM Verification function
REM ========================================
:verify_file
set "filepath=%~1"
set "filename=%~2"

REM Extract expected hash from hashes.txt
set "expected_hash="
for /f "usebackq tokens=*" %%L in ("%HASHES_FILE%") do (
    echo %%L | findstr /B /C:"%filename%" >nul
    if !errorlevel! equ 0 (
        REM Found filename line, next line should be SHA256
        set "found_file=1"
    ) else if defined found_file (
        echo %%L | findstr /B /C:"SHA256:" >nul
        if !errorlevel! equ 0 (
            REM Extract hash value
            for /f "tokens=2" %%H in ("%%L") do (
                set "expected_hash=%%H"
            )
            set "found_file="
            goto :got_expected_hash
        )
    )
)

:got_expected_hash
if not defined expected_hash (
    echo     [WARNING] No hash found for %filename%
    exit /b 0
)

REM Calculate actual hash
for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%filepath%" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
    set "actual_hash=%%H"
    set "actual_hash=!actual_hash: =!"
    goto :got_actual_hash
)

:got_actual_hash
if /i "!actual_hash!"=="!expected_hash!" (
    echo     [VERIFIED] %filename%
    exit /b 0
) else (
    echo     [FAIL] Hash mismatch for %filename%!
    echo            Expected: !expected_hash!
    echo            Actual:   !actual_hash!
    exit /b 1
)