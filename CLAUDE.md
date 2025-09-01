### Batch File Self-Elevation Pattern
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
- ✅ Add self-elevation to: Service control scripts, Control Panel launcher, System configuration scripts
- ✅ Don't add to: Read-only scripts, dependency installers (unless installing system-wide)

### Script Language Selection
- ✅ Choose the best scripting language for each specific task:
  - **PowerShell (.ps1)**: Windows service management, registry operations, system configuration, Windows-specific tasks
  - **Batch (.bat)**: Simple launchers, basic file operations, environment setup
  - **C# (.cs)**: Control Panel application, complex GUI applications, performance-critical tools
- ✅ Consider maintainability and readability when choosing the language
- ✅ Use existing scripts in the codebase as reference for similar tasks

### PowerShell Script Rules
- ✅ PowerShell scripts (.ps1) go in `.\scripts\` root folder
- ✅ PowerShell scripts use portable PowerShell from `.\pwsh\pwsh.exe` first, fall back to system PowerShell
- ✅ Each `.ps1` script needs a matching `.bat` launcher with same name in the same directory (e.g., Register-Services.ps1 → Register-Services.bat)
- ✅ Use `.\scripts\_Template.ps1` as base for all new PowerShell scripts
- ✅ Use `.\scripts\_Template.ps1.bat` as base for all PowerShell batch launchers
- ✅ Use `$PSScriptRoot` for script directory, `Split-Path -Parent $PSScriptRoot` for isotone root
- ✅ Never hardcode paths - always derive from script location
- ✅ Use only ASCII characters in output - no Unicode symbols, emojis, or special characters
- ✅ For checkmarks use [OK], for warnings use [WARNING], for errors use [ERROR]
- ✅ All PowerShell scripts must log to `logs\isotone` with proper log rotation
- ✅ Support common parameters: -Verbose, -Debug, -Force where applicable
- ✅ Scripts should return proper exit codes (0 for success, non-zero for failure)
- ✅ Use approved verbs for function names (Get-, Set-, Start-, Stop-, etc.)

### C# Control Panel Development Rules
- ✅ Control Panel source code is in `.\iso-control\src\`
- ✅ Solution file: `.\iso-control\src\Isotone.sln`
- ✅ Main project: `.\iso-control\src\Isotone\Isotone.csproj`
- ✅ Application icon: `.\iso-control\src\assets\isotone.ico`
- ✅ Target Framework: .NET 8.0 Windows (net8.0-windows)
- ✅ Use WinForms for UI (not WPF)
- ✅ Always request Administrator privileges via app.manifest
- ✅ Use relative paths in project files (e.g., `..\..\assets\isotone.ico`)
- ✅ Service names: IsotoneApache, IsotoneMariaDB, IsotoneMailpit
- ✅ All Control Panel data stored in `C:\isotone\iso-control\`:
  - Configuration: `.\iso-control\control-panel.json`
  - Cache files: `.\iso-control\cache\`
  - User settings: `.\iso-control\settings\`
  - Logs: `.\iso-control\logs\`
- ✅ Use async/await for long-running operations
- ✅ Implement proper error handling and logging
- ✅ Support system tray minimization
- ✅ Use dark theme by default

### Project Structure
- `apache24/` - Bundled Apache HTTP Server
- `php/` - Bundled PHP runtime
- `mariadb/` - Bundled MariaDB database
- `phpmyadmin/` - Bundled phpMyAdmin
- `mailpit/` - Bundled Mailpit email testing server
- `pwsh/` - Bundled PowerShell 7
- `bin/` - Essential tools (wget, 7-zip)
- `config/` - Configuration templates for each component
- `scripts/` - PowerShell scripts and batch launchers
  - `_Template.ps1` - Template for new PowerShell scripts
  - `_Template.ps1.bat` - Template for PowerShell batch launchers
- `iso-control/` - Control Panel application (C# WinForms .NET 8)
  - `src/` - Source code directory
    - `assets/` - Application assets (isotone.ico)
    - `Isotone.sln` - Visual Studio solution file
    - `Isotone/` - Main project directory
      - `Isotone.csproj` - Project file
      - `app.manifest` - Application manifest
      - `Program.cs` - Entry point
      - `FormMain.cs` - Main window
      - `Controls/` - User control panels
      - `Services/` - Service management
      - `Models/` - Data models
      - `Utilities/` - Helper classes
      - `Resources/Icons/` - Icon resources
- `logs/isotone/` - All script logs with timestamps
- `licenses/` - Open source licenses for all components
- `www/` - Web root directory (USER CONTENT - COMPLETELY IGNORE THIS FOLDER)
- NO `downloads/` folder - everything is bundled

### Never Do These
- ❌ NEVER create, edit, modify, delete, search, read, or access ANY files in the `www/` folder - completely ignore this directory
- ❌ When using Grep, Glob, LS, or any search tools, ALWAYS exclude the `www/` folder from searches
- ❌ NEVER create scripts that automatically update/modify code - always update files manually to prevent corruption
- ❌ Don't hardcode paths (use relative paths from script location)
- ❌ Don't modify Windows registry (except for auto-start)
- ❌ Don't use deprecated PHP/Apache features
- ❌ Don't commit binary files to git
- ❌ Don't store passwords in plain text
- ❌ Don't include user data in `/www/`
- ❌ Never remove configuration files from bundled components - IsotoneStack modifies configs in place like XAMPP
- ❌ Don't create download scripts - everything is bundled
- ❌ Never enable mod_headers (#LoadModule headers_module) in Apache - it causes issues

### Apache Configuration Rules
- ❌ NEVER add PHP handling directives (`<FilesMatch>`, `SetHandler`) in individual Directory blocks - PHP is already configured globally
- ❌ NEVER add `DirectoryIndex` directives in individual Directory blocks - it's already set globally in httpd.conf
- ✅ Keep Apache alias configurations minimal - only include Alias, Directory block with permissions (Options, AllowOverride, Require)
- ✅ Apache alias files should only contain: Alias directive, Directory block with Options/AllowOverride/Require directives

### Always Do These
- ✅ Check for Administrator privileges when needed
- ✅ Self-elevate batch files that need admin rights (services, system changes)
- ✅ Use relative paths within isotone directory
- ✅ Handle Windows path separators (`\` vs `/`)
- ✅ Include error handling and comprehensive logging
- ✅ Test on both Windows 10 and 11
- ✅ Keep configurations portable
- ✅ Log all operations to `logs\isotone` with timestamps
- ✅ Show console output only when there are warnings or errors