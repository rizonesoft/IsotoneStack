# Build-ControlPanel.ps1
# Builds the IsotoneStack Control Panel Python application into a standalone EXE
# Uses PyInstaller to create a portable executable

param(
    [string]$OutputPath = "",  # Optional custom output path
    [switch]$OneFile,         # Build as single EXE instead of folder
    [switch]$Debug,            # Include debug info in build
    [switch]$Clean,            # Clean build directories before building
    [switch]$Force,
    [switch]$Verbose
)

#Requires -Version 5.1

# Get script locations using portable paths (no hardcoded paths)
$scriptPath = $PSScriptRoot  # This is now the control-panel folder
$isotonePath = Split-Path -Parent $scriptPath
$scriptsPath = Join-Path $isotonePath "scripts"
$pwshPath = Join-Path $isotonePath "pwsh"
$pwshExe = Join-Path $pwshPath "pwsh.exe"
$logsPath = Join-Path $isotonePath "logs\isotone"

# Define common paths
$paths = @{
    Root         = $isotonePath
    Scripts      = $scriptsPath
    ControlPanel = $scriptPath  # Script is now IN the control-panel folder
    Python       = Join-Path $isotonePath "python"
    Runtimes     = Join-Path $isotonePath "runtimes"
    Dist         = Join-Path $scriptPath "dist"  # Build output in control-panel/dist
    Build        = Join-Path $scriptPath "build"  # Build temp in control-panel/build
    Logs         = Join-Path $isotonePath "logs"
    LogsIsotone  = $logsPath
}

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
        Write-Warning "Failed to load settings file: $_"
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
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Helper function to check admin privileges
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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

# Main script logic
try {
    # Start logging (only log start/end and important events)
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    if ($Verbose) {
        Write-Log "Parameters: OutputPath=$OutputPath, OneFile=$OneFile, Debug=$Debug, Clean=$Clean, Force=$Force, Verbose=$Verbose" "DEBUG"
    }
    
    Write-Host ""
    Write-Log "=== Building IsotoneStack Control Panel ===" "MAGENTA"
    if ($Verbose) {
        Write-Log "IsotoneStack Path: $isotonePath" "DEBUG"
    }
    Write-Host ""
    
    # Check if control panel source exists
    if (!(Test-Path $paths.ControlPanel)) {
        Write-Log "Control panel source not found at: $($paths.ControlPanel)" "ERROR"
        exit 1
    }
    
    # Check for main.py
    $mainPy = Join-Path $paths.ControlPanel "main.py"
    if (!(Test-Path $mainPy)) {
        Write-Log "main.py not found at: $mainPy" "ERROR"
        exit 1
    }
    
    # Determine Python executable - ALWAYS prefer embedded Python
    $pythonExe = Join-Path $paths.Python "python.exe"
    $pipExe = Join-Path $paths.Python "Scripts\pip.exe"
    $usingEmbedded = $false
    
    # Check for embedded Python first (this is the preferred method)
    if (Test-Path $pythonExe) {
        Write-Log "Using embedded Python: $pythonExe" "SUCCESS" -AlwaysLog
        $usingEmbedded = $true
        
        # Check if pip exists in embedded Python
        if (!(Test-Path $pipExe)) {
            Write-Log "pip not found in embedded Python, will use python -m pip" "WARNING"
            $pipExe = "$pythonExe -m pip"
        }
    } else {
        Write-Log "Embedded Python not found at: $($paths.Python)" "WARNING"
        Write-Log "Falling back to system Python (not recommended)" "WARNING"
        
        # Fall back to system Python
        $pythonExe = (Get-Command python -ErrorAction SilentlyContinue).Path
        if ($pythonExe) {
            Write-Log "Using system Python: $pythonExe" "WARNING" -AlwaysLog
            $pipExe = "pip"
        } else {
            Write-Log "No Python found! Please either:" "ERROR"
            Write-Log "  1. Download Python embeddable package to: $($paths.Python)" "ERROR"
            Write-Log "  2. Install Python 3.8+ system-wide" "ERROR"
            exit 1
        }
    }
    
    # Check Python version
    Write-Log "Checking Python version..." "DEBUG"
    $pythonVersion = & $pythonExe --version 2>&1
    Write-Log "Python version: $pythonVersion" "INFO" -AlwaysLog
    
    # Check for icon file (optional) - after Python is determined
    $iconFile = Join-Path $paths.ControlPanel "icon.ico"
    $hasIcon = Test-Path $iconFile
    if (!$hasIcon) {
        Write-Log "Icon file not found, will create a default icon" "WARNING"
        
        # Try to create a basic icon using Python PIL if available
        $createIconScript = @"
import sys
try:
    from PIL import Image, ImageDraw
    # Create a simple 32x32 icon
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Draw a simple blue square with "IS" text
    draw.rectangle([0, 0, 31, 31], fill=(0, 100, 200, 255))
    draw.text((8, 8), "IS", fill=(255, 255, 255, 255))
    img.save(r'$iconFile', format='ICO', sizes=[(32, 32)])
    print("Icon created successfully")
    sys.exit(0)
except ImportError:
    print("PIL not available, skipping icon creation")
    sys.exit(1)
"@
        
        $iconResult = $createIconScript | & $pythonExe - 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "[OK] Created default icon" "SUCCESS"
            $hasIcon = $true
        } else {
            Write-Log "Could not create icon, building without custom icon" "INFO"
            $hasIcon = $false
        }
    }
    
    # Clean build directories if requested or if they exist and might cause issues
    if ($Clean) {
        Write-Log "Cleaning build directories..." "INFO" -AlwaysLog
        if (Test-Path $paths.Build) {
            Remove-Item -Path $paths.Build -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "[OK] Cleaned build directory" "SUCCESS"
        }
        if (Test-Path $paths.Dist) {
            Remove-Item -Path $paths.Dist -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "[OK] Cleaned dist directory" "SUCCESS"
        }
        # Also clean spec files from previous builds
        $specFiles = Get-ChildItem -Path $paths.ControlPanel -Filter "*.spec" -ErrorAction SilentlyContinue
        foreach ($spec in $specFiles) {
            Remove-Item -Path $spec.FullName -Force -ErrorAction SilentlyContinue
            Write-Log "[OK] Removed old spec file: $($spec.Name)" "DEBUG"
        }
    }
    
    # Create directories if they don't exist
    if (!(Test-Path $paths.Build)) {
        New-Item -Path $paths.Build -ItemType Directory -Force | Out-Null
    }
    if (!(Test-Path $paths.Dist)) {
        New-Item -Path $paths.Dist -ItemType Directory -Force | Out-Null
    }
    
    # Install dependencies if requirements.txt exists
    $requirementsFile = Join-Path $paths.ControlPanel "requirements.txt"
    if (Test-Path $requirementsFile) {
        Write-Log "Installing control panel dependencies..." "INFO" -AlwaysLog
        
        # First upgrade pip to avoid issues
        Write-Log "Upgrading pip..." "DEBUG"
        & $pythonExe -m pip install --upgrade pip 2>&1 | Out-String | Write-Log -Level "DEBUG"
        
        # Install requirements
        $pipArgs = @("install", "-r", $requirementsFile)
        $pipOutput = & $pythonExe -m pip $pipArgs 2>&1 | Out-String
        if ($Verbose) {
            Write-Log $pipOutput "DEBUG"
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Warning: Some dependencies may not have installed correctly" "WARNING"
            Write-Log "Attempting to install critical dependencies individually..." "INFO"
            
            # Try to install critical dependencies one by one
            $criticalDeps = @("customtkinter", "psutil", "Pillow", "pystray", "PyMySQL", "pywin32", "PyYAML", "python-dotenv", "colorlog", "requests")
            foreach ($dep in $criticalDeps) {
                Write-Log "Installing $dep..." "DEBUG"
                $depOutput = & $pythonExe -m pip install $dep 2>&1 | Out-String
                if ($LASTEXITCODE -ne 0) {
                    Write-Log "Failed to install $dep" "ERROR"
                } else {
                    Write-Log "[OK] Installed $dep" "SUCCESS"
                }
            }
        } else {
            Write-Log "[OK] Dependencies installed successfully" "SUCCESS"
        }
    } else {
        Write-Log "No requirements.txt found, installing minimal dependencies..." "WARNING"
        # Install minimal required dependencies
        $minimalDeps = @("customtkinter", "psutil", "PyMySQL", "Pillow", "pywin32")
        foreach ($dep in $minimalDeps) {
            Write-Log "Installing $dep..." "INFO"
            & $pythonExe -m pip install $dep 2>&1 | Out-String | Write-Log -Level "DEBUG"
        }
    }
    
    # Install/upgrade PyInstaller
    Write-Log "Checking for PyInstaller..." "INFO" -AlwaysLog
    
    # Check if we have offline wheels in runtimes folder
    $wheelsPath = Join-Path $paths.Runtimes "wheels"
    if (Test-Path $wheelsPath) {
        Write-Log "Installing PyInstaller from offline wheels..." "INFO" -AlwaysLog
        $pipArgs = @("install", "--no-index", "--find-links", $wheelsPath, "pyinstaller")
        if ($Force) {
            $pipArgs += "--force-reinstall"
        }
        & $pythonExe -m pip $pipArgs 2>&1 | Out-String | Write-Log -Level "DEBUG"
    } else {
        Write-Log "Installing PyInstaller from PyPI..." "INFO" -AlwaysLog
        $pipArgs = @("install", "pyinstaller")
        if ($Force) {
            $pipArgs += "--upgrade", "--force-reinstall"
        }
        & $pythonExe -m pip $pipArgs 2>&1 | Out-String | Write-Log -Level "DEBUG"
    }
    
    # Check if PyInstaller was installed successfully
    $pyinstallerVersion = & $pythonExe -m PyInstaller --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to install PyInstaller" "ERROR"
        exit 1
    }
    Write-Log "PyInstaller version: $pyinstallerVersion" "INFO" -AlwaysLog
    
    # Build PyInstaller command
    $pyinstallerArgs = @(
        "-m", "PyInstaller",
        "--name", "IsotoneControlPanel",
        "--windowed",  # No console window
        "-y"  # Overwrite output directory without confirmation
    )
    
    # Add icon if it exists
    if ($hasIcon) {
        $pyinstallerArgs += "--icon", $iconFile
    }
    
    # Add remaining arguments
    $pyinstallerArgs += @(
        "--add-data", "$($paths.ControlPanel);.",
        "--distpath", $paths.Dist,
        "--workpath", $paths.Build,
        "--specpath", $paths.Build,
        # Hidden imports for customtkinter and other modules
        "--hidden-import", "customtkinter",
        "--hidden-import", "psutil",
        "--hidden-import", "PIL",
        "--hidden-import", "pystray",
        "--hidden-import", "tkinter",
        "--hidden-import", "tkinter.ttk",
        "--hidden-import", "pymysql",
        "--hidden-import", "pymysql.cursors",
        "--hidden-import", "pymysql.constants",
        # pywin32 modules (not the package itself)
        "--hidden-import", "win32api",
        "--hidden-import", "win32con",
        "--hidden-import", "win32gui",
        "--hidden-import", "win32process",
        "--hidden-import", "win32service",
        "--hidden-import", "win32serviceutil",
        "--hidden-import", "pywintypes",
        "--hidden-import", "yaml",
        "--hidden-import", "dotenv",
        "--hidden-import", "colorlog",
        "--hidden-import", "requests",
        "--hidden-import", "urllib3",
        # Collect all data from customtkinter
        "--collect-all", "customtkinter"
    )
    
    # Add one-file option if requested
    if ($OneFile) {
        $pyinstallerArgs += "--onefile"
        Write-Log "Building as single EXE file" "INFO" -AlwaysLog
    } else {
        Write-Log "Building as folder with EXE and dependencies" "INFO" -AlwaysLog
    }
    
    # Add debug option if requested
    if ($Debug) {
        $pyinstallerArgs += "--debug", "all"
        Write-Log "Including debug information in build" "INFO" -AlwaysLog
    } else {
        $pyinstallerArgs += "--log-level", "WARN"
    }
    
    # Add the main script
    $pyinstallerArgs += $mainPy
    
    # Change to control panel directory for build
    Push-Location $paths.ControlPanel
    
    try {
        Write-Log "Starting PyInstaller build..." "INFO" -AlwaysLog
        Write-Log "Build command: $pythonExe $($pyinstallerArgs -join ' ')" "DEBUG"
        
        # Run PyInstaller
        $buildOutput = & $pythonExe $pyinstallerArgs 2>&1 | Out-String
        
        if ($Verbose) {
            Write-Log $buildOutput "DEBUG"
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "PyInstaller build failed" "ERROR"
            Write-Log $buildOutput "ERROR"
            exit 1
        }
        
        Write-Log "[OK] Build completed successfully" "SUCCESS"
        
        # Determine output location
        if ($OneFile) {
            $exePath = Join-Path $paths.Dist "IsotoneControlPanel.exe"
        } else {
            $exePath = Join-Path $paths.Dist "IsotoneControlPanel\IsotoneControlPanel.exe"
        }
        
        if (Test-Path $exePath) {
            $exeInfo = Get-Item $exePath
            Write-Log "[OK] EXE created: $exePath" "SUCCESS"
            Write-Log "File size: $([math]::Round($exeInfo.Length / 1MB, 2)) MB" "INFO" -AlwaysLog
            
            # Copy to custom output path if specified
            if ($OutputPath -and $OutputPath -ne "") {
                if (!(Test-Path (Split-Path $OutputPath -Parent))) {
                    New-Item -Path (Split-Path $OutputPath -Parent) -ItemType Directory -Force | Out-Null
                }
                
                if ($OneFile) {
                    Copy-Item -Path $exePath -Destination $OutputPath -Force
                } else {
                    # Copy entire folder
                    $sourceFolder = Join-Path $paths.Dist "IsotoneControlPanel"
                    Copy-Item -Path $sourceFolder -Destination $OutputPath -Recurse -Force
                }
                Write-Log "[OK] Copied to: $OutputPath" "SUCCESS"
            }
        } else {
            Write-Log "EXE was not created at expected location: $exePath" "ERROR"
            exit 1
        }
        
    }
    finally {
        Pop-Location
    }
    
    # Summary
    Write-Host ""
    Write-Log "Build completed successfully" "SUCCESS" -AlwaysLog
    Write-Log "Output location: $exePath" "INFO" -AlwaysLog
    if ($Verbose) {
        Write-Log "Log file: $logFile" "DEBUG"
    }
}
catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Build failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}