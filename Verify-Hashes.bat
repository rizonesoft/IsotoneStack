@echo off
REM ==================================================================
REM Shortcut to Verify-Hashes.bat in tools folder
REM ==================================================================
cd /d "%~dp0tools"
call Verify-Hashes.bat %*
cd /d "%~dp0"