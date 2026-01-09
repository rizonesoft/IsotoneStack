# 🖥️ iso-control Production Readiness Plan

> **Status:** Pending  
> **Created:** January 2026  
> **Target:** iso-control WPF Control Panel Application  
> **Framework:** .NET 9, WPF, MaterialDesignInXAML, CommunityToolkit.Mvvm  
> **Legend:** 🔥 = Critical | ⚠️ = Important | 💡 = Enhancement | 🧪 = Testing

---

## 📋 Overview

This document outlines the improvements required to make **iso-control** (the IsotoneStack GUI Control Panel) production-ready.

### Current Analysis Summary

| Component | Status | Notes |
|-----------|--------|-------|
| **Dashboard** | ✅ Functional | Service management, system resources |
| **PHP Management** | ✅ Functional | Version switching, extension management |
| **Services** | ⚠️ Partial | Start/stop works, configuration not implemented |
| **Database** | ❌ Stub Only | Only has empty ViewModel (15 lines) |
| **Logs** | ❌ Placeholder | UI exists but content loading not implemented |
| **Settings** | ⚠️ Partial | Basic settings work, needs more options |

### Key Issues Identified

1. **Empty/Placeholder Views:** Database and Logs views are non-functional
2. **No MariaDB version switching UI** (needed for multi-version support)
3. **Service configuration dialogs** show "coming soon" messages
4. **No Virtual Hosts management** interface
5. **No backup/restore functionality** in UI
6. **System tray integration** not implemented
7. **Update checking** not implemented

---

## 🔥 Phase 1: Complete Stub Views (Critical)
*Goal: Make Database and Logs views fully functional.*

---

### 1.1 Implement DatabaseViewModel
- [ ] **1.1.1** 🔥 Expand `DatabaseViewModel.cs` with full functionality
    
    **Current state (only 15 lines):**
    ```csharp
    public partial class DatabaseViewModel : ObservableObject
    {
        private readonly ConfigurationManager _configManager;
        public DatabaseViewModel(ConfigurationManager configManager)
        {
            _configManager = configManager;
        }
    }
    ```
    
    **Required features:**
    - [ ] List all databases from MariaDB
    - [ ] Show database sizes and table counts
    - [ ] Create/Drop database functionality
    - [ ] Import/Export SQL files
    - [ ] Run SQL queries

- [ ] **1.1.2** Add required services to DatabaseViewModel
    ```csharp
    private readonly ServiceManager _serviceManager;
    private readonly ISnackbarMessageQueue _snackbarMessageQueue;
    
    [ObservableProperty]
    private ObservableCollection<DatabaseInfo> databases;
    
    [ObservableProperty]
    private bool isMariaDBRunning;
    
    [ObservableProperty]
    private string mariaDBVersion;
    
    [ObservableProperty]
    private string selectedMariaDBVersion; // For multi-version support
    
    public ObservableCollection<string> AvailableMariaDBVersions { get; }
    ```

- [ ] **1.1.3** Implement database listing using MariaDB CLI
    ```csharp
    private async Task LoadDatabasesAsync()
    {
        var mysqlPath = Path.Combine(_configManager.Configuration.IsotonePath, 
            "mariadb", SelectedMariaDBVersion, "bin", "mysql.exe");
        
        // Execute: mysql -u root -e "SHOW DATABASES"
        // Parse output into DatabaseInfo objects
    }
    ```

---

### 1.2 Implement DatabaseView.xaml UI
- [ ] **1.2.1** Design database management interface
    
    **Required UI elements:**
    - [ ] MariaDB version selector dropdown (multi-version)
    - [ ] Database list with DataGrid
    - [ ] Database details panel (tables, size, collation)
    - [ ] Action buttons: Create, Drop, Export, Import
    - [ ] Quick access: phpMyAdmin, Adminer
    - [ ] Connection string display
    - [ ] MariaDB status indicator

- [ ] **1.2.2** Add database creation dialog
    ```xml
    <materialDesign:DialogHost>
        <!-- Create Database Dialog -->
        <StackPanel>
            <TextBox Header="Database Name" />
            <ComboBox Header="Character Set" />
            <ComboBox Header="Collation" />
        </StackPanel>
    </materialDesign:DialogHost>
    ```

- [ ] **1.2.3** Add import/export functionality
    - [ ] File picker for SQL files
    - [ ] Progress indicator for operations
    - [ ] Output log display

---

### 1.3 Implement LogsViewModel
- [ ] **1.3.1** 🔥 Replace placeholder log loading with real implementation
    
    **Current state (placeholder):**
    ```csharp
    private void LoadLogContent(string logFile)
    {
        // Placeholder for loading actual log content
        LogContent = $"Contents of {logFile} will be displayed here...";
    }
    ```
    
    **Required implementation:**
    ```csharp
    private async Task LoadLogContentAsync(string logFile)
    {
        var logPath = GetLogFilePath(logFile);
        if (File.Exists(logPath))
        {
            // Read last N lines for performance
            var lines = await ReadLastLinesAsync(logPath, 500);
            LogContent = string.Join(Environment.NewLine, lines);
        }
        else
        {
            LogContent = $"Log file not found: {logPath}";
        }
    }
    
    private string GetLogFilePath(string logFile)
    {
        return logFile switch
        {
            "Apache Error Log" => Path.Combine(_isotonePath, "apache24", "logs", "error.log"),
            "Apache Access Log" => Path.Combine(_isotonePath, "apache24", "logs", "access.log"),
            "MariaDB Error Log" => Path.Combine(_isotonePath, "mariadb", "data", "*.err"),
            "PHP Error Log" => Path.Combine(_isotonePath, "logs", "php", "php_errors.log"),
            "IsotoneStack Log" => Path.Combine(_isotonePath, "logs", "isotone", "isotone.log"),
            _ => string.Empty
        };
    }
    ```

- [ ] **1.3.2** Add log tailing (live updates)
    ```csharp
    private FileSystemWatcher? _logWatcher;
    
    [ObservableProperty]
    private bool isLiveTailEnabled;
    
    partial void OnIsLiveTailEnabledChanged(bool value)
    {
        if (value)
            StartLogWatcher();
        else
            StopLogWatcher();
    }
    ```

- [ ] **1.3.3** Add log filtering and search
    ```csharp
    [ObservableProperty]
    private string searchQuery;
    
    [ObservableProperty]
    private string filterLevel; // Error, Warning, Info, Debug
    ```

---

### 1.4 Implement LogsView.xaml UI
- [ ] **1.4.1** Design log viewer interface
    - [ ] Log file selector (ListBox/ComboBox)
    - [ ] Log content viewer (RichTextBox with syntax highlighting)
    - [ ] Live tail toggle button
    - [ ] Search bar with regex support
    - [ ] Filter by level dropdown
    - [ ] Clear log button
    - [ ] Open in external editor button
    - [ ] Auto-scroll toggle

---

## ⚠️ Phase 2: MariaDB Multi-Version Support (Important)
*Goal: Add UI for switching between MariaDB versions (syncs with TODO-MDB1011).*

---

### 2.1 Add MariaDB Version Selector
- [ ] **2.1.1** Detect installed MariaDB versions
    ```csharp
    // Utilities/MariaDBManager.cs
    public class MariaDBManager
    {
        public List<string> GetInstalledVersions(string isotonePath)
        {
            var mariadbPath = Path.Combine(isotonePath, "mariadb");
            return Directory.GetDirectories(mariadbPath)
                .Where(d => File.Exists(Path.Combine(d, "bin", "mariadbd.exe")))
                .Select(d => Path.GetFileName(d))
                .Where(v => Version.TryParse(v, out _))
                .OrderByDescending(v => Version.Parse(v))
                .ToList();
        }
    }
    ```

- [ ] **2.1.2** Add version switching to DashboardView
    - [ ] ComboBox for MariaDB version selection
    - [ ] Warning about data directory isolation
    - [ ] Service restart prompt

- [ ] **2.1.3** Implement version switching command
    ```csharp
    [RelayCommand]
    private async Task SwitchMariaDBVersionAsync(string version)
    {
        // 1. Stop MariaDB service
        // 2. Update service configuration
        // 3. Start MariaDB with new version
        // 4. Update UI
    }
    ```

---

### 2.2 Update Dashboard Cards
- [ ] **2.2.1** Show current MariaDB version on service card
- [ ] **2.2.2** Add version dropdown to MariaDB section (like PHP)
- [ ] **2.2.3** Show data directory size per version

---

## ⚠️ Phase 3: Service Configuration Dialogs (Important)
*Goal: Replace "coming soon" messages with actual configuration dialogs.*

---

### 3.1 Apache Configuration Dialog
- [ ] **3.1.1** Create ApacheConfigDialog (Window or DialogHost)
    ```csharp
    public partial class ApacheConfigWindow : Window
    {
        [ObservableProperty]
        private string httpPort = "80";
        
        [ObservableProperty]
        private string httpsPort = "443";
        
        [ObservableProperty]
        private string documentRoot;
        
        [ObservableProperty]
        private ObservableCollection<string> loadedModules;
    }
    ```

- [ ] **3.1.2** UI elements for Apache configuration
    - [ ] Port configuration (HTTP, HTTPS)
    - [ ] Document root selector
    - [ ] SSL certificate configuration
    - [ ] Module enable/disable
    - [ ] Virtual hosts list button
    - [ ] Open httpd.conf button

---

### 3.2 MariaDB Configuration Dialog
- [ ] **3.2.1** Create MariaDBConfigWindow
    ```csharp
    [ObservableProperty]
    private string port = "3306";
    
    [ObservableProperty]
    private string rootPassword;
    
    [ObservableProperty]
    private string innoDbBufferSize;
    
    [ObservableProperty]
    private string maxConnections;
    
    [ObservableProperty]
    private string characterSet;
    
    [ObservableProperty]
    private string collation;
    ```

- [ ] **3.2.2** UI elements for MariaDB configuration
    - [ ] Port configuration
    - [ ] Root password management
    - [ ] Memory settings (buffer pool size)
    - [ ] Connection limits
    - [ ] Character set / collation defaults
    - [ ] Open my.ini button

---

### 3.3 Mailpit Configuration Dialog
- [ ] **3.3.1** Create MailpitConfigWindow
    - [ ] SMTP port (default 1025)
    - [ ] Web UI port (default 8025)
    - [ ] Authentication settings
    - [ ] Storage settings

---

## 💡 Phase 4: Virtual Hosts Management (Enhancement)
*Goal: Add UI for managing Apache virtual hosts.*

---

### 4.1 Virtual Hosts View
- [ ] **4.1.1** Create VirtualHostsView.xaml
    - [ ] List of configured virtual hosts
    - [ ] Add/Edit/Delete buttons
    - [ ] Enable/Disable toggle
    - [ ] SSL indicator

- [ ] **4.1.2** Create VirtualHostsViewModel
    ```csharp
    public partial class VirtualHostsViewModel : ObservableObject
    {
        [ObservableProperty]
        private ObservableCollection<VirtualHost> virtualHosts;
        
        [RelayCommand]
        private async Task AddVirtualHostAsync();
        
        [RelayCommand]
        private async Task EditVirtualHostAsync(VirtualHost host);
        
        [RelayCommand]
        private async Task DeleteVirtualHostAsync(VirtualHost host);
        
        [RelayCommand]
        private async Task ToggleVirtualHostAsync(VirtualHost host);
    }
    
    public class VirtualHost
    {
        public string ServerName { get; set; }
        public string DocumentRoot { get; set; }
        public int Port { get; set; }
        public bool SslEnabled { get; set; }
        public bool IsEnabled { get; set; }
    }
    ```

- [ ] **4.1.3** Implement hosts file management
    - [ ] Add entries to Windows hosts file
    - [ ] Remove entries on virtual host deletion
    - [ ] Show warning if running without admin privileges

---

### 4.2 Virtual Host Dialog
- [ ] **4.2.1** Create AddVirtualHostDialog
    - [ ] Server name input
    - [ ] Document root folder picker
    - [ ] Port configuration
    - [ ] SSL certificate selection
    - [ ] PHP version override
    - [ ] Generate from template option

---

## 💡 Phase 5: System Tray Integration (Enhancement)
*Goal: Add minimize to tray and quick actions from tray.*

---

### 5.1 System Tray Implementation
- [ ] **5.1.1** Add NotifyIcon to App.xaml.cs
    ```csharp
    private System.Windows.Forms.NotifyIcon? _trayIcon;
    
    private void InitializeTrayIcon()
    {
        _trayIcon = new System.Windows.Forms.NotifyIcon
        {
            Icon = new System.Drawing.Icon("assets/isotone.ico"),
            Text = "IsotoneStack",
            Visible = true
        };
        
        _trayIcon.DoubleClick += (s, e) => ShowMainWindow();
        _trayIcon.ContextMenuStrip = CreateTrayContextMenu();
    }
    ```

- [ ] **5.1.2** Create tray context menu
    ```csharp
    private ContextMenuStrip CreateTrayContextMenu()
    {
        var menu = new ContextMenuStrip();
        menu.Items.Add("Show Control Panel", null, (s, e) => ShowMainWindow());
        menu.Items.Add("-");
        menu.Items.Add("Start All Services", null, async (s, e) => await StartAllServices());
        menu.Items.Add("Stop All Services", null, async (s, e) => await StopAllServices());
        menu.Items.Add("-");
        menu.Items.Add("Open localhost", null, (s, e) => OpenLocalhost());
        menu.Items.Add("Open phpMyAdmin", null, (s, e) => OpenPhpMyAdmin());
        menu.Items.Add("-");
        menu.Items.Add("Exit", null, (s, e) => ExitApplication());
        return menu;
    }
    ```

- [ ] **5.1.3** Implement minimize to tray behavior
    ```csharp
    protected override void OnStateChanged(EventArgs e)
    {
        if (WindowState == WindowState.Minimized && _configManager.Configuration.MinimizeToTray)
        {
            Hide();
            _trayIcon.ShowBalloonTip(1000, "IsotoneStack", "Running in background", ToolTipIcon.Info);
        }
        base.OnStateChanged(e);
    }
    ```

---

### 5.2 Service Status Indicators
- [ ] **5.2.1** Show service status in tray icon
    - [ ] Green icon = all services running
    - [ ] Yellow icon = some services running
    - [ ] Red icon = no services running

- [ ] **5.2.2** Add balloon notifications
    - [ ] Service started/stopped notifications
    - [ ] Error notifications

---

## 💡 Phase 6: Backup & Restore UI (Enhancement)
*Goal: Add backup and restore functionality through the UI.*

---

### 6.1 Backup View
- [ ] **6.1.1** Create BackupView.xaml
    - [ ] Backup type selection (Full, Database only, Configuration only)
    - [ ] Select databases to backup
    - [ ] Destination folder picker
    - [ ] Backup schedule settings
    - [ ] Backup history list

- [ ] **6.1.2** Create BackupViewModel
    ```csharp
    public partial class BackupViewModel : ObservableObject
    {
        [RelayCommand]
        private async Task CreateBackupAsync();
        
        [RelayCommand]
        private async Task RestoreBackupAsync(BackupInfo backup);
        
        [RelayCommand]
        private async Task DeleteBackupAsync(BackupInfo backup);
        
        [RelayCommand]
        private void ConfigureSchedule();
    }
    ```

---

### 6.2 Quick Backup from Dashboard
- [ ] **6.2.1** Add "Backup Now" button to Dashboard quick actions
- [ ] **6.2.2** Implement one-click backup functionality

---

## 💡 Phase 7: UI/UX Improvements (Enhancement)
*Goal: Polish the user interface for a professional look.*

---

### 7.1 Navigation Improvements
- [ ] **7.1.1** Add keyboard shortcuts
    ```csharp
    // F1 = Dashboard, F2 = PHP, F3 = Database, F4 = Services, F5 = Refresh
    InputBindings.Add(new KeyBinding(NavigateToDashboardCommand, Key.F1, ModifierKeys.None));
    InputBindings.Add(new KeyBinding(RefreshCommand, Key.F5, ModifierKeys.None));
    ```

- [ ] **7.1.2** Add breadcrumb navigation
- [ ] **7.1.3** Remember last active view on restart

---

### 7.2 Dashboard Enhancements
- [ ] **7.2.1** Add quick statistics cards
    - [ ] Total databases count
    - [ ] Active virtual hosts count
    - [ ] PHP extensions enabled count
    - [ ] Disk space used by IsotoneStack

- [ ] **7.2.2** Add service uptime display
- [ ] **7.2.3** Add quick action bar (most used actions)

---

### 7.3 Theme Improvements
- [ ] **7.3.1** Add theme selection (Light/Dark/System)
- [ ] **7.3.2** Add accent color customization
- [ ] **7.3.3** Improve responsive layout for different window sizes

---

### 7.4 Status Bar
- [ ] **7.4.1** Add status bar at bottom of window
    - [ ] Current PHP version
    - [ ] Current MariaDB version
    - [ ] Service status indicators
    - [ ] Last refresh timestamp

---

## 💡 Phase 8: Settings Improvements (Enhancement)
*Goal: Expand settings with more configuration options.*

---

### 8.1 Expand Settings Categories
- [ ] **8.1.1** General Settings
    - [ ] Start with Windows
    - [ ] Minimize to tray
    - [ ] Check for updates
    - [ ] Language selection

- [ ] **8.1.2** Appearance Settings
    - [ ] Theme (Light/Dark/System)
    - [ ] Accent color
    - [ ] Font size

- [ ] **8.1.3** Advanced Settings
    - [ ] Debug mode
    - [ ] Log verbosity level
    - [ ] Custom Isotone path
    - [ ] Custom configuration paths

- [ ] **8.1.4** About Section
    - [ ] Version information
    - [ ] Check for updates button
    - [ ] GitHub link
    - [ ] Credits/License

---

### 8.2 Settings Persistence
- [ ] **8.2.1** Move settings to JSON file (already exists: config.json)
- [ ] **8.2.2** Add settings validation
- [ ] **8.2.3** Add import/export settings

---

## 🧪 Phase 9: Testing & Quality (Testing)
*Goal: Ensure reliability and catch edge cases.*

---

### 9.1 Error Handling Improvements
- [ ] **9.1.1** Add proper exception handling to all async operations
- [ ] **9.1.2** Add retry logic for service operations
- [ ] **9.1.3** Improve error messages with actionable suggestions

---

### 9.2 Performance Optimization
- [ ] **9.2.1** Reduce service polling frequency when minimized
- [ ] **9.2.2** Lazy load views that aren't immediately visible
- [ ] **9.2.3** Optimize log file reading (don't load entire file)

---

### 9.3 Unit Tests
- [ ] **9.3.1** Add unit test project (Isotone.Tests)
- [ ] **9.3.2** Test ServiceManager operations
- [ ] **9.3.3** Test ConfigurationManager operations
- [ ] **9.3.4** Test PHPManager operations

---

## 🔄 Progress Tracking

| Phase | Status | Priority | Notes |
|-------|--------|----------|-------|
| Phase 1: Complete Stub Views | ⏳ Not Started | 🔥 Critical | Database & Logs are empty |
| Phase 2: MariaDB Multi-Version | ⏳ Not Started | ⚠️ Important | Syncs with TODO-MDB1011 |
| Phase 3: Service Config Dialogs | ⏳ Not Started | ⚠️ Important | Replace "coming soon" |
| Phase 4: Virtual Hosts | ⏳ Not Started | 💡 Enhancement | New feature |
| Phase 5: System Tray | ⏳ Not Started | 💡 Enhancement | MinimizeToTray setting exists |
| Phase 6: Backup & Restore | ⏳ Not Started | 💡 Enhancement | New feature |
| Phase 7: UI/UX Improvements | ⏳ Not Started | 💡 Enhancement | Polish |
| Phase 8: Settings Improvements | ⏳ Not Started | 💡 Enhancement | Expand options |
| Phase 9: Testing & Quality | ⏳ Not Started | 🧪 Testing | Reliability |

---

## 📋 Quick Reference: Current Architecture

### ViewModels
| File | Lines | Status |
|------|-------|--------|
| `DashboardViewModel.cs` | 1036 | ✅ Full implementation |
| `PhpViewModel.cs` | 338 | ✅ Full implementation |
| `ServicesViewModel.cs` | 215 | ⚠️ Config not implemented |
| `SettingsViewModel.cs` | 128 | ⚠️ Basic implementation |
| `LogsViewModel.cs` | 67 | ❌ Placeholder only |
| `MainViewModel.cs` | 363 | ✅ Navigation works |
| `DatabaseViewModel.cs` | 15 | ❌ Empty stub |

### Services
| File | Lines | Status |
|------|-------|--------|
| `ServiceManager.cs` | 157 | ✅ Start/Stop/Restart works |
| `ViewCache.cs` | ~50 | ✅ View caching works |

### Utilities
| File | Lines | Status |
|------|-------|--------|
| `ConfigurationManager.cs` | ~100 | ✅ Basic config works |
| `PHPManager.cs` | ~300 | ✅ Full implementation |
| `ErrorHandler.cs` | ~170 | ✅ Error handling works |

---

## 🔗 Dependencies

| Task | Depends On |
|------|------------|
| Phase 2 (MariaDB Multi-Version) | TODO-MDB1011.md completion |
| Phase 3 (Service Config) | Phase 1 (Service dialogs may need DB view) |
| Phase 5 (System Tray) | Phase 8 (MinimizeToTray setting) |

---

> **Last Updated:** 2026-01-09  
> **Author:** IsotoneStack Team
