# IsotoneStack Manager - Interactive Control Panel
# Provides a menu-driven interface for managing IsotoneStack services

param(
    [switch]$NoLogo
)

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "IsotoneStack Manager"

# Configuration
$global:IsotoneRoot = "C:\isotone"
$global:Services = @{
    Apache = "IsotoneApache"
    MariaDB = "IsotoneMariaDB"
}

# Colors
$global:Colors = @{
    Header = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Menu = "White"
    Info = "Gray"
}

function Show-Logo {
    if (-not $NoLogo) {
        Clear-Host
        Write-Host @"

    ██╗███████╗ ██████╗ ████████╗ ██████╗ ███╗   ██╗███████╗
    ██║██╔════╝██╔═══██╗╚══██╔══╝██╔═══██╗████╗  ██║██╔════╝
    ██║███████╗██║   ██║   ██║   ██║   ██║██╔██╗ ██║█████╗  
    ██║╚════██║██║   ██║   ██║   ██║   ██║██║╚██╗██║██╔══╝  
    ██║███████║╚██████╔╝   ██║   ╚██████╔╝██║ ╚████║███████╗
    ╚═╝╚══════╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝
                       S T A C K   M A N A G E R

"@ -ForegroundColor $Colors.Header
        Write-Host "    Installation Path: $IsotoneRoot" -ForegroundColor $Colors.Info
        Write-Host "    ═══════════════════════════════════════════════════════" -ForegroundColor $Colors.Header
        Write-Host ""
    }
}

function Get-ServiceStatus {
    param([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        return $service.Status
    }
    return "Not Installed"
}

function Show-Status {
    Write-Host "`n  Service Status:" -ForegroundColor $Colors.Header
    Write-Host "  ───────────────" -ForegroundColor $Colors.Info
    
    foreach ($key in $Services.Keys) {
        $status = Get-ServiceStatus -ServiceName $Services[$key]
        $color = switch ($status) {
            "Running" { $Colors.Success }
            "Stopped" { $Colors.Warning }
            default { $Colors.Error }
        }
        $statusText = "{0,-15} : {1}" -f $key, $status
        Write-Host "  $statusText" -ForegroundColor $color
    }
    
    Write-Host "`n  Quick Links:" -ForegroundColor $Colors.Header
    Write-Host "  ────────────" -ForegroundColor $Colors.Info
    Write-Host "  Web Server     : http://localhost" -ForegroundColor $Colors.Info
    Write-Host "  phpMyAdmin     : http://localhost/phpmyadmin" -ForegroundColor $Colors.Info
    Write-Host "  Database       : localhost:3306" -ForegroundColor $Colors.Info
}

function Start-Services {
    Write-Host "`n  Starting IsotoneStack services..." -ForegroundColor $Colors.Header
    
    foreach ($key in $Services.Keys) {
        Write-Host -NoNewline "  Starting $key... " -ForegroundColor $Colors.Info
        try {
            Start-Service -Name $Services[$key] -ErrorAction Stop
            Write-Host "OK" -ForegroundColor $Colors.Success
        } catch {
            Write-Host "FAILED" -ForegroundColor $Colors.Error
            Write-Host "    Error: $_" -ForegroundColor $Colors.Error
        }
    }
}

function Stop-Services {
    Write-Host "`n  Stopping IsotoneStack services..." -ForegroundColor $Colors.Header
    
    foreach ($key in $Services.Keys) {
        Write-Host -NoNewline "  Stopping $key... " -ForegroundColor $Colors.Info
        try {
            Stop-Service -Name $Services[$key] -ErrorAction Stop
            Write-Host "OK" -ForegroundColor $Colors.Success
        } catch {
            Write-Host "FAILED" -ForegroundColor $Colors.Error
        }
    }
}

function Restart-Services {
    Stop-Services
    Start-Sleep -Seconds 2
    Start-Services
}

function Show-Logs {
    Write-Host "`n  Available Logs:" -ForegroundColor $Colors.Header
    Write-Host "  ───────────────" -ForegroundColor $Colors.Info
    Write-Host "  1. Apache Error Log" -ForegroundColor $Colors.Menu
    Write-Host "  2. Apache Access Log" -ForegroundColor $Colors.Menu
    Write-Host "  3. PHP Error Log" -ForegroundColor $Colors.Menu
    Write-Host "  4. MariaDB Error Log" -ForegroundColor $Colors.Menu
    Write-Host "  5. MariaDB Slow Query Log" -ForegroundColor $Colors.Menu
    Write-Host "  0. Back to Main Menu" -ForegroundColor $Colors.Menu
    
    $choice = Read-Host "`n  Select log to view"
    
    $logFile = switch ($choice) {
        "1" { "$IsotoneRoot\logs\apache\error.log" }
        "2" { "$IsotoneRoot\logs\apache\access.log" }
        "3" { "$IsotoneRoot\logs\php\error.log" }
        "4" { "$IsotoneRoot\logs\mariadb\error.log" }
        "5" { "$IsotoneRoot\logs\mariadb\slow-query.log" }
        "0" { return }
        default { return }
    }
    
    if (Test-Path $logFile) {
        Write-Host "`n  Last 20 lines of $logFile:" -ForegroundColor $Colors.Header
        Get-Content $logFile -Tail 20 | ForEach-Object { Write-Host "  $_" -ForegroundColor $Colors.Info }
    } else {
        Write-Host "`n  Log file not found: $logFile" -ForegroundColor $Colors.Error
    }
    
    Read-Host "`n  Press Enter to continue"
}

function Test-Installation {
    Write-Host "`n  Running Installation Tests..." -ForegroundColor $Colors.Header
    Write-Host "  ─────────────────────────────" -ForegroundColor $Colors.Info
    
    # Test Apache
    Write-Host -NoNewline "  Apache Binary... " -ForegroundColor $Colors.Info
    if (Test-Path "$IsotoneRoot\apache24\bin\httpd.exe") {
        Write-Host "OK" -ForegroundColor $Colors.Success
    } else {
        Write-Host "NOT FOUND" -ForegroundColor $Colors.Error
    }
    
    # Test PHP
    Write-Host -NoNewline "  PHP Binary... " -ForegroundColor $Colors.Info
    if (Test-Path "$IsotoneRoot\php\php.exe") {
        Write-Host "OK" -ForegroundColor $Colors.Success
        $phpVersion = & "$IsotoneRoot\php\php.exe" -v 2>$null | Select-Object -First 1
        Write-Host "    Version: $phpVersion" -ForegroundColor $Colors.Info
    } else {
        Write-Host "NOT FOUND" -ForegroundColor $Colors.Error
    }
    
    # Test MariaDB
    Write-Host -NoNewline "  MariaDB Binary... " -ForegroundColor $Colors.Info
    if (Test-Path "$IsotoneRoot\mariadb\bin\mysql.exe") {
        Write-Host "OK" -ForegroundColor $Colors.Success
    } else {
        Write-Host "NOT FOUND" -ForegroundColor $Colors.Error
    }
    
    # Test phpMyAdmin
    Write-Host -NoNewline "  phpMyAdmin... " -ForegroundColor $Colors.Info
    if (Test-Path "$IsotoneRoot\phpmyadmin\index.php") {
        Write-Host "OK" -ForegroundColor $Colors.Success
    } else {
        Write-Host "NOT FOUND" -ForegroundColor $Colors.Error
    }
    
    # Test Web Access
    Write-Host -NoNewline "  Web Server Response... " -ForegroundColor $Colors.Info
    try {
        $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -eq 200) {
            Write-Host "OK" -ForegroundColor $Colors.Success
        } else {
            Write-Host "ERROR (Status: $($response.StatusCode))" -ForegroundColor $Colors.Error
        }
    } catch {
        Write-Host "NO RESPONSE" -ForegroundColor $Colors.Warning
    }
    
    Read-Host "`n  Press Enter to continue"
}

function Open-ConfigFile {
    Write-Host "`n  Configuration Files:" -ForegroundColor $Colors.Header
    Write-Host "  ────────────────────" -ForegroundColor $Colors.Info
    Write-Host "  1. Apache Configuration (httpd.conf)" -ForegroundColor $Colors.Menu
    Write-Host "  2. PHP Configuration (php.ini)" -ForegroundColor $Colors.Menu
    Write-Host "  3. MariaDB Configuration (my.ini)" -ForegroundColor $Colors.Menu
    Write-Host "  4. phpMyAdmin Config (config.inc.php)" -ForegroundColor $Colors.Menu
    Write-Host "  0. Back to Main Menu" -ForegroundColor $Colors.Menu
    
    $choice = Read-Host "`n  Select file to edit"
    
    $configFile = switch ($choice) {
        "1" { "$IsotoneRoot\apache24\conf\httpd.conf" }
        "2" { "$IsotoneRoot\php\php.ini" }
        "3" { "$IsotoneRoot\mariadb\my.ini" }
        "4" { "$IsotoneRoot\phpmyadmin\config.inc.php" }
        "0" { return }
        default { return }
    }
    
    if (Test-Path $configFile) {
        Start-Process notepad.exe -ArgumentList $configFile
        Write-Host "`n  Opening $configFile in Notepad..." -ForegroundColor $Colors.Success
    } else {
        Write-Host "`n  Configuration file not found: $configFile" -ForegroundColor $Colors.Error
    }
    
    Read-Host "`n  Press Enter to continue"
}

function Show-SystemInfo {
    Write-Host "`n  System Information:" -ForegroundColor $Colors.Header
    Write-Host "  ───────────────────" -ForegroundColor $Colors.Info
    
    # IsotoneStack Version Info
    Write-Host "`n  IsotoneStack Components:" -ForegroundColor $Colors.Header
    Write-Host "  Apache         : 2.4.62" -ForegroundColor $Colors.Info
    Write-Host "  PHP            : 8.3.15" -ForegroundColor $Colors.Info
    Write-Host "  MariaDB        : 11.4.4 LTS" -ForegroundColor $Colors.Info
    Write-Host "  phpMyAdmin     : 5.2.1" -ForegroundColor $Colors.Info
    
    # System Resources
    Write-Host "`n  System Resources:" -ForegroundColor $Colors.Header
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $cpu = Get-WmiObject -Class Win32_Processor | Select-Object -First 1
    $mem = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeMem = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    
    Write-Host "  OS             : $($os.Caption)" -ForegroundColor $Colors.Info
    Write-Host "  CPU            : $($cpu.Name)" -ForegroundColor $Colors.Info
    Write-Host "  Memory         : $freeMem GB free / $mem GB total" -ForegroundColor $Colors.Info
    
    # Disk Space
    Write-Host "`n  Disk Usage (C:\isotone):" -ForegroundColor $Colors.Header
    $drive = Get-PSDrive C
    $freeSpace = [math]::Round($drive.Free / 1GB, 2)
    $usedSpace = [math]::Round($drive.Used / 1GB, 2)
    Write-Host "  Free Space     : $freeSpace GB" -ForegroundColor $Colors.Info
    Write-Host "  Used Space     : $usedSpace GB" -ForegroundColor $Colors.Info
    
    if (Test-Path $IsotoneRoot) {
        $isotoneSize = (Get-ChildItem $IsotoneRoot -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "  IsotoneStack   : $([math]::Round($isotoneSize, 2)) MB" -ForegroundColor $Colors.Info
    }
    
    Read-Host "`n  Press Enter to continue"
}

function Show-MainMenu {
    Show-Logo
    Show-Status
    
    Write-Host "`n  Main Menu:" -ForegroundColor $Colors.Header
    Write-Host "  ──────────" -ForegroundColor $Colors.Info
    Write-Host "  1. Start All Services" -ForegroundColor $Colors.Menu
    Write-Host "  2. Stop All Services" -ForegroundColor $Colors.Menu
    Write-Host "  3. Restart All Services" -ForegroundColor $Colors.Menu
    Write-Host "  4. View Logs" -ForegroundColor $Colors.Menu
    Write-Host "  5. Edit Configuration" -ForegroundColor $Colors.Menu
    Write-Host "  6. Test Installation" -ForegroundColor $Colors.Menu
    Write-Host "  7. System Information" -ForegroundColor $Colors.Menu
    Write-Host "  8. Open IsotoneStack Folder" -ForegroundColor $Colors.Menu
    Write-Host "  9. Refresh Status" -ForegroundColor $Colors.Menu
    Write-Host "  0. Exit" -ForegroundColor $Colors.Menu
    
    Write-Host ""
    $choice = Read-Host "  Select an option"
    
    switch ($choice) {
        "1" { Start-Services; Read-Host "`n  Press Enter to continue" }
        "2" { Stop-Services; Read-Host "`n  Press Enter to continue" }
        "3" { Restart-Services; Read-Host "`n  Press Enter to continue" }
        "4" { Show-Logs }
        "5" { Open-ConfigFile }
        "6" { Test-Installation }
        "7" { Show-SystemInfo }
        "8" { 
            Start-Process explorer.exe -ArgumentList $IsotoneRoot
            Write-Host "`n  Opening $IsotoneRoot in Explorer..." -ForegroundColor $Colors.Success
            Read-Host "`n  Press Enter to continue"
        }
        "9" { 
            Write-Host "`n  Refreshing status..." -ForegroundColor $Colors.Info
            Start-Sleep -Seconds 1
        }
        "0" { 
            Write-Host "`n  Thank you for using IsotoneStack!" -ForegroundColor $Colors.Success
            Write-Host "  Visit http://localhost to access your web server." -ForegroundColor $Colors.Info
            exit 
        }
        default { 
            Write-Host "`n  Invalid option. Please try again." -ForegroundColor $Colors.Warning
            Read-Host "`n  Press Enter to continue"
        }
    }
}

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n  WARNING: This script should be run as Administrator for full functionality." -ForegroundColor $Colors.Warning
    Write-Host "  Some operations may fail without Administrator privileges." -ForegroundColor $Colors.Warning
    Read-Host "`n  Press Enter to continue anyway"
}

# Main Loop
while ($true) {
    Show-MainMenu
}