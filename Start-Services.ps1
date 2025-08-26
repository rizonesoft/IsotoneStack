# Start IsotoneStack Services
Write-Host "Starting IsotoneStack services..." -ForegroundColor Cyan
net start IsotoneApache
net start IsotoneMariaDB
Write-Host "Services started!" -ForegroundColor Green
