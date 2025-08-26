# Check IsotoneStack Service Status
Write-Host "`nIsotoneStack Service Status" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
sc.exe query IsotoneApache | Select-String "STATE"
sc.exe query IsotoneMariaDB | Select-String "STATE"
