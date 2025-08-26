# Master installation script that calls the main installer
# This file should be in the root for GitHub visibility

param(
    [string]$InstallPath = "C:\isotone",
    [switch]$SkipVCRedist = $false,
    [switch]$Force = $false
)

# Ensure we're in the right directory
Set-Location $PSScriptRoot

# Call the main installation script
& ".\Install-IsotoneStack.ps1" -InstallPath $InstallPath -SkipVCRedist:$SkipVCRedist -Force:$Force