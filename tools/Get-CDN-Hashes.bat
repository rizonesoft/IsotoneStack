@echo off
setlocal EnableDelayedExpansion
REM ==================================================================
REM Get hashes for files you want to upload to CDN
REM ==================================================================
title Get CDN Hashes
color 0E

echo ============================================
echo    Get Hashes for CDN Upload
echo ============================================
echo.
echo This will calculate hashes for files you plan
echo to upload to your CDN.
echo.
echo Place files in their respective folders first:
echo   - Binary tools in bin\
echo   - Archives in downloads\
echo.
pause

REM Set to parent directory (tools script is in tools folder)
set ISOTONE_PATH=%~dp0..
if "%ISOTONE_PATH:~-1%"=="\" set ISOTONE_PATH=%ISOTONE_PATH:~0,-1%

echo.
echo Calculating hashes...
echo ============================================
echo.

REM Check for wget.exe
if exist "%ISOTONE_PATH%\bin\wget.exe" (
    echo wget.exe
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\bin\wget.exe" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\bin\wget.exe" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\bin\wget.exe") do echo SIZE: %%~zA bytes
    echo.
)

REM Check for 7z.exe
if exist "%ISOTONE_PATH%\bin\7z.exe" (
    echo 7z.exe
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\bin\7z.exe" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\bin\7z.exe" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\bin\7z.exe") do echo SIZE: %%~zA bytes
    echo.
)

REM Check for 7z.dll
if exist "%ISOTONE_PATH%\bin\7z.dll" (
    echo 7z.dll
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\bin\7z.dll" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\bin\7z.dll" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\bin\7z.dll") do echo SIZE: %%~zA bytes
    echo.
)

REM Check for Apache 7z
if exist "%ISOTONE_PATH%\downloads\httpd-2.4.65-250724-Win64-VS17.7z" (
    echo httpd-2.4.65-250724-Win64-VS17.7z
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\httpd-2.4.65-250724-Win64-VS17.7z" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\httpd-2.4.65-250724-Win64-VS17.7z" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\downloads\httpd-2.4.65-250724-Win64-VS17.7z") do echo SIZE: %%~zA bytes
    echo.
) else if exist "%ISOTONE_PATH%\downloads\apache24.7z" (
    echo httpd-2.4.65-250724-Win64-VS17.7z ^(from apache24.7z^)
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\apache24.7z" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\apache24.7z" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\downloads\apache24.7z") do echo SIZE: %%~zA bytes
    echo.
)

REM Check for PHP 7z
if exist "%ISOTONE_PATH%\downloads\php-8.4.11-Win32-vs17-x64.7z" (
    echo php-8.4.11-Win32-vs17-x64.7z
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\php-8.4.11-Win32-vs17-x64.7z" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\php-8.4.11-Win32-vs17-x64.7z" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\downloads\php-8.4.11-Win32-vs17-x64.7z") do echo SIZE: %%~zA bytes
    echo.
) else if exist "%ISOTONE_PATH%\downloads\php.7z" (
    echo php-8.4.11-Win32-vs17-x64.7z ^(from php.7z^)
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\php.7z" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\php.7z" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\downloads\php.7z") do echo SIZE: %%~zA bytes
    echo.
)

REM Check for MariaDB 7z
if exist "%ISOTONE_PATH%\downloads\mariadb-11.4.4-winx64.7z" (
    echo mariadb-11.4.4-winx64.7z
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\mariadb-11.4.4-winx64.7z" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\mariadb-11.4.4-winx64.7z" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\downloads\mariadb-11.4.4-winx64.7z") do echo SIZE: %%~zA bytes
    echo.
) else if exist "%ISOTONE_PATH%\downloads\mariadb.7z" (
    echo mariadb-11.4.4-winx64.7z ^(from mariadb.7z^)
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\mariadb.7z" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\mariadb.7z" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\downloads\mariadb.7z") do echo SIZE: %%~zA bytes
    echo.
)

REM Check for phpMyAdmin 7z
if exist "%ISOTONE_PATH%\downloads\phpMyAdmin-5.2.2-english.7z" (
    echo phpMyAdmin-5.2.2-english.7z
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\phpMyAdmin-5.2.2-english.7z" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\phpMyAdmin-5.2.2-english.7z" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\downloads\phpMyAdmin-5.2.2-english.7z") do echo SIZE: %%~zA bytes
    echo.
) else if exist "%ISOTONE_PATH%\downloads\phpmyadmin.7z" (
    echo phpMyAdmin-5.2.2-english.7z ^(from phpmyadmin.7z^)
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\phpmyadmin.7z" SHA256 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo SHA256: !hash!
    )
    for /f "skip=1 tokens=* delims=" %%H in ('certutil -hashfile "%ISOTONE_PATH%\downloads\phpmyadmin.7z" MD5 2^>nul ^| findstr /v "CertUtil"') do (
        set "hash=%%H"
        set "hash=!hash: =!"
        echo MD5: !hash!
    )
    for %%A in ("%ISOTONE_PATH%\downloads\phpmyadmin.7z") do echo SIZE: %%~zA bytes
    echo.
)

echo ============================================
echo.
echo Copy these values to your hashes.txt file
echo and upload it to:
echo https://isotone.b-cdn.net/IsotoneStack/hashes.txt
echo.
pause