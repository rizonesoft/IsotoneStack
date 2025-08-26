# IsotoneStack - Portable Windows Development Environment

A complete, portable WAMP (Windows, Apache, MySQL/MariaDB, PHP) stack that installs to `C:\isotone` with the latest stable versions of all components.

## Components

- **Apache** 2.4.62 (Latest stable)
- **PHP** 8.3.15 (Latest 8.3.x stable)
- **MariaDB** 11.4.4 (Latest LTS)
- **phpMyAdmin** 5.2.1 (Latest stable)

## Features

- ✅ Completely portable installation
- ✅ No registry dependencies
- ✅ Automatic service installation
- ✅ Pre-configured for optimal performance
- ✅ Interactive control panel
- ✅ Latest stable versions
- ✅ Windows service integration
- ✅ Automatic VC++ Runtime detection

## Quick Start

### Installation

1. **Run PowerShell as Administrator**

2. **Navigate to the isotone directory:**
   ```powershell
   cd C:\isotone
   ```

3. **Run the installation script:**
   ```powershell
   .\Install-IsotoneStack.ps1
   ```

4. **Start the services:**
   ```powershell
   .\control-panel\start.ps1
   ```

### Access Points

- **Web Server:** http://localhost
- **phpMyAdmin:** http://localhost/phpmyadmin
- **Database:** localhost:3306
  - Default user: `root`
  - Default password: `isotone_admin`

## Directory Structure

```
C:\isotone\
├── apache24/          # Apache installation
├── php/              # PHP installation
├── mariadb/          # MariaDB installation
├── phpmyadmin/       # phpMyAdmin installation
├── control-panel/    # Management scripts
├── logs/            # Log files for all services
├── tmp/             # Temporary files
├── ssl/             # SSL certificates
├── backups/         # Backup directory
├── config/          # Configuration templates
└── www/             # Website files
    └── default/     # Default website
```

## Control Panel Scripts

All management scripts are located in `C:\isotone\control-panel\`:

### Basic Commands

```powershell
# Start all services
.\start.ps1

# Stop all services
.\stop.ps1

# Restart all services
.\restart.ps1

# Check service status
.\status.ps1

# Uninstall services (preserves files)
.\uninstall.ps1

# Complete uninstall (removes all files)
.\uninstall.ps1 -RemoveData
```

### Interactive Manager

Launch the interactive control panel:

```powershell
.\IsotoneStack-Manager.ps1
```

Features:
- Service management (start/stop/restart)
- Log viewer
- Configuration editor
- Installation testing
- System information
- Visual status display

## Configuration Files

### Apache
- Main config: `C:\isotone\apache24\conf\httpd.conf`
- Template: `C:\isotone\config\httpd-isotone.conf`

### PHP
- Main config: `C:\isotone\php\php.ini`
- Template: `C:\isotone\config\php-isotone.ini`

### MariaDB
- Main config: `C:\isotone\mariadb\my.ini`
- Template: `C:\isotone\config\my-isotone.ini`

### phpMyAdmin
- Main config: `C:\isotone\phpmyadmin\config.inc.php`

## Default Settings

### PHP Extensions Enabled
- curl, fileinfo, gd, mbstring, mysqli, openssl, pdo_mysql, zip, and more

### MariaDB Settings
- InnoDB buffer pool: 1GB
- Max connections: 200
- Character set: utf8mb4

### Apache Modules
- mod_rewrite enabled
- mod_ssl available
- PHP module configured

## Troubleshooting

### Services Won't Start

1. **Check if running as Administrator:**
   - Right-click PowerShell → Run as Administrator

2. **Check port conflicts:**
   ```powershell
   netstat -ano | findstr :80
   netstat -ano | findstr :3306
   ```

3. **Check Visual C++ Runtime:**
   - The installer automatically downloads if needed
   - Manual download: https://aka.ms/vs/17/release/vc_redist.x64.exe

### View Logs

```powershell
# Apache error log
Get-Content C:\isotone\logs\apache\error.log -Tail 20

# PHP error log
Get-Content C:\isotone\logs\php\error.log -Tail 20

# MariaDB error log
Get-Content C:\isotone\logs\mariadb\error.log -Tail 20
```

### Reset MariaDB Password

```powershell
# Stop MariaDB
.\control-panel\stop.ps1

# Start MariaDB in safe mode
C:\isotone\mariadb\bin\mysqld.exe --skip-grant-tables

# In another PowerShell window
C:\isotone\mariadb\bin\mysql.exe -u root
```

Then run:
```sql
UPDATE mysql.user SET Password=PASSWORD('new_password') WHERE User='root';
FLUSH PRIVILEGES;
EXIT;
```

## Advanced Usage

### Adding Virtual Hosts

Edit `C:\isotone\apache24\conf\extra\httpd-vhosts.conf`:

```apache
<VirtualHost *:80>
    ServerName mysite.local
    DocumentRoot "C:/isotone/www/mysite"
    <Directory "C:/isotone/www/mysite">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

Add to `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1 mysite.local
```

### Custom PHP Configuration

Create a `.user.ini` file in your web directory:
```ini
memory_limit = 1024M
max_execution_time = 600
upload_max_filesize = 256M
```

### SSL Configuration

1. Generate certificates in `C:\isotone\ssl\`
2. Uncomment in `httpd.conf`:
   ```apache
   Include conf/extra/httpd-ssl.conf
   ```
3. Restart Apache

## Installation Options

```powershell
# Custom installation path
.\Install-IsotoneStack.ps1 -InstallPath "D:\DevStack"

# Skip VC++ Runtime check
.\Install-IsotoneStack.ps1 -SkipVCRedist

# Force reinstall (overwrites existing)
.\Install-IsotoneStack.ps1 -Force
```

## Updates

To update components:

1. Stop all services
2. Backup your data and configurations
3. Run installation with `-Force` flag:
   ```powershell
   .\Install-IsotoneStack.ps1 -Force
   ```

## Security Notes

⚠️ **Default installation is configured for development use only!**

For production:
1. Change default database passwords
2. Restrict Apache access
3. Disable PHP error display
4. Configure firewall rules
5. Enable SSL/TLS
6. Review and harden all configurations

## Support

- Check service status: `.\control-panel\status.ps1`
- Test installation: Run option 6 in the Manager
- View system info: Run option 7 in the Manager
- All logs are in: `C:\isotone\logs\`

## License

This stack installer is provided as-is for development purposes. Individual components are subject to their respective licenses:
- Apache: Apache License 2.0
- PHP: PHP License
- MariaDB: GPL v2
- phpMyAdmin: GPL v2

---

**IsotoneStack** - Simplifying Windows Development Environments