# IsotoneStack Advanced Installer Script
# PowerShell 5.1+ (included with Windows 10/11)

param(
    [string]$InstallPath = "C:\isotone",
    [string]$Action = "install"
)

# Configuration class
class IsotoneConfig {
    [string]$InstallPath
    [string]$InstallPathFS  # Forward slashes
    [hashtable]$Variables
    
    IsotoneConfig([string]$path) {
        $this.InstallPath = $path
        $this.InstallPathFS = $path.Replace('\', '/')
        $this.Variables = @{
            'INSTALL_PATH'      = $this.InstallPathFS
            'INSTALL_PATH_BS'   = $this.InstallPath
            'APACHE_PATH'       = "$($this.InstallPathFS)/apache24"
            'APACHE_PATH_BS'    = "$($this.InstallPath)\apache24"
            'PHP_PATH'          = "$($this.InstallPathFS)/php"
            'PHP_PATH_BS'       = "$($this.InstallPath)\php"
            'MARIADB_PATH'      = "$($this.InstallPathFS)/mariadb"
            'MARIADB_PATH_BS'   = "$($this.InstallPath)\mariadb"
            'WWW_PATH'          = "$($this.InstallPathFS)/www"
            'WWW_PATH_BS'       = "$($this.InstallPath)\www"
            'SERVER_NAME'       = 'localhost'
            'SERVER_PORT'       = '80'
            'MYSQL_PORT'        = '3306'
        }
    }
}

# Template processor
function Process-Templates {
    param([IsotoneConfig]$Config)
    
    Write-Host "Processing configuration templates..." -ForegroundColor Cyan
    
    $templates = Get-ChildItem -Path "$($Config.InstallPath)\config" -Filter "*.template"
    
    foreach ($template in $templates) {
        $content = Get-Content $template.FullName -Raw
        
        # Replace all variables
        foreach ($key in $Config.Variables.Keys) {
            $content = $content -replace "\{\{$key\}\}", $Config.Variables[$key]
        }
        
        # Determine output path
        $outputFile = switch -Wildcard ($template.Name) {
            "httpd*.template"     { "$($Config.Variables.APACHE_PATH_BS)\conf\$($template.BaseName)" }
            "php*.template"       { "$($Config.Variables.PHP_PATH_BS)\$($template.BaseName)" }
            "my*.template"        { "$($Config.Variables.MARIADB_PATH_BS)\$($template.BaseName)" }
            "phpmyadmin*.template" { "$($Config.Variables.INSTALL_PATH_BS)\phpmyadmin\$($template.BaseName)" }
            default              { "$($Config.InstallPath)\$($template.BaseName)" }
        }
        
        Set-Content -Path $outputFile -Value $content -Encoding UTF8
        Write-Host "  ✓ Processed $($template.Name) -> $outputFile" -ForegroundColor Green
    }
}

# Component downloader
function Download-Component {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Hash,
        [string]$Destination
    )
    
    Write-Host "Downloading $Name..." -ForegroundColor Cyan
    
    try {
        # Download with progress
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile "$Destination.zip" -UseBasicParsing
        
        # Verify hash
        $actualHash = (Get-FileHash "$Destination.zip" -Algorithm SHA256).Hash
        if ($actualHash -ne $Hash) {
            throw "Hash mismatch for $Name"
        }
        
        # Extract
        Expand-Archive -Path "$Destination.zip" -DestinationPath $Destination -Force
        Remove-Item "$Destination.zip"
        
        Write-Host "  ✓ $Name installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Failed to install $Name: $_" -ForegroundColor Red
        throw
    }
}

# Service manager
function Register-Services {
    param([IsotoneConfig]$Config)
    
    Write-Host "Registering Windows services..." -ForegroundColor Cyan
    
    # Apache
    $apacheExe = "$($Config.Variables.APACHE_PATH_BS)\bin\httpd.exe"
    if (Test-Path $apacheExe) {
        & $apacheExe -k install -n "IsotoneApache" -f "$($Config.Variables.APACHE_PATH_BS)\conf\httpd.conf"
        Write-Host "  ✓ Apache service registered" -ForegroundColor Green
    }
    
    # MariaDB
    $mariadbExe = "$($Config.Variables.MARIADB_PATH_BS)\bin\mariadbd.exe"
    if (Test-Path $mariadbExe) {
        & $mariadbExe --install "IsotoneMariaDB" --defaults-file="$($Config.Variables.MARIADB_PATH_BS)\my.ini"
        Write-Host "  ✓ MariaDB service registered" -ForegroundColor Green
    }
}

# Environment setup
function Set-EnvironmentVariables {
    param([IsotoneConfig]$Config)
    
    Write-Host "Setting environment variables..." -ForegroundColor Cyan
    
    # Add to system PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $newPaths = @(
        $Config.Variables.PHP_PATH_BS,
        "$($Config.Variables.APACHE_PATH_BS)\bin",
        "$($Config.Variables.MARIADB_PATH_BS)\bin",
        "$($Config.InstallPath)\bin"
    )
    
    foreach ($path in $newPaths) {
        if ($currentPath -notlike "*$path*") {
            $currentPath += ";$path"
            Write-Host "  + Added $path to PATH" -ForegroundColor Yellow
        }
    }
    
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "Machine")
    [Environment]::SetEnvironmentVariable("ISOTONE_HOME", $Config.InstallPath, "Machine")
    
    Write-Host "  ✓ Environment variables configured" -ForegroundColor Green
}

# Main installation
function Install-IsotoneStack {
    param([string]$InstallPath)
    
    $config = [IsotoneConfig]::new($InstallPath)
    
    Write-Host "`n=== IsotoneStack Installation ===" -ForegroundColor Magenta
    Write-Host "Install Path: $InstallPath`n" -ForegroundColor White
    
    # Create directory structure
    $dirs = @('apache24', 'php', 'mariadb', 'phpmyadmin', 'www', 'bin', 'logs', 'backups', 'config', 'downloads')
    foreach ($dir in $dirs) {
        New-Item -Path "$InstallPath\$dir" -ItemType Directory -Force | Out-Null
    }
    
    # Process templates
    Process-Templates -Config $config
    
    # Register services (if admin)
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Register-Services -Config $config
        Set-EnvironmentVariables -Config $config
    } else {
        Write-Host "`n⚠ Run as Administrator to register services and set environment variables" -ForegroundColor Yellow
    }
    
    Write-Host "`n=== Installation Complete ===" -ForegroundColor Green
}

# Execute based on action
switch ($Action) {
    "install"   { Install-IsotoneStack -InstallPath $InstallPath }
    "configure" { Process-Templates -Config ([IsotoneConfig]::new($InstallPath)) }
    "services"  { Register-Services -Config ([IsotoneConfig]::new($InstallPath)) }
    default     { Write-Host "Unknown action: $Action" -ForegroundColor Red }
}