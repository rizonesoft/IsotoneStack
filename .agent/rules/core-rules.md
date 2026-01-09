---
trigger: always_on
---

# IsotoneStack Development Rules

## PowerShell Script Rules
- All PowerShell scripts must use portable PowerShell from `.\pwsh\pwsh.exe`
- All scripts (.ps1 and .bat) go in `.\scripts\` folder unless explicitly requested in root
- Each `.ps1` script needs a matching `.bat` launcher with same name
- Use `.\scripts\_Template.ps1` as base for all new PowerShell scripts
- Use `.\scripts\_Template.ps1.bat` as base for all new batch launchers
- Batch launchers must self-elevate when admin required
- Use `$PSScriptRoot` for script-relative paths
- Use `Split-Path -Parent $PSScriptRoot` for isotone root path
- Never hardcode paths - always derive from script location
- Use only ASCII characters - no Unicode symbols, emojis, or special characters
- For checkmarks use [OK], for warnings use [WARNING], for errors use [ERROR]
- All PowerShell scripts must log to `logs\isotone` with timestamped files
- Use Write-Log function for both console and file output
- Batch files should be simple launchers - no logging needed
- Only show warnings/errors to console when something is wrong
- Support common parameters: -Verbose, -Debug, -Force where applicable
- Scripts should return proper exit codes (0 for success, non-zero for failure)
- Use approved verbs for function names (Get-, Set-, Start-, Stop-, etc.)

## Batch File Self-Elevation Pattern
When a batch file needs Administrator privileges (for services, registry, system changes):
```batch
REM Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)
```
- Add self-elevation to: Service control scripts, Control Panel launcher, System configuration scripts
- Don't add to: Read-only scripts, dependency installers (unless installing system-wide)

## C# iso-control Development Rules
- Control Panel is in `.\iso-control\` (root level, not under src)
- Solution file: `.\iso-control\Isotone.sln`
- Main project: `.\iso-control\Isotone.csproj`
- Application icon: `.\iso-control\assets\isotone.ico`
- Target Framework: .NET 9.0 Windows (net9.0-windows)
- Uses WPF with MaterialDesignInXAML and CommunityToolkit.Mvvm
- MVVM pattern: ViewModels/, Views/, Services/, Utilities/
- Always request Administrator privileges via app.manifest
- Use relative paths in project files
- Service names: IsotoneApache, IsotoneMariaDB, IsotoneMailpit
- Use async/await for long-running operations
- Implement proper error handling using ErrorHandler utility
- Support system tray minimization (MinimizeToTray setting)
- Uses dark theme by default

## Project Structure
```
isotone/
├── apache24/           - Bundled Apache HTTP Server
├── php/                - Bundled PHP runtime (multi-version: 8.3, 8.4, 8.5)
├── mariadb/            - Bundled MariaDB database (multi-version: 10.11, 11.8, 12.1)
├── phpmyadmin/         - Bundled phpMyAdmin
├── adminer/            - Bundled Adminer database manager
├── phpliteadmin/       - Bundled phpLiteAdmin for SQLite
├── mailpit/            - Bundled Mailpit email testing server
├── pwsh/               - Bundled PowerShell 7
├── python/             - Bundled Python runtime
├── browser/            - Bundled Chromium browser
├── bin/                - Essential tools (NSSM, 7-zip)
├── config/             - Configuration templates for each component
├── scripts/            - PowerShell scripts and batch launchers
│   ├── _Template.ps1         - Template for new PowerShell scripts
│   └── _Template.ps1.bat     - Template for PowerShell batch launchers
├── iso-control/        - Control Panel application (C# WPF .NET 9)
│   ├── ViewModels/           - MVVM ViewModels
│   ├── Views/                - XAML Views
│   ├── Services/             - Service management
│   ├── Utilities/            - Helper classes
│   └── assets/               - Application assets (icons)
├── distribution/       - Installer files and InnoSetup scripts
├── TODO/               - Project TODO files
├── logs/isotone/       - All script logs with timestamps
├── backups/            - Database backups
├── ssl/                - SSL certificates
├── default/            - Default web files (index.php, info.php)
├── www/                - Web root directory (USER CONTENT - COMPLETELY IGNORE)
└── NO downloads/ folder - everything is bundled
```

## Apache Configuration Rules
- NEVER add PHP handling directives (`<FilesMatch>`, `SetHandler`) in individual Directory blocks - PHP is already configured globally
- NEVER add `DirectoryIndex` directives in individual Directory blocks - it's already set globally in httpd.conf
- Keep Apache alias configurations minimal - only include Alias, Directory block with permissions (Options, AllowOverride, Require)
- Apache alias files should only contain: Alias directive, Directory block with Options/AllowOverride/Require
- Never enable mod_headers (#LoadModule headers_module) in Apache - it causes issues

## MariaDB Configuration Rules
- MariaDB supports multi-version structure (10.11.15, 11.8.5, 12.1.2)
- Each version has its own data directory under `mariadb\data\{major.minor}\`
- Configuration files are version-specific under `mariadb\{version}\my.ini`
- Default collation: utf8mb4_unicode_ci (for shared hosting compatibility)
- Never use utf8mb4_uca1400_ai_ci (MariaDB 12+ only, breaks compatibility)
- Use Switch-MariaDBVersion.ps1 to switch between versions

## Never Do These
- NEVER create, edit, modify, delete, search, read, or access ANY files in the `www/` folder - completely ignore this directory
- When using Grep, Glob, LS, or any search tools, ALWAYS exclude the `www/` folder from searches
- NEVER create scripts that automatically update/modify code - always update files manually to prevent corruption
- Don't hardcode paths (use relative paths from script location)
- Don't use system PowerShell - use `.\pwsh\pwsh.exe`
- Don't modify Windows registry (except for auto-start)
- Don't use deprecated PHP/Apache features
- Don't commit binary files to git
- Don't store passwords in plain text
- Don't include user data in `/www/`
- Never remove configuration files from bundled components - IsotoneStack modifies configs in place like XAMPP
- Don't create download scripts - everything is bundled

## Always Do These
- Check for Administrator privileges when needed
- Self-elevate batch files that need admin rights (services, system changes)
- Use relative paths within isotone directory
- Handle Windows path separators (`\` vs `/`)
- Include error handling and comprehensive logging
- Test on both Windows 10 and 11
- Keep configurations portable
- Log all operations to `logs\isotone` with timestamps
- Show console output only when there are warnings or errors

## Development Environment
- Apache/MariaDB/PHP run natively on Windows as services
- Development/coding may happen in WSL (Windows Subsystem for Linux)
- File paths in WSL use `/mnt/r/isotone/` to access Windows `R:\isotone\`
- Cannot run curl/test Apache from WSL - Apache is on Windows only
- Use Windows browser to test: `http://localhost/` or `http://localhost:port/`

## Script Language Selection
Choose the best scripting language for each specific task:
- **PowerShell (.ps1)**: Windows service management, registry operations, system configuration, Windows-specific tasks
- **Batch (.bat)**: Simple launchers, basic file operations, environment setup
- **C# (.cs)**: Control Panel application, complex GUI applications, performance-critical tools

Consider maintainability and readability when choosing the language. Use existing scripts in the codebase as reference for similar tasks.
