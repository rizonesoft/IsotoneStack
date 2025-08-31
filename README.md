# IsotoneStack - Portable Windows Development Environment

A complete, portable WAMP (Windows, Apache, MySQL/MariaDB, PHP) stack distributed as a pre-bundled package with the latest stable versions of all components.

## 📦 Distribution Model

IsotoneStack follows the XAMPP distribution model:
- **Pre-bundled components** - All binaries included in the download
- **No internet required** - Works completely offline after download
- **Portable installation** - Can be moved between systems
- **Zero configuration** - Works out of the box
- **Complete distribution** - All components in `distribution/isotone-components/`

### Component Distribution
All required components are pre-bundled in `C:\isotone\distribution\isotone-components\`:
- Apache, PHP, MariaDB binaries
- Database management tools (phpMyAdmin, Adminer, phpLiteAdmin)
- Development tools (Mailpit, PowerShell)
- All dependencies and utilities
- Ready for offline installation

See [distribution/isotone-components/COMPONENTS.md](distribution/isotone-components/COMPONENTS.md) for complete component list.

## 🚀 Components

### Core Services
- **Apache** 2.4.65 (Latest stable web server)
- **PHP** 8.4.11 (Latest stable PHP runtime)
- **MariaDB** 12.0.2 (Latest stable database server)
- **SQLite** 3 (Built into PHP - file-based database)

### Management Tools
- **phpMyAdmin** 5.2.2 (Latest stable - MariaDB management)
- **phpLiteAdmin** 1.9.8.2 (SQLite database management)
- **Adminer** 5.3.0 (Universal database management - supports MariaDB, SQLite, PostgreSQL, and more)
- **Mailpit** 1.27.7 (Email testing tool - captures and displays emails sent by your applications)
- **Control Panel** - Modern Python/CustomTkinter GUI

### System Utilities
- **NSSM** 2.24 (Non-Sucking Service Manager - reliable Windows service management)
- **PowerShell** 7+ (Portable PowerShell for script execution)
- **VC++ Runtime** 2022 (Required runtime libraries)

## ✨ Features

- ✅ Complete portable package (no separate downloads)
- ✅ Modern GUI control panel
- ✅ Windows service integration
- ✅ No registry dependencies
- ✅ Pre-configured for optimal performance
- ✅ Virtual hosts manager
- ✅ Database management interface
- ✅ Email testing with Mailpit (captures all outgoing emails)
- ✅ System tray integration
- ✅ Dark/light theme support

## 📥 Installation

### Download Package
1. Download the complete IsotoneStack package (includes all components)
2. Extract to `C:\isotone`

### Manual Component Setup (for developers)
If you're building from source or updating components:

1. **Download components manually:**
   - Apache 2.4.65+ from [apachelounge.com](https://www.apachelounge.com/download/)
   - PHP 8.4.11+ from [windows.php.net](https://windows.php.net/download/)
   - MariaDB 12.0.2+ from [mariadb.org](https://mariadb.org/download/)
   - phpMyAdmin 5.2.2+ from [phpmyadmin.net](https://www.phpmyadmin.net/downloads/)
   - phpLiteAdmin 1.9.8.2+ from [phpliteadmin.org](https://www.phpliteadmin.org/)
   - Adminer 5.3.0+ from [adminer.org](https://www.adminer.org/)
   - Mailpit 1.27.7+ from [github.com/axllent/mailpit](https://github.com/axllent/mailpit/releases)

2. **Extract to correct directories:**
   ```
   C:\isotone\apache24\      ← Apache files
   C:\isotone\php\           ← PHP files
   C:\isotone\mariadb\       ← MariaDB files
   C:\isotone\phpmyadmin\    ← phpMyAdmin files
   C:\isotone\phpliteadmin\  ← phpLiteAdmin files
   C:\isotone\adminer\       ← Adminer files
   C:\isotone\mailpit\       ← Mailpit executable
   ```

3. **Run setup script:**
   ```powershell
   cd C:\isotone
   .\Setup-IsotoneStack.ps1
   ```

## 🎮 Control Panel

### GUI Control Panel (Recommended)
```batch
C:\isotone\control-panel\launch.bat
```

Features:
- Service management (start/stop/restart)
- Virtual hosts configuration
- Database management
- Port configuration
- Log viewer
- Settings management

### PowerShell Scripts
Located in `C:\isotone\`:

```powershell
# Configure and register services (run once)
.\Setup-IsotoneStack.ps1

# Start all services
.\Start-Services.ps1

# Stop all services
.\Stop-Services.ps1

# Check service status
.\Check-Status.ps1

# Uninstall services (preserves files)
.\Uninstall-Services.ps1
```

## 📁 Directory Structure

```
C:\isotone\
├── apache24/          # Apache 2.4.65+ binaries
├── php/               # PHP 8.4.11+ binaries
├── mariadb/           # MariaDB 12.0.2+ binaries
├── sqlite/            # SQLite databases directory
├── phpmyadmin/        # phpMyAdmin 5.2.2+ web app
├── phpliteadmin/      # phpLiteAdmin 1.9.8.2 SQLite manager
├── adminer/           # Adminer 5.3.0 universal DB manager
├── mailpit/           # Mailpit 1.27.7 email testing tool
├── bin/               # System utilities
│   └── nssm.exe       # NSSM 2.24 service manager
├── runtime/           # VC++ Runtime installer (included)
│   └── vc_redist.x64.exe
├── distribution/      # Component distribution packages
│   └── isotone-components/  # All pre-bundled components
│       ├── apache24/         # Apache distribution
│       ├── php/              # PHP distribution
│       ├── mariadb/          # MariaDB distribution
│       ├── mailpit/          # Mailpit distribution
│       ├── adminer/          # Adminer distribution
│       ├── phpmyadmin/       # phpMyAdmin distribution
│       ├── phpliteadmin/     # phpLiteAdmin distribution
│       ├── pwsh/             # PowerShell distribution
│       └── bin/              # Binary utilities
├── control-panel/     # Python GUI application
│   ├── main.py        # Main application entry
│   ├── ui/            # UI components
│   └── services/      # Service management
├── www/               # Your websites go here
│   └── default/       # Default website
├── logs/              # Centralized logs
├── config/            # Configuration templates
├── ssl/               # SSL certificates
├── tmp/               # Temporary files
└── backups/           # Database backups
```

## 🌐 Access Points

- **Web Server:** http://localhost
- **phpMyAdmin:** http://localhost/phpmyadmin (MariaDB management)
- **phpLiteAdmin:** http://localhost/phpliteadmin (SQLite management)
- **Adminer:** http://localhost/adminer (Universal database management)
- **SQLite Direct:** http://localhost/sqlite (Alias to phpLiteAdmin)
- **Mailpit Web UI:** http://localhost:8025 (Email testing interface)
- **MariaDB:** localhost:3306
- **Mailpit SMTP:** localhost:1025 (SMTP server for capturing emails)
- **SQLite:** File-based in C:\isotone\sqlite\
  - Default user: `root`
  - Default password: *(set during setup)*

## ⚙️ Configuration

### Service Ports
- Apache: 80, 443 (SSL)
- MariaDB: 3306
- Mailpit SMTP: 1025
- Mailpit Web UI: 8025
- PHP: Via Apache module

### Configuration Files
- Apache: `C:\isotone\apache24\conf\httpd.conf`
- PHP: `C:\isotone\php\php.ini`
- MariaDB: `C:\isotone\mariadb\data\my.ini`
- phpMyAdmin: `C:\isotone\phpmyadmin\config.inc.php`

## 🛠️ Troubleshooting

### Services Won't Start

1. **Check Administrator privileges:**
   ```powershell
   # Run PowerShell as Administrator
   ```

2. **Check port conflicts:**
   ```powershell
   netstat -ano | findstr :80
   netstat -ano | findstr :3306
   ```

3. **Check Visual C++ Runtime:**
   - Included in `runtime\vc_redist.x64.exe`
   - Auto-installed by Setup script
   - Manual install: Run `runtime\vc_redist.x64.exe`

### View Logs

```powershell
# Apache errors
Get-Content C:\isotone\logs\apache\error.log -Tail 20

# PHP errors
Get-Content C:\isotone\logs\php\error.log -Tail 20

# MariaDB errors
Get-Content C:\isotone\logs\mariadb\error.log -Tail 20
```

## 🔧 Advanced Usage

### Virtual Hosts

1. Use the Control Panel's Virtual Hosts Manager, or
2. Edit `C:\isotone\apache24\conf\extra\httpd-vhosts.conf`:

```apache
<VirtualHost *:80>
    ServerName myproject.local
    DocumentRoot "C:/isotone/www/myproject"
    <Directory "C:/isotone/www/myproject">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

3. Add to `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1 myproject.local
```

### PHP Configuration

Create `.user.ini` in your project:
```ini
memory_limit = 1024M
max_execution_time = 600
upload_max_filesize = 256M
post_max_size = 256M
```

### Email Testing with Mailpit

Mailpit captures all emails sent by your PHP applications for testing:

1. **Configure PHP to use Mailpit** (already configured in php.ini):
```ini
SMTP = localhost
smtp_port = 1025
```

2. **Start Mailpit service** (auto-starts with IsotoneStack):
```powershell
.\Start-Services.ps1  # Includes Mailpit
```

3. **View captured emails**:
   - Open http://localhost:8025
   - All emails sent by your applications appear here
   - No emails are actually sent externally

4. **PHP mail() example**:
```php
mail('test@example.com', 'Test Subject', 'Test message body');
// This email will be captured by Mailpit
```

### SSL Setup

1. Generate certificates in `C:\isotone\ssl\`
2. Enable SSL in Apache configuration
3. Restart Apache service

## 📊 System Requirements

- **OS:** Windows 10/11 (64-bit)
- **RAM:** 2GB minimum, 4GB+ recommended
- **Disk:** 2GB for installation
- **Runtime:** Visual C++ 2019-2022 Redistributable (included in `runtime` folder)

## 🔒 Security Notes

⚠️ **Default configuration is for development only!**

For production:
1. Change all default passwords
2. Restrict service access
3. Enable firewall rules
4. Configure SSL/TLS
5. Disable debug modes
6. Review security settings

## 📝 License

IsotoneStack distribution is open source. Individual components are subject to their respective licenses:
- Apache: Apache License 2.0
- PHP: PHP License 3.01
- MariaDB: GPL v2
- phpMyAdmin: GPL v2
- Adminer: Apache License 2.0 or GPL v2
- Mailpit: MIT License

## 🆘 Support

- **Documentation:** See `/docs` directory
- **Issues:** Report on GitHub
- **Logs:** Check `C:\isotone\logs\`
- **Status:** Run Control Panel or `.\Check-Status.ps1`

---

**IsotoneStack** - Professional Development Environment for Windows
Version 1.0 | Built with the latest stable components