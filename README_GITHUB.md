# 🚀 IsotoneStack

<div align="center">
  
  [![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/IsotoneStack/releases)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  [![Windows](https://img.shields.io/badge/platform-Windows%2010%2F11-0078D6.svg)](https://www.microsoft.com/windows)
  [![Python](https://img.shields.io/badge/python-3.11+-yellow.svg)](https://www.python.org/)
  
  **A modern, portable Windows development stack with a beautiful GUI control panel**
  
  [Features](#features) • [Installation](#installation) • [Usage](#usage) • [Documentation](#documentation) • [Contributing](#contributing)

  <img src="docs/images/dashboard.png" alt="IsotoneStack Dashboard" width="800"/>
  
</div>

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Components](#components)
- [Control Panel](#control-panel)
- [Configuration](#configuration)
- [Virtual Hosts](#virtual-hosts)
- [Database Management](#database-management)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🌟 Overview

IsotoneStack is a complete, portable WAMP (Windows, Apache, MySQL/MariaDB, PHP) development environment that installs to `C:\isotone` with zero dependencies. It features a modern GUI control panel built with Python and CustomTkinter for easy service management.

### Why IsotoneStack?

- **🎯 Zero Configuration**: Works out of the box with optimized settings
- **📦 Truly Portable**: No registry modifications, completely self-contained
- **🎨 Modern UI**: Beautiful dark/light theme control panel
- **⚡ Latest Versions**: Always uses the latest stable releases
- **🔧 Developer Friendly**: Built by developers, for developers

## ✨ Features

### Core Stack
- **Apache 2.4.62** - High-performance web server
- **PHP 8.3.x** - Latest PHP with all essential extensions
- **MariaDB 11.4.x LTS** - MySQL-compatible database
- **phpMyAdmin 5.2.x** - Web-based database management

### Control Panel GUI
- 🎨 **Modern Interface**: CustomTkinter with dark/light themes
- 📊 **Real-time Dashboard**: Service status, resource usage, quick stats
- ⚙️ **Service Management**: Start/stop/restart with animations
- 🌐 **Virtual Hosts Manager**: Drag-drop site creation
- 🗄️ **Database Manager**: Integrated database tools
- 🔌 **Port Manager**: Automatic conflict detection
- 📝 **Log Viewer**: Real-time log streaming
- 🔔 **System Tray**: Background operation with quick access

### Developer Tools
- **PowerShell Scripts**: Automated installation and management
- **Batch Files**: Quick launchers for all functions
- **Configuration Templates**: Pre-optimized settings
- **SSL Support**: Built-in SSL certificate management
- **Backup System**: Automated backup capabilities

## 💻 System Requirements

### Minimum Requirements
- Windows 10 version 1903 or Windows 11
- 4 GB RAM (8 GB recommended)
- 2 GB free disk space
- 64-bit processor
- Administrator privileges for installation

### Software Requirements
- Python 3.11+ (for GUI control panel)
- Visual C++ Redistributable 2015-2022 (auto-installed)
- PowerShell 5.1+ (included in Windows)

## 🚀 Installation

### Quick Install

1. **Clone the repository**
   ```powershell
   git clone https://github.com/yourusername/IsotoneStack.git C:\isotone
   cd C:\isotone
   ```

2. **Run the installer as Administrator**
   ```powershell
   .\install.bat
   ```
   Or use PowerShell directly:
   ```powershell
   .\Install-IsotoneStack.ps1
   ```

3. **Start services**
   ```powershell
   .\start_services.bat
   ```

4. **Launch the Control Panel GUI**
   ```powershell
   cd control-panel
   .\launch.bat
   ```

### Manual Installation

See [detailed installation guide](docs/INSTALLATION.md) for manual setup instructions.

## 📦 Components

### Directory Structure
```
C:\isotone\
├── apache24/          # Apache web server
├── php/              # PHP runtime and extensions
├── mariadb/          # MariaDB database server
├── phpmyadmin/       # phpMyAdmin interface
├── www/              # Your websites go here
│   └── default/      # Default website
├── control-panel/    # Python GUI application
├── config/           # Configuration templates
├── logs/            # Service logs
├── ssl/             # SSL certificates
├── tmp/             # Temporary files
└── backups/         # Backup storage
```

### Service Details

| Service | Default Port | Service Name | Configuration |
|---------|-------------|--------------|---------------|
| Apache | 80, 443 | IsotoneApache | `apache24\conf\httpd.conf` |
| MariaDB | 3306 | IsotoneMariaDB | `mariadb\my.ini` |
| PHP-FPM | 9000 | - | `php\php.ini` |

## 🎮 Control Panel

### GUI Control Panel

The modern control panel provides a beautiful interface for managing your stack:

```bash
cd C:\isotone\control-panel
launch.bat
```

Features:
- **Dashboard**: Overview with real-time metrics
- **Service Control**: Individual and batch operations
- **Virtual Hosts**: Visual host management
- **Database Manager**: Browse and manage databases
- **Port Monitor**: Check port availability
- **Log Viewer**: Stream logs in real-time
- **Settings**: Theme and behavior configuration

### PowerShell Control Panel

Interactive menu-driven control:

```powershell
.\control-panel\IsotoneStack-Manager.ps1
```

### Quick Commands

| Command | Description |
|---------|-------------|
| `start_services.bat` | Start all services |
| `stop_services.bat` | Stop all services |
| `restart_services.bat` | Restart all services |
| `service_status.bat` | Check service status |
| `manager.bat` | Open control panel |
| `quick_launch.bat` | Quick action menu |

## ⚙️ Configuration

### Apache Configuration

Edit `C:\isotone\apache24\conf\httpd.conf`:

```apache
ServerRoot "C:/isotone/apache24"
Listen 80
DocumentRoot "C:/isotone/www/default"
```

### PHP Configuration

Edit `C:\isotone\php\php.ini`:

```ini
memory_limit = 512M
upload_max_filesize = 128M
post_max_size = 128M
max_execution_time = 300
```

### MariaDB Configuration

Edit `C:\isotone\mariadb\my.ini`:

```ini
[mysqld]
port = 3306
innodb_buffer_pool_size = 1G
max_connections = 200
```

## 🌐 Virtual Hosts

### Creating a Virtual Host

1. **Using GUI Control Panel**:
   - Open Control Panel → Virtual Hosts
   - Click "Add Virtual Host"
   - Enter domain and document root
   - Click Save

2. **Manual Configuration**:
   
   Add to `apache24\conf\extra\httpd-vhosts.conf`:
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

3. **Update hosts file** (`C:\Windows\System32\drivers\etc\hosts`):
   ```
   127.0.0.1 mysite.local
   ```

## 🗄️ Database Management

### Access phpMyAdmin
- URL: http://localhost/phpmyadmin
- Username: `root`
- Password: `isotone_admin`

### Command Line Access
```bash
C:\isotone\mariadb\bin\mysql.exe -u root -p
```

### Creating a Database
```sql
CREATE DATABASE my_project;
CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON my_project.* TO 'myuser'@'localhost';
FLUSH PRIVILEGES;
```

## 🔧 Troubleshooting

### Common Issues

#### Services Won't Start
- Run as Administrator
- Check port conflicts: `netstat -ano | findstr :80`
- Verify VC++ Runtime is installed

#### Port Conflicts
- Use Port Manager in GUI
- Change ports in configuration files
- Stop conflicting services

#### Permission Errors
- Ensure running as Administrator
- Check Windows Defender/Antivirus exceptions

### Log Files

- Apache: `C:\isotone\logs\apache\error.log`
- PHP: `C:\isotone\logs\php\error.log`
- MariaDB: `C:\isotone\logs\mariadb\error.log`

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- PowerShell: Follow [PowerShell Best Practices](https://poshcode.gitbook.io/powershell-practice-and-style/)
- Python: Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
- Use meaningful commit messages

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Licenses

- Apache: [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
- PHP: [PHP License](https://www.php.net/license/)
- MariaDB: [GPL v2](https://mariadb.com/kb/en/mariadb-license/)
- phpMyAdmin: [GPL v2](https://www.phpmyadmin.net/license/)

## 🙏 Acknowledgments

- Apache Software Foundation
- PHP Development Team
- MariaDB Foundation
- phpMyAdmin Team
- CustomTkinter by Tom Schimansky
- All contributors and users

## 📞 Support

- 📧 Email: support@isotonestack.com
- 💬 Discord: [Join our server](https://discord.gg/isotonestack)
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/IsotoneStack/issues)
- 📖 Wiki: [Documentation](https://github.com/yourusername/IsotoneStack/wiki)

---

<div align="center">
  Made with ❤️ by the IsotoneStack Team
  
  ⭐ Star us on GitHub!
</div>