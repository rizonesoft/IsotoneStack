# 🤖 CLAUDE.md - AI Assistant Guide for IsotoneStack

This document helps AI assistants (like Claude, ChatGPT, Copilot) understand and work with the IsotoneStack project effectively.

## 📋 Project Overview

**IsotoneStack** is a portable Windows development environment (WAMP stack) that installs to `C:\isotone` with a modern Python/CustomTkinter GUI control panel.

### Key Characteristics
- **Installation Path**: Always `C:\isotone` (hardcoded for portability)
- **Platform**: Windows 10/11 only (64-bit)
- **Language**: PowerShell for scripts, Python 3.11+ for GUI
- **Architecture**: Portable, no registry dependencies
- **Services**: Apache, MariaDB registered as Windows services

## 🏗️ Project Structure

```
C:\isotone\
├── apache24/           # Apache binaries and configs
├── php/               # PHP binaries and extensions  
├── mariadb/           # MariaDB binaries and data
├── phpmyadmin/        # phpMyAdmin web interface
├── www/               # User websites (git-ignored)
├── control-panel/     # Python GUI application
├── config/            # Configuration templates
├── logs/              # Service logs (git-ignored)
├── ssl/               # SSL certificates (git-ignored)
├── tmp/               # Temporary files (git-ignored)
└── backups/           # Backups (git-ignored)
```

## 🔧 Component Versions

Always use the LATEST STABLE versions:
- **Apache**: 2.4.62+ from apachelounge.com
- **PHP**: 8.3.x from windows.php.net
- **MariaDB**: 11.4.x LTS from mariadb.org
- **phpMyAdmin**: 5.2.x from phpmyadmin.net

## 📝 Coding Standards

### PowerShell Scripts
```powershell
# Use approved verbs (Get-, Set-, Start-, Stop-, etc.)
function Start-IsotoneService {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )
    # Implementation
}

# Always check for admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Requires Administrator privileges" -ForegroundColor Red
    exit 1
}

# Use $ErrorActionPreference = "Stop"
# Handle errors with try/catch
```

### Python GUI Code
```python
# Use type hints
def create_button(parent: ctk.CTk, text: str) -> ctk.CTkButton:
    pass

# Follow CustomTkinter conventions
# Dark theme by default
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

# Organize into classes
class ServicePanel:
    def __init__(self, parent, config, logger):
        pass
```

### File Naming Conventions
- **PowerShell**: `PascalCase.ps1` (e.g., `Install-IsotoneStack.ps1`)
- **Python**: `snake_case.py` (e.g., `service_panel.py`)
- **Batch files**: `lowercase_underscore.bat` (e.g., `start_services.bat`)
- **Config files**: `lowercase-hyphen.conf` (e.g., `httpd-vhosts.conf`)

## 🎯 Common Tasks

### Adding a New Service

1. **Update installer** (`Install-IsotoneStack.ps1`):
   ```powershell
   $VERSIONS = @{
       NewService = @{
           Version = "x.x.x"
           Url = "https://..."
           Folder = "newservice"
       }
   }
   ```

2. **Add to control panel** (`control-panel/ui/service_panel.py`):
   ```python
   services_info.append({
       "id": "newservice",
       "name": "New Service",
       "service": "IsotoneNewService",
       "port": "xxxx"
   })
   ```

3. **Update service monitor** (`services/service_monitor.py`)

### Creating Configuration Templates

Place in `/config/` with descriptive names:
- `httpd-isotone.conf` - Apache template
- `php-isotone.ini` - PHP template
- `my-isotone.ini` - MariaDB template

### Adding GUI Features

1. Create component in `/control-panel/ui/`
2. Add to sidebar navigation
3. Register in `main_window.py`
4. Update `requirements.txt` if new dependencies

## 🚫 Important Restrictions

### Never Do These
- ❌ Don't hardcode paths other than `C:\isotone`
- ❌ Don't modify Windows registry (except for auto-start)
- ❌ Don't use deprecated PHP/Apache features
- ❌ Don't commit binary files to git
- ❌ Don't store passwords in plain text
- ❌ Don't include user data in `/www/`

### Always Do These
- ✅ Check for Administrator privileges
- ✅ Use relative paths within isotone directory
- ✅ Handle Windows path separators (`\` vs `/`)
- ✅ Include error handling and logging
- ✅ Test on both Windows 10 and 11
- ✅ Keep configurations portable

## 🔐 Security Considerations

### Default Credentials
- **MariaDB root**: `isotone_admin` (should be changed)
- **No default web passwords**
- **SSL certificates**: Self-signed for development

### File Permissions
- Service executables: Read/Execute
- Config files: Read/Write for admins only
- Logs: Write access for services
- www folder: Full access for developers

## 📦 Distribution

### What's Included in Git
- ✅ Source code and scripts
- ✅ Configuration templates
- ✅ Documentation
- ✅ Batch file launchers

### What's Excluded (via .gitignore)
- ❌ Binary executables
- ❌ User data and databases
- ❌ Logs and temporary files
- ❌ SSL certificates
- ❌ Virtual environments

## 🔄 Update Process

1. **Check for new versions** in official sources
2. **Update version numbers** in `Install-IsotoneStack.ps1`
3. **Test installation** on clean system
4. **Update documentation** with changes
5. **Tag release** in git

## 💡 Helper Prompts for AI

### For Installation Issues
"The IsotoneStack installer is failing at [step]. The error message is [error]. The installer should download from official sources and extract to C:\isotone. Check the PowerShell script Install-IsotoneStack.ps1 for the installation logic."

### For GUI Development
"I need to add [feature] to the IsotoneStack control panel GUI. It uses Python 3.11+ with CustomTkinter. The main window is in control-panel/ui/main_window.py and should follow the existing dark theme design pattern."

### For Service Management
"The [Apache/MariaDB/PHP] service in IsotoneStack won't [start/stop]. Services are named IsotoneApache and IsotoneMariaDB. Check the service control in control-panel/service_panel.py and Windows service commands."

### For Configuration
"I need to modify the [Apache/PHP/MariaDB] configuration for IsotoneStack. Config templates are in /config/ folder. The active configs are in /apache24/conf/, /php/, and /mariadb/ respectively."

## 📚 Resources

### Official Documentation
- [Apache Docs](https://httpd.apache.org/docs/2.4/)
- [PHP Manual](https://www.php.net/manual/en/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [CustomTkinter Wiki](https://github.com/TomSchimansky/CustomTkinter/wiki)

### Project Links
- Repository: https://github.com/yourusername/IsotoneStack
- Issues: https://github.com/yourusername/IsotoneStack/issues
- Wiki: https://github.com/yourusername/IsotoneStack/wiki

## 🆘 Troubleshooting Guide

### Service Issues
1. Check Windows Event Viewer
2. Verify service registration: `sc query IsotoneApache`
3. Check port availability: `netstat -ano | findstr :80`
4. Review logs in `/logs/` directory

### GUI Issues
1. Verify Python 3.11+ is installed
2. Check virtual environment activation
3. Install requirements: `pip install -r requirements.txt`
4. Run with console for error output

### Path Issues
- Apache uses forward slashes: `C:/isotone/www`
- Windows uses backslashes: `C:\isotone\www`
- PowerShell accepts both
- Always use `Path.join()` in Python

## ✅ Testing Checklist

Before committing changes:
- [ ] Scripts run without errors
- [ ] Services start/stop correctly
- [ ] GUI launches and all pages work
- [ ] Configurations are valid
- [ ] No hardcoded user-specific paths
- [ ] Documentation is updated
- [ ] .gitignore rules are followed

---

**Remember**: IsotoneStack aims to be a zero-configuration, portable development environment. Keep it simple, reliable, and developer-friendly!