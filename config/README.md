Configuration Templates for IsotoneStack
=========================================

This directory contains configuration templates used by the IsotoneStack installer.

Template Files:
- httpd.conf.template - Apache HTTP Server configuration
- php.ini.template - PHP configuration (if available)
- my.ini.template - MariaDB configuration  
- phpmyadmin.config.template - phpMyAdmin configuration

Placeholders:
The following placeholders are replaced during installation:
- {{INSTALL_PATH}} - The installation directory (e.g., C:\isotone)
- {{BLOWFISH_SECRET}} - Random 32-character string for phpMyAdmin
- {{ADMIN_PASSWORD}} - Administrator password (if set)

Usage:
The installer (Setup-IsotoneStack.ps1) will:
1. Copy these templates to their respective locations
2. Replace all placeholders with actual values
3. Adjust paths for the current installation directory

Notes:
- These templates are used only if the target configuration files don't already exist
- Existing configuration files are never overwritten
- Manual changes should be made to the actual config files, not these templates