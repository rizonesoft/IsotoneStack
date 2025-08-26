@echo off
REM ==================================================================
REM Remove Component Directories from Git Tracking
REM ==================================================================
title Clean Git Tracking
color 0E

echo ============================================
echo    Remove Component Directories from Git
echo ============================================
echo.
echo This will remove the following directories from git tracking:
echo   - apache24/
echo   - mariadb/
echo   - php/
echo   - phpmyadmin/
echo   - bin/
echo   - downloads/
echo   - backups/
echo   - www/ (except www/default/)
echo.
echo These directories are now in .gitignore and should not be tracked.
echo.
pause

echo.
echo Removing directories from git tracking...
echo.

REM Remove directories from git index (keeps local files)
git rm -r --cached apache24/ 2>nul
if %errorlevel% equ 0 (
    echo [OK] Removed apache24/ from tracking
) else (
    echo [INFO] apache24/ not tracked or already removed
)

git rm -r --cached mariadb/ 2>nul
if %errorlevel% equ 0 (
    echo [OK] Removed mariadb/ from tracking
) else (
    echo [INFO] mariadb/ not tracked or already removed
)

git rm -r --cached php/ 2>nul
if %errorlevel% equ 0 (
    echo [OK] Removed php/ from tracking
) else (
    echo [INFO] php/ not tracked or already removed
)

git rm -r --cached phpmyadmin/ 2>nul
if %errorlevel% equ 0 (
    echo [OK] Removed phpmyadmin/ from tracking
) else (
    echo [INFO] phpmyadmin/ not tracked or already removed
)

git rm -r --cached bin/ 2>nul
if %errorlevel% equ 0 (
    echo [OK] Removed bin/ from tracking
) else (
    echo [INFO] bin/ not tracked or already removed
)

git rm -r --cached downloads/ 2>nul
if %errorlevel% equ 0 (
    echo [OK] Removed downloads/ from tracking
) else (
    echo [INFO] downloads/ not tracked or already removed
)

git rm -r --cached backups/ 2>nul
if %errorlevel% equ 0 (
    echo [OK] Removed backups/ from tracking
) else (
    echo [INFO] backups/ not tracked or already removed
)

REM Handle www/ specially - keep www/default/
git rm -r --cached www/* 2>nul
if %errorlevel% equ 0 (
    echo [OK] Removed www/ contents from tracking (except default/)
    REM Re-add www/default if it exists
    if exist "www\default" (
        git add -f www/default/
        echo [OK] Re-added www/default/ to tracking
    )
) else (
    echo [INFO] www/ not tracked or already removed
)

echo.
echo ============================================
echo    Git Status
echo ============================================
echo.
git status --short

echo.
echo ============================================
echo    Next Steps
echo ============================================
echo.
echo The directories have been removed from git tracking.
echo They will remain on your local system but won't be in the repository.
echo.
echo To complete the cleanup:
echo   1. Review the changes above
echo   2. Commit the changes:
echo      git commit -m "Remove component directories from tracking"
echo   3. Push to remote repository:
echo      git push
echo.
echo Note: These directories are now in .gitignore and won't be tracked in future.
echo.
pause