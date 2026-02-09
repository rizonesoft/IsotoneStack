# IsotoneStack Master TODO

## iso-control (Control Panel)

### Phase 1: Complete Stub Views

- [ ] Expand DatabaseViewModel with full functionality
- [ ] Add services to DatabaseViewModel (ServiceManager, SnackbarMessageQueue, ObservableProperties)
- [ ] Implement database listing using MariaDB CLI
- [ ] Design DatabaseView.xaml (version selector, DataGrid, details panel, action buttons, connection string)
- [ ] Add database creation dialog (name, character set, collation)
- [ ] Add import/export functionality with file picker and progress indicator
- [ ] Replace placeholder log loading with real file-reading implementation
- [ ] Add log tailing (live updates via FileSystemWatcher)
- [ ] Add log filtering and search (by level, regex)
- [ ] Design LogsView.xaml (file selector, content viewer, live tail toggle, search bar, filter, clear, open external, auto-scroll)

### Phase 2: MariaDB Multi-Version Support

- [ ] Detect installed MariaDB versions (MariaDBManager utility)
- [ ] Add version switching ComboBox to DashboardView with restart prompt
- [ ] Implement SwitchMariaDBVersionAsync command
- [ ] Show current MariaDB version on service card
- [ ] Add version dropdown to MariaDB section (like PHP)
- [ ] Show data directory size per version

### Phase 3: Service Configuration Dialogs

- [ ] Create ApacheConfigDialog (port, document root, SSL, modules, vhosts, open httpd.conf)
- [ ] Create MariaDBConfigDialog (port, root password, buffer pool, max connections, charset, collation, open my.ini)
- [ ] Create MailpitConfigDialog (SMTP port, web UI port, authentication, storage)

### Phase 4: Virtual Hosts Management

- [ ] Create VirtualHostsView.xaml (list, add/edit/delete, enable/disable toggle, SSL indicator)
- [ ] Create VirtualHostsViewModel (CRUD commands, VirtualHost model)
- [ ] Implement hosts file management (add/remove entries, admin privilege warning)
- [ ] Create AddVirtualHostDialog (server name, doc root, port, SSL, PHP version override, template)

### Phase 5: System Tray Integration

- [ ] Add NotifyIcon to App.xaml.cs
- [ ] Create tray context menu (show, start/stop all, open localhost, open phpMyAdmin, exit)
- [ ] Implement minimize to tray behavior
- [ ] Show service status in tray icon (green/yellow/red)
- [ ] Add balloon notifications for service started/stopped/errors

### Phase 6: Backup & Restore UI

- [ ] Create BackupView.xaml (type selection, database picker, destination, schedule, history)
- [ ] Create BackupViewModel (create, restore, delete, schedule commands)
- [ ] Add "Backup Now" button to Dashboard quick actions
- [ ] Implement one-click backup functionality

### Phase 7: UI/UX Improvements

- [ ] Add keyboard shortcuts (F1-F5)
- [ ] Add breadcrumb navigation
- [ ] Remember last active view on restart
- [ ] Add quick statistics cards (databases, vhosts, extensions, disk space)
- [ ] Add service uptime display
- [ ] Add quick action bar
- [ ] Add theme selection (Light/Dark/System)
- [ ] Add accent color customization
- [ ] Improve responsive layout for different window sizes
- [ ] Add status bar (PHP version, MariaDB version, service status, last refresh)

### Phase 8: Settings Improvements

- [ ] General Settings (start with Windows, minimize to tray, check for updates, language)
- [ ] Appearance Settings (theme, accent color, font size)
- [ ] Advanced Settings (debug mode, log verbosity, custom paths)
- [ ] About Section (version info, check for updates, GitHub link, credits/license)
- [ ] Add settings validation
- [ ] Add import/export settings

### Phase 9: Testing & Quality

- [ ] Add proper exception handling to all async operations
- [ ] Add retry logic for service operations
- [ ] Improve error messages with actionable suggestions
- [ ] Reduce service polling frequency when minimized
- [ ] Lazy load views that aren't immediately visible
- [ ] Optimize log file reading (don't load entire file)
- [ ] Add unit test project (Isotone.Tests)
- [ ] Test ServiceManager operations
- [ ] Test ConfigurationManager operations
- [ ] Test PHPManager operations

---

## Installer (InnoSetup)

### Phase 1: Make All Components Mandatory

- [ ] Change from selectable to fixed installation (single type)
- [ ] Mark ALL components as fixed (not removable)
- [ ] Hide component selection page entirely (ShouldSkipPage)
- [ ] Remove component conditions from mandatory file entries

### Phase 2: Dynamic Version Detection

- [ ] Remove hardcoded versions from component descriptions
- [ ] Add version detection in [Code] section
- [ ] Create version constants file (version.iss)
- [ ] Include version.iss in main script

### Phase 3: Pre-Installation Checks

- [ ] Add port conflict detection (80, 3306) in InitializeSetup
- [ ] Check for XAMPP, WAMP, Laragon installations
- [ ] Add realistic disk space requirement (~2GB)

### Phase 4: MariaDB Multi-Version Installer Support

- [ ] Modify MariaDB source for versioned directory structure (10.11.15, 11.8.5, 12.1.2)
- [ ] Create version-specific data directories in [Dirs]
- [ ] Create wizard page for default MariaDB version selection

### Phase 5: Post-Installation Improvements

- [ ] Add post-install verification step (check critical files exist)
- [ ] Add optional README display after install
- [ ] Add web browser launch option after install

### Phase 6: Build Process Improvements

- [ ] Add version extraction from source in Build-Installer.bat
- [ ] Add build timestamp to output filename
- [ ] Add SHA256 checksum generation
- [ ] Create component update script (download, update version.iss, validate integrity)

### Phase 7: Uninstallation Improvements

- [ ] Add uninstall dialog for data preservation (keep/remove www, data, configs)
- [ ] Add timeout and force kill for services before uninstall

---

## MariaDB Multi-Version

### Phase 4: Initialize and Import Data (Remaining)

- [ ] Verify databases created on 10.11 (`SHOW DATABASES`)
- [ ] Import each database from migration-ready backups to 10.11
- [ ] Handle import errors (collation, syntax, stored procedures)

### Phase 8: Version Switching Script

- [ ] Create Switch-MariaDBVersion.ps1 with -Version, -NoRestart, -ListVersions parameters
- [ ] Implement version discovery (scan mariadb/ for versioned dirs)
- [ ] Implement version validation (check mariadbd.exe exists)
- [ ] Implement data directory mapping (major.minor)
- [ ] Implement service stop/reconfigure/start
- [ ] Implement service restart with version verification
- [ ] Display current vs target version before switching
- [ ] Add data compatibility warning (data not shared between versions)
- [ ] Create Switch-MariaDBVersion.bat launcher
- [ ] Create Migrate-MariaDBData.ps1 helper (export, collation convert, import)
- [ ] Add usage examples to script help
- [ ] Test switching between versions (10.11 <> 12.1.2)
- [ ] Verify data directory isolation after switch
- [ ] Update Isotone README.md with version switching docs

---

## Web Application Installer

### Framework & Architecture

- [ ] Create Install-WebApp.ps1 script with -App, -Directory, -Database parameters
- [ ] Create Install-WebApp.ps1.bat launcher
- [ ] Design app recipe system (JSON/YAML manifest per app with download URLs, requirements, post-install steps)
- [ ] Store app recipes in config/webapps/ directory
- [ ] Implement download and extraction logic (ZIP from official sources)
- [ ] Implement database auto-creation (CREATE DATABASE via MariaDB CLI)
- [ ] Implement wp-config.php / .env auto-generation from templates
- [ ] Implement virtual host auto-creation for new apps
- [ ] Implement hosts file entry for new virtual host
- [ ] Add -ListApps parameter to show available applications

### WordPress Installer

- [ ] Download latest WordPress from wordpress.org API
- [ ] Auto-create database and wp-config.php with random salts
- [ ] Set correct file permissions for www/ subdirectory
- [ ] Configure WordPress to use Mailpit SMTP for email
- [ ] Optionally run WP-CLI silent install (headless site setup)

### Laravel Installer

- [ ] Bundle Composer in composer/ directory (composer.phar)
- [ ] Run composer create-project laravel/laravel via bundled PHP
- [ ] Auto-create database and populate .env with MariaDB credentials
- [ ] Run php artisan key:generate and php artisan migrate
- [ ] Configure Laravel mail to use Mailpit

### Additional App Support

- [ ] Add Drupal recipe (download, database, settings.php)
- [ ] Add Joomla recipe (download, database, configuration.php)
- [ ] Add Symfony recipe (Composer create-project, .env)
- [ ] Add CodeIgniter recipe (Composer create-project, .env)
- [ ] Add plain PHP project recipe (empty skeleton with index.php)

### iso-control Integration

- [ ] Add "New Project" button to Dashboard
- [ ] Create NewProjectDialog (app type dropdown, directory name, database name)
- [ ] Show installed web apps list with status indicators
- [ ] Add "Open in Browser" and "Open in Explorer" actions per project

### Web Control Panel Integration

- [ ] Complete the stub files.php page (file manager or project listing)
- [ ] Add "Create New Project" card to default/control dashboard
- [ ] Add project listing API endpoint in default/control/api/

---

## GitHub & Repository

### Community Files

- [ ] Create CHANGELOG.md (document releases, use Keep a Changelog format)
- [ ] Create CONTRIBUTING.md (how to build, test, and submit PRs)
- [ ] Create SECURITY.md (vulnerability reporting process)
- [ ] Create CODE_OF_CONDUCT.md
- [ ] Create .github/ISSUE_TEMPLATE/bug_report.md
- [ ] Create .github/ISSUE_TEMPLATE/feature_request.md
- [ ] Create .github/PULL_REQUEST_TEMPLATE.md
- [ ] Create .github/FUNDING.yml (if applicable)

### README.md Overhaul

- [ ] Update component versions (PHP 8.3/8.4/8.5, MariaDB 10.11/11.8/12.1)
- [ ] Remove Python control panel references (now WPF .NET 9)
- [ ] Fix hardcoded C:\isotone paths (use portable relative paths)
- [ ] Fix script references (Setup-IsotoneStack.ps1 -> Configure-IsotoneStack.ps1, etc.)
- [ ] Update directory structure to reflect current layout (iso-control, multi-version PHP/MariaDB)
- [ ] Add badges (build status, license, latest release, GitHub stars)
- [ ] Add screenshot or GIF of iso-control and web dashboard
- [ ] Add "Quick Start" section with minimal steps
- [ ] Document multi-version PHP and MariaDB switching
- [ ] Document web application installer feature (when built)

### GitHub Releases

- [ ] Create first official GitHub release with version tag
- [ ] Upload installer (.exe) as release asset
- [ ] Upload portable ZIP as release asset
- [ ] Include SHA256 checksums in release notes
- [ ] Write release notes template for future releases

### GitHub Actions (CI/CD)

- [ ] Add workflow to build iso-control (dotnet build/publish)
- [ ] Add workflow to compile InnoSetup installer
- [ ] Add workflow to run iso-control unit tests
- [ ] Add workflow to auto-create GitHub releases on tag push
- [ ] Add workflow to validate PowerShell scripts (PSScriptAnalyzer)

### Repository Cleanup

- [ ] Audit .gitignore for missing patterns
- [ ] Remove stale TODO files after merging into TODO.md
- [ ] Add LICENSE headers to all scripts
- [ ] Verify all tracked files are intentional (no accidental binaries)

---

## Documentation

### User Documentation

- [ ] Create docs/ directory
- [ ] Write Getting Started guide (download, install, first project)
- [ ] Write PHP Version Switching guide
- [ ] Write MariaDB Version Switching guide
- [ ] Write Virtual Hosts setup guide
- [ ] Write SSL/HTTPS setup guide with self-signed cert generation
- [ ] Write Email Testing with Mailpit guide
- [ ] Write Troubleshooting FAQ
- [ ] Write Upgrading Components guide

### Developer Documentation

- [ ] Document iso-control architecture (MVVM, services, utilities)
- [ ] Document script conventions (template usage, logging, exit codes)
- [ ] Document configuration template system (variable substitution)
- [ ] Document how to add new bundled components

---

## Scripts & Infrastructure

### Missing Scripts

- [ ] Create Generate-SSLCert.ps1 (self-signed certificate generation using OpenSSL)
- [ ] Create Generate-SSLCert.ps1.bat launcher
- [ ] Create Backup-Databases.ps1 (scheduled/manual MariaDB backup)
- [ ] Create Backup-Databases.ps1.bat launcher
- [ ] Create Check-Status.ps1 (service health check with port verification)
- [ ] Create Check-Status.ps1.bat launcher
- [ ] Create Update-Components.ps1 (check for newer versions of bundled components)

### Script Fixes

- [ ] Fix INSTALL.bat old script references (Start-IsotoneStack.bat -> Start-Services.bat)
- [ ] Bundle Composer in composer/ directory (currently empty)
- [ ] Add Composer to PATH via Set-Environment.ps1

### Configuration

- [ ] Add Mailpit configuration template to config/ directory
- [ ] Add Apache SSL vhost template to config/apache/extra/
- [ ] Add default .user.ini template for PHP project overrides

---

## Web Control Panel (default/control/)

### Complete Stub Pages

- [ ] Implement backup.php (list backups, trigger backup, restore, download)
- [ ] Implement files.php (project listing, disk usage, open in explorer)
- [ ] Implement php.php (show active version, extensions, key settings, switch version trigger)
- [ ] Implement vhosts.php (list virtual hosts, add/edit/delete with form)

### Improvements

- [ ] Fix hardcoded C:\isotone paths in all control panel pages (use dynamic detection)
- [ ] Add dark theme to match iso-control aesthetic
- [ ] Add AJAX-based service start/stop (no page refresh)
- [ ] Add WebSocket or polling for live service status updates
- [ ] Add responsive mobile layout

---

## Production Readiness

### Security Hardening

- [ ] Generate random MariaDB root password during first install
- [ ] Restrict phpMyAdmin access to localhost only (already done via Apache?)
- [ ] Add HTTP basic auth option for web control panel
- [ ] Add Content-Security-Policy headers to default pages
- [ ] Disable Apache directory listing by default
- [ ] Disable PHP expose_php and display_errors in production mode

### Performance

- [ ] Enable OPcache in php.ini template by default
- [ ] Add Apache mod_deflate configuration for compression
- [ ] Add Apache mod_expires configuration for static asset caching
- [ ] Tune MariaDB my.ini defaults for development workloads (InnoDB buffer pool, query cache)

### Reliability

- [ ] Add service watchdog script (auto-restart crashed services)
- [ ] Add log rotation for Apache access/error logs
- [ ] Add log rotation for MariaDB error logs
- [ ] Add disk space monitoring with warnings

### Portability

- [ ] Test clean install on fresh Windows 10 VM
- [ ] Test clean install on fresh Windows 11 VM
- [ ] Test portable mode (run from USB/external drive)
- [ ] Test installation on non-C: drives (D:, E:, network drives)
- [ ] Verify all paths are relative (no hardcoded drive letters in configs)

---

## Distribution & Release

### Release Preparation

- [ ] Define version numbering scheme (semver)
- [ ] Create release checklist document
- [ ] Build and test installer end-to-end on clean VM
- [ ] Write upgrade migration guide (for existing users)
- [ ] Create uninstall verification test

### Marketing & Visibility

- [ ] Add project description and topics to GitHub repo settings
- [ ] Add social preview image for GitHub (1280x640)
- [ ] Create project website or GitHub Pages landing page
- [ ] Write announcement blog post or Reddit/HackerNews post
- [ ] Add to awesome-wamp or similar curated lists
- [ ] Add comparison table (IsotoneStack vs XAMPP vs Laragon vs WAMP)
