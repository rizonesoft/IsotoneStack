# Setup-Development.ps1
# Sets up the development environment with symlinks to component directories
# This allows testing while keeping large binaries out of the git repository

param(
    [string]$ComponentsPath = "C:\isotone-components",
    [switch]$Remove  # Remove symlinks instead of creating them
)

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Get script locations
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logsPath "$scriptName`_$timestamp.log"

# Components to manage
$components = @(
    "apache24",
    "mariadb",
    "php",
    "phpmyadmin",
    "pwsh",
    "bin"
)

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    
    # Also write to console with appropriate color (unless NoConsole specified)
    if (-not $NoConsole) {
        switch ($Level) {
            "ERROR"   { Write-Host $Message -ForegroundColor Red }
            "WARNING" { Write-Host $Message -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $Message -ForegroundColor Green }
            "INFO"    { Write-Host $Message -ForegroundColor White }
            "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
            "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
            "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
            default   { Write-Host $Message }
        }
    }
}

# Function to create symbolic link
function New-SymLink {
    param(
        [string]$Link,
        [string]$Target
    )
    
    try {
        # Remove existing link or directory
        if (Test-Path $Link) {
            $item = Get-Item $Link -Force
            if ($item.LinkType -eq "SymbolicLink") {
                Write-Log "  Removing existing symlink: $Link" "DEBUG"
                $item.Delete()
            } else {
                Write-Log "  Warning: $Link exists and is not a symlink" "WARNING"
                return $false
            }
        }
        
        # Create new symlink
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        Write-Log "  [OK] Created symlink: $(Split-Path $Link -Leaf) -> $Target" "SUCCESS"
        return $true
    } catch {
        Write-Log "  [ERROR] Failed to create symlink: $_" "ERROR"
        return $false
    }
}

# Function to remove symbolic link
function Remove-SymLink {
    param([string]$Link)
    
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        if ($item.LinkType -eq "SymbolicLink") {
            try {
                $item.Delete()
                Write-Log "  [OK] Removed symlink: $(Split-Path $Link -Leaf)" "SUCCESS"
                return $true
            } catch {
                Write-Log "  [ERROR] Failed to remove symlink: $_" "ERROR"
                return $false
            }
        } else {
            Write-Log "  [SKIP] Not a symlink: $(Split-Path $Link -Leaf)" "WARNING"
        }
    } else {
        Write-Log "  [SKIP] Does not exist: $(Split-Path $Link -Leaf)" "DEBUG"
    }
    return $true
}

try {
    # Start logging
    Write-Log "========================================" "INFO"
    Write-Log "Development Environment Setup Started" "INFO"
    Write-Log "Repository: $isotonePath" "INFO"
    Write-Log "Components: $ComponentsPath" "INFO"
    Write-Log "Operation: $(if ($Remove) {'Remove symlinks'} else {'Create symlinks'})" "INFO"
    Write-Log "========================================" "INFO"
    
    Write-Host ""
    Write-Log "=== IsotoneStack Development Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check for Administrator privileges
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "This script requires Administrator privileges for creating symbolic links" "ERROR"
        Write-Log "Please run this script as Administrator" "ERROR"
        exit 1
    }
    Write-Log "[OK] Running with Administrator privileges" "SUCCESS"
    Write-Host ""
    
    if ($Remove) {
        # ============================================================
        # Remove symbolic links
        # ============================================================
        Write-Log "Removing symbolic links..." "CYAN"
        Write-Host ""
        
        $success = $true
        foreach ($component in $components) {
            $linkPath = Join-Path $isotonePath $component
            if (!(Remove-SymLink $linkPath)) {
                $success = $false
            }
        }
        
        Write-Host ""
        if ($success) {
            Write-Log "[SUCCESS] All symbolic links removed" "SUCCESS"
        } else {
            Write-Log "[WARNING] Some symbolic links could not be removed" "WARNING"
        }
    } else {
        # ============================================================
        # Create symbolic links
        # ============================================================
        
        # Check if components directory exists
        if (!(Test-Path $ComponentsPath)) {
            Write-Log "Components directory does not exist: $ComponentsPath" "ERROR"
            Write-Log "" "INFO"
            Write-Log "Would you like to:" "YELLOW"
            Write-Log "  1. Create the directory and move components there" "INFO"
            Write-Log "  2. Specify a different path" "INFO"
            Write-Log "  3. Cancel" "INFO"
            Write-Host ""
            Write-Host "Enter choice (1-3): " -NoNewline
            $choice = Read-Host
            
            switch ($choice) {
                "1" {
                    Write-Log "Creating components directory..." "INFO"
                    New-Item -Path $ComponentsPath -ItemType Directory -Force | Out-Null
                    
                    # Move existing components
                    Write-Log "Moving components to $ComponentsPath..." "INFO"
                    foreach ($component in $components) {
                        $sourcePath = Join-Path $isotonePath $component
                        if (Test-Path $sourcePath) {
                            $destPath = Join-Path $ComponentsPath $component
                            Write-Log "  Moving $component..." "DEBUG"
                            Move-Item -Path $sourcePath -Destination $destPath -Force
                            Write-Log "  [OK] Moved $component" "SUCCESS"
                        }
                    }
                }
                "2" {
                    Write-Host "Enter new components path: " -NoNewline
                    $ComponentsPath = Read-Host
                    if (!(Test-Path $ComponentsPath)) {
                        Write-Log "Path does not exist: $ComponentsPath" "ERROR"
                        exit 1
                    }
                }
                default {
                    Write-Log "Operation cancelled" "WARNING"
                    exit 0
                }
            }
        }
        
        Write-Host ""
        Write-Log "Creating symbolic links..." "CYAN"
        Write-Host ""
        
        # Create symbolic links
        $success = $true
        $missing = @()
        
        foreach ($component in $components) {
            $targetPath = Join-Path $ComponentsPath $component
            $linkPath = Join-Path $isotonePath $component
            
            if (Test-Path $targetPath) {
                if (!(New-SymLink $linkPath $targetPath)) {
                    $success = $false
                }
            } else {
                Write-Log "  [MISSING] Component not found: $component" "WARNING"
                $missing += $component
            }
        }
        
        Write-Host ""
        
        if ($missing.Count -gt 0) {
            Write-Log "Missing components in $ComponentsPath`:" "WARNING"
            foreach ($m in $missing) {
                Write-Log "  - $m" "WARNING"
            }
            Write-Host ""
            Write-Log "Download the IsotoneStack components and extract them to:" "INFO"
            Write-Log "  $ComponentsPath" "CYAN"
        }
        
        if ($success -and $missing.Count -eq 0) {
            Write-Log "[SUCCESS] Development environment ready!" "SUCCESS"
        } elseif ($success) {
            Write-Log "[PARTIAL] Some components are missing" "WARNING"
        } else {
            Write-Log "[ERROR] Failed to create some symbolic links" "ERROR"
        }
    }
    
    Write-Host ""
    Write-Log "========================================" "INFO"
    Write-Log "Next steps:" "INFO"
    
    if (!$Remove) {
        Write-Log "  1. Ensure components are in: $ComponentsPath" "DEBUG"
        Write-Log "  2. Run Configure-IsotoneStack.ps1 to configure" "DEBUG"
        Write-Log "  3. Run Register-Services.ps1 to register services" "DEBUG"
    } else {
        Write-Log "  Symbolic links removed. Repository is clean." "DEBUG"
    }
    
    Write-Log "========================================" "INFO"
    Write-Log "Development setup completed" "INFO"
    Write-Log "Log file: $logFile" "INFO"
    Write-Log "========================================" "INFO"
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Development setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}