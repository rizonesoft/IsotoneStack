#Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host """
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host """
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
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
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host """
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host """
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host """
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
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
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host """
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host """
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
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
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host """
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { #Requires -RunAsAdministrator
# Install Visual C++ Redistributables for PHP 8.4
# PHP 8.4 requires Visual Studio 2022 runtime (VC17)

param(
    [switch]$Force = $false
,`n    [switch]$Verbose,`n    [switch]$Debug)

$isotonePath = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}
$logPath = Join-Path $isotonePath "logs\isotone"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logPath "install-vcredist_$timestamp.log"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}




Write-Log "Visual C++ Redistributable Installation" "INFO"

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

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host "".LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""

Write-Log "Visual C++ Redistributable Setup Complete" "SUCCESS"

Write-Host ""
Write-Log "Next steps:" "INFO"
Write-Log "  1. Restart Apache service" "DEBUG"
Write-Log "  2. Test PHP SQLite extensions" "DEBUG"
Write-Log "  3. Access phpLiteAdmin at http://localhost/phpliteadmin" "DEBUG"
Write-Host ""
