# IsotoneStack Components Distribution

This directory contains all pre-bundled components for IsotoneStack, ready for offline installation.

## 📦 Component List

### Web Server & Runtime
- **Apache 2.4.65** - HTTP Server (`apache24/`)
  - Complete Apache distribution from ApacheLounge
  - Includes all modules and configuration files
  - Pre-configured for Windows

- **PHP 8.4.11** - PHP Runtime (`php/`)
  - Thread-safe build for Apache integration
  - Includes all essential extensions
  - Pre-configured php.ini for development

### Databases
- **MariaDB 12.0.2** - MySQL-compatible database (`mariadb/`)
  - Full MariaDB server distribution
  - Command-line tools included
  - Ready for Windows service installation

### Database Management Tools
- **phpMyAdmin 5.2.2** - MariaDB/MySQL web interface (`phpmyadmin/`)
  - Full web application
  - Pre-configured for MariaDB connection
  - Includes all themes and libraries

- **phpLiteAdmin 1.9.8.2** - SQLite management (`phpliteadmin/`)
  - Lightweight SQLite database manager
  - Single-file PHP application
  - Pre-configured for IsotoneStack

- **Adminer 5.3.0** - Universal database tool (`adminer/`)
  - Supports multiple database systems
  - Single-file PHP application
  - Includes plugins and themes

### Development Tools
- **Mailpit 1.27.7** - Email testing tool (`mailpit/`)
  - Captures outgoing emails for testing
  - Web UI for viewing captured emails
  - SMTP server on port 1025

- **PowerShell 7** - Portable PowerShell (`pwsh/`)
  - Complete PowerShell 7 runtime
  - No installation required
  - Used by all IsotoneStack scripts

### Utilities
- **Binary Tools** (`bin/`)
  - **NSSM 2.24** - Non-Sucking Service Manager
    - Reliable Windows service management
    - Used for Mailpit and other non-Windows services
    - Better service control than Windows SC
  - Essential command-line utilities
  - Includes wget, 7-zip, and other tools
  - Required for component management

## 📋 Version Information

| Component | Version | Architecture | License |
|-----------|---------|--------------|---------|
| Apache | 2.4.65 | x64 | Apache License 2.0 |
| PHP | 8.4.11 | x64 TS | PHP License 3.01 |
| MariaDB | 12.0.2 | x64 | GPL v2 |
| phpMyAdmin | 5.2.2 | - | GPL v2 |
| phpLiteAdmin | 1.9.8.2 | - | GPL v3 |
| Adminer | 5.3.0 | - | Apache/GPL v2 |
| Mailpit | 1.27.7 | x64 | MIT |
| NSSM | 2.24 | x64 | Public Domain |
| PowerShell | 7.x | x64 | MIT |

## 🔧 Component Structure

Each component is self-contained with:
- All required binaries and libraries
- Configuration files (where applicable)
- Documentation and licenses
- No external dependencies

## 📝 Notes

- All components are Windows x64 builds
- Components are pre-configured for `C:\isotone` installation
- No internet connection required after download
- Components can be updated individually if needed

## 🚀 Usage

These components are automatically deployed by the IsotoneStack setup scripts:
1. Extract IsotoneStack to `C:\isotone`
2. Run `Setup-IsotoneStack.ps1`
3. Components are configured and services registered

## ⚠️ Important

- Do not manually modify component files
- Configuration changes should be made in `C:\isotone\config\`
- Updates should be performed through official IsotoneStack releases
- Keep all components in sync for compatibility

## 📄 Licenses

Each component retains its original license:
- See individual component directories for specific license files
- All components are open source and free for commercial use
- IsotoneStack distribution follows all component licensing terms

---

**IsotoneStack Components** - Pre-bundled for offline installation
Version 1.0 | All components included