# Uninstall IsotoneStack Services
param([switch]$RemoveData)

Write-Host "Stopping services..." -ForegroundColor Yellow
net stop IsotoneApache 2>$null
net stop IsotoneMariaDB 2>$null

Write-Host "Removing services..." -ForegroundColor Yellow
sc.exe delete IsotoneApache
sc.exe delete IsotoneMariaDB

if ($RemoveData) {
    Write-Host "Removing all data..." -ForegroundColor Red
    Remove-Item $InstallPath -Recurse -Force
}

Write-Host "Services uninstalled!" -ForegroundColor Green
