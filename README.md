# IsotoneStack - Portable Windows Development Environment

A complete, portable WAMP (Windows, Apache, MySQL/MariaDB, PHP) stack distributed as a pre-bundled package with the latest stable versions of all components.

## 📦 Distribution Model

IsotoneStack follows the XAMPP distribution model:
- **Pre-bundled components** - All binaries included in the download
- **No internet required** - Works completely offline after download
- **Portable installation** - Can be moved between systems
- **Zero configuration** - Works out of the box

## 🚀 Components

- **Apache** 2.4.65 (Latest stable)
- **PHP** 8.4.11 (Latest stable)
- **MariaDB** 12.0.2 (Latest stable)
- **phpMyAdmin** 5.2.2 (Latest stable)
- **Control Panel** - Modern Python/CustomTkinter GUI

## ✨ Features

- ✅ Complete portable package (no separate downloads)
- ✅ Modern GUI control panel
- ✅ Windows service integration
- ✅ No registry dependencies
- ✅ Pre-configured for optimal performance
- ✅ Virtual hosts manager
- ✅ Database management interface
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

2. **Extract to correct directories:**
   ```
   C:\isotone\apache24\    ← Apache files
   C:\isotone\php\         ← PHP files
   C:\isotone\mariadb\     ← MariaDB files
   C:\isotone\phpmyadmin\  ← phpMyAdmin files
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
├── phpmyadmin/        # phpMyAdmin 5.2.2+ web app
├── runtime/           # VC++ Runtime installer (included)
│   └── vc_redist.x64.exe
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
- **phpMyAdmin:** http://localhost/phpmyadmin
- **MariaDB:** localhost:3306
  - Default user: `root`
  - Default password: *(set during setup)*

## ⚙️ Configuration

### Service Ports
- Apache: 80, 443 (SSL)
- MariaDB: 3306
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

## 🆘 Support

- **Documentation:** See `/docs` directory
- **Issues:** Report on GitHub
- **Logs:** Check `C:\isotone\logs\`
- **Status:** Run Control Panel or `.\Check-Status.ps1`

---

**IsotoneStack** - Professional Development Environment for Windows
Version 1.0 | Built with the latest stable components