#Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $logFile -Value $logMessage
    
    # Write to console with color based on level
    switch ($Level) {
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        "ERROR"   { Write-Host $Message -ForegroundColor Red }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "INFO"    { Write-Host $Message -ForegroundColor Cyan }
        "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
        default   { Write-Host $Message }
    }
}

Write-Log "========================================" "INFO"
Write-Log "Visual C++ Redistributable Installation" "INFO"
Write-Log "========================================" "INFO"
Write-Host ""

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "This script requires Administrator privileges!" "ERROR"
    Write-Log "Please run as Administrator." "ERROR"
    exit 1
}

Write-Log "Checking for existing Visual C++ 2022 Redistributables..." "INFO"

# Check if VC++ 2022 x64 is already installed
$vcInstalled = $false
$vcKeys = @(
    "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
    "HKLM:\SOFTWARE\Classes\Installer\Dependencies\Microsoft.VS.VC_RuntimeMinimumVSU_amd64,v14"
)

foreach ($key in $vcKeys) {
    if (Test-Path $key) {
        try {
            $version = Get-ItemProperty -Path $key -Name "Version" -ErrorAction SilentlyContinue
            if ($version) {
                Write-Log "  Found VC++ Runtime: $($version.Version)" "SUCCESS"
                $vcInstalled = $true
                break
            }
        } catch {
            # Continue checking other keys
        }
    }
}

# Also check for the DLLs directly
$systemPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::System)
$vcDlls = @("vcruntime140.dll", "vcruntime140_1.dll", "msvcp140.dll")
$dllsFound = $true

foreach ($dll in $vcDlls) {
    $dllPath = Join-Path $systemPath $dll
    if (!(Test-Path $dllPath)) {
        $dllsFound = $false
        Write-Log "  Missing: $dll" "WARNING"
    } else {
        Write-Log "  Found: $dll" "DEBUG"
    }
}

if ($vcInstalled -and $dllsFound -and !$Force) {
    Write-Log "Visual C++ 2022 Redistributables are already installed." "SUCCESS"
    Write-Log "Use -Force parameter to reinstall." "INFO"
} else {
    Write-Host ""
    Write-Log "Downloading Visual C++ 2022 Redistributable (x64)..." "INFO"
    
    # Download URL for VC++ 2022 x64
    $vcRedistUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
    $vcRedistPath = Join-Path $isotonePath "temp\vc_redist.x64.exe"
    
    # Create temp directory if it doesn't exist
    $tempPath = Join-Path $isotonePath "temp"
    if (!(Test-Path $tempPath)) {
        New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
    }
    
    try {
        # Download the redistributable
        Write-Log "  Downloading from: $vcRedistUrl" "DEBUG"
        Invoke-WebRequest -Uri $vcRedistUrl -OutFile $vcRedistPath -UseBasicParsing
        Write-Log "  Download complete" "SUCCESS"
        
        Write-Host ""
        Write-Log "Installing Visual C++ 2022 Redistributable..." "INFO"
        
        # Install silently
        $process = Start-Process -FilePath $vcRedistPath -ArgumentList "/quiet", "/norestart" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Log "  Installation completed successfully" "SUCCESS"
        } elseif ($process.ExitCode -eq 1638) {
            Write-Log "  A newer version is already installed" "INFO"
        } elseif ($process.ExitCode -eq 3010) {
            Write-Log "  Installation completed - restart required" "WARNING"
            Write-Log "  Please restart your computer to complete the installation" "WARNING"
        } else {
            Write-Log "  Installation failed with exit code: $($process.ExitCode)" "ERROR"
        }
        
        # Clean up
        Remove-Item -Path $vcRedistPath -Force -ErrorAction SilentlyContinue
        Write-Log "  Cleaned up temporary files" "DEBUG"
        
    } catch {
        Write-Log "Failed to download or install VC++ Redistributable: $_" "ERROR"
        Write-Log "Please download manually from:" "INFO"
        Write-Log "  $vcRedistUrl" "INFO"
        exit 1
    }
}

Write-Host ""
Write-Log "========================================" "INFO"
Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"
Write-Log "========================================" "INFO"
Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host ""