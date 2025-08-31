### PowerShell Script Rules
- ✅ All PowerShell scripts must use portable PowerShell from `.\pwsh\pwsh.exe`
- ✅ Core service scripts (Register/Start/Stop/Unregister-Services, Configure-IsotoneStack, etc.) go in `.\scripts\` root folder
- ✅ Component-specific scripts go in subdirectories: `.\scripts\phpmyadmin\`, `.\scripts\apache\`, `.\scripts\mariadb\`, etc.
- ✅ Each `.ps1` script needs a matching `.bat` launcher with same name in the same directory
- ✅ Use `.\scripts\_Template.ps1` as base for all new PowerShell scripts
- ✅ Use `.\scripts\_Template.bat` as base for all new batch launchers
- ✅ Batch launchers must self-elevate when admin required
- ✅ Use `$PSScriptRoot` for script-relative paths
- ✅ Use `Split-Path -Parent $PSScriptRoot` for isotone root path
- ✅ Never hardcode paths - always derive from script location
- ✅ Use only ASCII characters - no Unicode symbols, emojis, or special characters (no ✓, ⚠, ✗, etc.)
- ✅ For checkmarks use [OK], for warnings use [WARNING], for errors use [ERROR]
- ✅ All PowerShell scripts must log to `logs\isotone` with timestamped files
- ✅ Use Write-Log function for both console and file output
- ✅ Batch files should be simple launchers - no logging needed
- ✅ Only show warnings/errors to console when something is wrong

### Project Structure
- `apache24/` - Bundled Apache HTTP Server
- `php/` - Bundled PHP runtime
- `mariadb/` - Bundled MariaDB database
- `phpmyadmin/` - Bundled phpMyAdmin
- `pwsh/` - Bundled PowerShell 7
- `bin/` - Essential tools (wget, 7-zip)
- `config/` - Configuration templates for each component
- `scripts/` - PowerShell and batch scripts (core scripts in root, component-specific in subdirectories)
  - `phpmyadmin/` - phpMyAdmin-specific scripts
  - `apache/` - Apache-specific scripts
  - `mariadb/` - MariaDB-specific scripts
- `logs/isotone/` - All script logs with timestamps
- `licenses/` - Open source licenses for all components
- `www/` - Web root directory (USER CONTENT - COMPLETELY IGNORE THIS FOLDER)
- NO `downloads/` folder - everything is bundled

### Never Do These
- ❌ NEVER create, edit, modify, delete, search, read, or access ANY files in the `www/` folder - completely ignore this directory
- ❌ When using Grep, Glob, LS, or any search tools, ALWAYS exclude the `www/` folder from searches
- ❌ NEVER create scripts that automatically update/modify code - always update files manually to prevent corruption
- ❌ Don't hardcode paths (use relative paths from script location)
- ❌ Don't use system PowerShell - use `.\pwsh\pwsh.exe`
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
- ✅ Use relative paths within isotone directory
- ✅ Handle Windows path separators (`\` vs `/`)
- ✅ Include error handling and comprehensive logging
- ✅ Test on both Windows 10 and 11
- ✅ Keep configurations portable
- ✅ Log all operations to `logs\isotone` with timestamps
- ✅ Show console output only when there are warnings or errors