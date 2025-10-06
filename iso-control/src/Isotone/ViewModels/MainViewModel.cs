using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows.Input;
using System.Windows.Media;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MaterialDesignThemes.Wpf;
using Isotone.Services;
using Isotone.Utilities;
using Isotone.Views;

namespace Isotone.ViewModels
{
    public partial class MainViewModel : ObservableObject
    {
        private readonly ServiceManager _serviceManager;
        private readonly ConfigurationManager _configManager;
        private readonly ISnackbarMessageQueue _snackbarMessageQueue;
        private readonly ViewCache _viewCache;

        [ObservableProperty]
        private object? currentView;

        [ObservableProperty]
        private string statusText = "Checking services...";

        [ObservableProperty]
        private Brush statusColor = Brushes.Yellow;

        [ObservableProperty]
        private bool isMenuOpen;

        [ObservableProperty]
        private ObservableCollection<NavigationItemViewModel> navigationItems;

        [ObservableProperty]
        private double cpuUsage;

        [ObservableProperty]
        private double ramUsage;

        [ObservableProperty]
        private double diskUsage;

        [ObservableProperty]
        private string systemInfo = "Initializing...";

        [ObservableProperty]
        private string diskFreeSpace = "Calculating...";

        public ISnackbarMessageQueue SnackbarMessageQueue => _snackbarMessageQueue;

        public MainViewModel()
        {
            // Get the isotone path dynamically - try environment variable first, then auto-detect, then default
            string isotonePath = Environment.GetEnvironmentVariable("ISOTONE_PATH");
            
            if (string.IsNullOrEmpty(isotonePath))
            {
                // Auto-detect based on executable location
                // Executable is in: R:\isotone\iso-control\bin\Debug\net8.0-windows\
                // We need to go up to: R:\isotone\
                var exeDir = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
                if (!string.IsNullOrEmpty(exeDir))
                {
                    // Go up from bin\Debug\net8.0-windows to iso-control, then to isotone root
                    var binDir = System.IO.Directory.GetParent(exeDir)?.Parent?.Parent?.FullName; // bin folder
                    var isoControlDir = System.IO.Directory.GetParent(binDir ?? "")?.FullName; // iso-control folder
                    isotonePath = System.IO.Directory.GetParent(isoControlDir ?? "")?.FullName ?? @"C:\isotone"; // isotone root
                }
                else
                {
                    isotonePath = @"C:\isotone";
                }
            }
            
            _configManager = new ConfigurationManager(isotonePath);
            _serviceManager = new ServiceManager(_configManager.Configuration.IsotonePath);
            _snackbarMessageQueue = new SnackbarMessageQueue();
            _viewCache = new ViewCache();
            
            // Register view factories for lazy loading
            RegisterViewFactories();

            // Initialize navigation items
            NavigationItems = new ObservableCollection<NavigationItemViewModel>
            {
                new NavigationItemViewModel("Dashboard", "ViewDashboard", () => NavigateTo("Dashboard")),
                new NavigationItemViewModel("Services", "ServerNetwork", () => NavigateTo("Services")),
                new NavigationItemViewModel("Database", "Database", () => NavigateTo("Database")),
                new NavigationItemViewModel("Virtual Hosts", "Web", () => NavigateTo("VirtualHosts")),
                new NavigationItemViewModel("Ports", "LanConnect", () => NavigateTo("Ports")),
                new NavigationItemViewModel("Logs", "FileDocument", () => NavigateTo("Logs")),
                new NavigationItemViewModel("Scripts", "ScriptText", () => NavigateTo("Scripts")),
                new NavigationItemViewModel("Security", "Security", () => NavigateTo("Security")),
                new NavigationItemViewModel("Settings", "Settings", () => NavigateTo("Settings"))
            };

            // Select Dashboard by default
            NavigationItems[0].IsSelected = true;
            NavigateTo("Dashboard");

            // Start monitoring services and system resources
            _ = UpdateServiceStatusAsync();
            _ = UpdateSystemResourcesAsync();
        }

        private void RegisterViewFactories()
        {
            _viewCache.RegisterFactory("Dashboard", () => 
                new DashboardView { DataContext = new DashboardViewModel(_serviceManager, _configManager, _snackbarMessageQueue) });
            _viewCache.RegisterFactory("Services", () => 
                new ServicesView { DataContext = new ServicesViewModel(_serviceManager, _configManager, _snackbarMessageQueue) });
            _viewCache.RegisterFactory("Database", () => 
                new DatabaseView { DataContext = new DatabaseViewModel(_configManager) });
            _viewCache.RegisterFactory("Logs", () => 
                new LogsView { DataContext = new LogsViewModel(_configManager) });
            _viewCache.RegisterFactory("Settings", () => 
                new SettingsView { DataContext = new SettingsViewModel(_configManager) });
        }
        
        private void NavigateTo(string viewName)
        {
            // Use cached views for better performance
            CurrentView = _viewCache.GetOrCreate(viewName) ?? 
                         new ComingSoonView { DataContext = new ComingSoonViewModel(viewName) };

            // Update selection
            foreach (var item in NavigationItems)
            {
                item.IsSelected = item.Title == viewName;
            }
        }

        private async System.Threading.Tasks.Task UpdateServiceStatusAsync()
        {
            while (true)
            {
                try
                {
                    var services = _serviceManager.GetAllServices();
                    var runningCount = services.Count(s => s.IsRunning);
                    var totalCount = services.Count();

                    if (runningCount == totalCount)
                    {
                        StatusText = $"All {totalCount} services running";
                        StatusColor = Brushes.LightGreen;
                    }
                    else if (runningCount == 0)
                    {
                        StatusText = "All services stopped";
                        StatusColor = Brushes.OrangeRed;
                    }
                    else
                    {
                        StatusText = $"{runningCount}/{totalCount} services running";
                        StatusColor = Brushes.Orange;
                    }
                }
                catch
                {
                    StatusText = "Error checking services";
                    StatusColor = Brushes.Red;
                }

                await System.Threading.Tasks.Task.Delay(5000);
            }
        }


        [RelayCommand]
        private void OpenLocalhost()
        {
            try
            {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "http://localhost",
                    UseShellExecute = true
                });
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to open localhost: {ex.Message}");
            }
        }

        [RelayCommand]
        private void OpenPhpMyAdmin()
        {
            try
            {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "http://localhost/phpmyadmin",
                    UseShellExecute = true
                });
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to open phpMyAdmin: {ex.Message}");
            }
        }

        [RelayCommand]
        private void OpenMailpit()
        {
            try
            {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "http://localhost:8025",
                    UseShellExecute = true
                });
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to open Mailpit: {ex.Message}");
            }
        }

        private async System.Threading.Tasks.Task UpdateSystemResourcesAsync()
        {
            while (true)
            {
                try
                {
                    // CPU Usage
                    try
                    {
                        var cpuCounter = new System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total");
                        cpuCounter.NextValue();
                        await System.Threading.Tasks.Task.Delay(100);
                        CpuUsage = Math.Round(cpuCounter.NextValue(), 1);
                    }
                    catch
                    {
                        CpuUsage = 0;
                    }

                    // RAM Usage
                    try
                    {
                        var availableMemoryCounter = new System.Diagnostics.PerformanceCounter("Memory", "Available MBytes");
                        var availableMemoryMB = availableMemoryCounter.NextValue();
                        
                        var totalPhysicalMemory = GetTotalPhysicalMemory();
                        var totalMemoryMB = totalPhysicalMemory / (1024.0 * 1024.0);
                        var usedMemoryMB = totalMemoryMB - availableMemoryMB;
                        
                        RamUsage = Math.Round((usedMemoryMB / totalMemoryMB) * 100, 1);
                        
                        var totalMemoryGB = Math.Round(totalMemoryMB / 1024.0, 1);
                        var freeMemoryGB = Math.Round(availableMemoryMB / 1024.0, 1);
                        var usedMemoryGB = Math.Round((totalMemoryMB - availableMemoryMB) / 1024.0, 1);
                        
                        // Disk Usage for C: drive
                        var drive = new System.IO.DriveInfo("C");
                        var totalSize = drive.TotalSize;
                        var freeSpace = drive.TotalFreeSpace;
                        var usedSpace = totalSize - freeSpace;
                        DiskUsage = Math.Round((double)usedSpace / totalSize * 100, 1);
                        
                        var diskFreeGB = Math.Round(freeSpace / (1024.0 * 1024.0 * 1024.0), 1);
                        var diskTotalGB = Math.Round(totalSize / (1024.0 * 1024.0 * 1024.0), 1);
                        var diskUsedGB = Math.Round(usedSpace / (1024.0 * 1024.0 * 1024.0), 1);
                        
                        SystemInfo = $"{usedMemoryGB:F1} GB / {totalMemoryGB:F1} GB Used";
                        DiskFreeSpace = $"{diskUsedGB:F1} GB / {diskTotalGB:F1} GB Used ({diskFreeGB:F1} GB Free)";
                    }
                    catch
                    {
                        // Simplified fallback
                        var drive = new System.IO.DriveInfo("C");
                        DiskUsage = Math.Round((double)(drive.TotalSize - drive.TotalFreeSpace) / drive.TotalSize * 100, 1);
                        var diskFreeGB = Math.Round(drive.TotalFreeSpace / (1024.0 * 1024.0 * 1024.0), 1);
                        var diskTotalGB = Math.Round(drive.TotalSize / (1024.0 * 1024.0 * 1024.0), 1);
                        SystemInfo = "Memory information unavailable";
                        DiskFreeSpace = $"{diskTotalGB - diskFreeGB:F1} GB / {diskTotalGB:F1} GB Used ({diskFreeGB:F1} GB Free)";
                    }
                }
                catch
                {
                    SystemInfo = "Resource monitoring unavailable";
                    DiskFreeSpace = "Disk information unavailable";
                }

                await System.Threading.Tasks.Task.Delay(2000); // Update every 2 seconds
            }
        }

        private static long GetTotalPhysicalMemory()
        {
            try
            {
                var computerInfo = new System.Diagnostics.PerformanceCounter("Memory", "Total Visible Memory Size");
                var totalKB = computerInfo.NextValue();
                if (totalKB > 0)
                    return (long)(totalKB * 1024);
            }
            catch { }
            
            return 16L * 1024 * 1024 * 1024; // Default to 16GB if we can't determine
        }

        [RelayCommand]
        private void OpenSettings()
        {
            NavigateTo("Settings");
        }
    }

    public partial class NavigationItemViewModel : ObservableObject
    {
        [ObservableProperty]
        private string title;

        [ObservableProperty]
        private string icon;

        [ObservableProperty]
        private bool isSelected;

        private readonly Action _navigateAction;

        public ICommand NavigateCommand { get; }

        public NavigationItemViewModel(string title, string icon, Action navigateAction)
        {
            Title = title;
            Icon = icon;
            _navigateAction = navigateAction;
            NavigateCommand = new RelayCommand(_navigateAction);
        }
    }

    public class ComingSoonViewModel
    {
        public string Feature { get; }

        public ComingSoonViewModel(string feature)
        {
            Feature = feature;
        }
    }
}