# Stop IsotoneStack Services
Write-Host "Stopping IsotoneStack services..." -ForegroundColor Cyan
net stop IsotoneApache
net stop IsotoneMariaDB
Write-Host "Services stopped!" -ForegroundColor Green
