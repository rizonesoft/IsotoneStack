using System;
using System.Windows.Input;
using System.Windows.Media;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MaterialDesignThemes.Wpf;
using Isotone.Services;
using Isotone.Utilities;

namespace Isotone.ViewModels
{
    public partial class DashboardViewModel : ObservableObject
    {
        private readonly ServiceManager _serviceManager;
        private readonly ConfigurationManager _configManager;
        private readonly ISnackbarMessageQueue _snackbarMessageQueue;

        [ObservableProperty]
        private string apacheStatus = "Checking...";

        [ObservableProperty]
        private string mariaDBStatus = "Checking...";

        [ObservableProperty]
        private string mailpitStatus = "Checking...";

        [ObservableProperty]
        private Brush apacheStatusColor = Brushes.Gray;

        [ObservableProperty]
        private Brush mariaDBStatusColor = Brushes.Gray;

        [ObservableProperty]
        private Brush mailpitStatusColor = Brushes.Gray;

        [ObservableProperty]
        private bool canStartApache;

        [ObservableProperty]
        private bool canStopApache;

        [ObservableProperty]
        private bool canRestartApache;

        [ObservableProperty]
        private bool canStartMariaDB;

        [ObservableProperty]
        private bool canStopMariaDB;

        [ObservableProperty]
        private bool canRestartMariaDB;

        [ObservableProperty]
        private bool canStartMailpit;

        [ObservableProperty]
        private bool canStopMailpit;

        [ObservableProperty]
        private bool canRestartMailpit;

        [ObservableProperty]
        private string isotonePath;

        [ObservableProperty]
        private string phpVersion = "8.3.x";

        [ObservableProperty]
        private string apacheVersion = "2.4.x";

        [ObservableProperty]
        private string mariaDBVersion = "11.x";

        [ObservableProperty]
        private double cpuUsage;

        [ObservableProperty]
        private double ramUsage;

        [ObservableProperty]
        private double diskUsage;

        [ObservableProperty]
        private string systemInfo = "Initializing...";

        public DashboardViewModel(ServiceManager serviceManager, ConfigurationManager configManager, ISnackbarMessageQueue snackbarMessageQueue)
        {
            _serviceManager = serviceManager;
            _configManager = configManager;
            _snackbarMessageQueue = snackbarMessageQueue;

            IsotonePath = _configManager.Configuration.IsotonePath;

            _ = UpdateServiceStatusAsync();
            _ = UpdateSystemResourcesAsync();
        }

        private async System.Threading.Tasks.Task UpdateServiceStatusAsync()
        {
            while (true)
            {
                try
                {
                    var apacheService = _serviceManager.GetService("IsotoneApache");
                    var mariadbService = _serviceManager.GetService("IsotoneMariaDB");
                    var mailpitService = _serviceManager.GetService("IsotoneMailpit");

                    UpdateApacheStatus(apacheService);
                    UpdateMariaDBStatus(mariadbService);
                    UpdateMailpitStatus(mailpitService);
                }
                catch (Exception ex)
                {
                    _snackbarMessageQueue.Enqueue($"Error updating service status: {ex.Message}");
                }

                await System.Threading.Tasks.Task.Delay(2000);
            }
        }

        private void UpdateApacheStatus(ServiceInfo? service)
        {
            if (service == null)
            {
                ApacheStatus = "Not Installed";
                ApacheStatusColor = Brushes.Gray;
                CanStartApache = false;
                CanStopApache = false;
                CanRestartApache = false;
                return;
            }

            ApacheStatus = service.IsRunning ? "Running" : "Stopped";
            ApacheStatusColor = service.IsRunning ? Brushes.LightGreen : Brushes.OrangeRed;
            CanStartApache = !service.IsRunning;
            CanStopApache = service.IsRunning;
            CanRestartApache = service.IsRunning;
        }

        private void UpdateMariaDBStatus(ServiceInfo? service)
        {
            if (service == null)
            {
                MariaDBStatus = "Not Installed";
                MariaDBStatusColor = Brushes.Gray;
                CanStartMariaDB = false;
                CanStopMariaDB = false;
                CanRestartMariaDB = false;
                return;
            }

            MariaDBStatus = service.IsRunning ? "Running" : "Stopped";
            MariaDBStatusColor = service.IsRunning ? Brushes.LightGreen : Brushes.OrangeRed;
            CanStartMariaDB = !service.IsRunning;
            CanStopMariaDB = service.IsRunning;
            CanRestartMariaDB = service.IsRunning;
        }

        private void UpdateMailpitStatus(ServiceInfo? service)
        {
            if (service == null)
            {
                MailpitStatus = "Not Installed";
                MailpitStatusColor = Brushes.Gray;
                CanStartMailpit = false;
                CanStopMailpit = false;
                CanRestartMailpit = false;
                return;
            }

            MailpitStatus = service.IsRunning ? "Running" : "Stopped";
            MailpitStatusColor = service.IsRunning ? Brushes.LightGreen : Brushes.OrangeRed;
            CanStartMailpit = !service.IsRunning;
            CanStopMailpit = service.IsRunning;
            CanRestartMailpit = service.IsRunning;
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StartApache()
        {
            try
            {
                await _serviceManager.StartServiceAsync("IsotoneApache");
                _snackbarMessageQueue.Enqueue("Apache service started");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to start Apache: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StopApache()
        {
            try
            {
                await _serviceManager.StopServiceAsync("IsotoneApache");
                _snackbarMessageQueue.Enqueue("Apache service stopped");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to stop Apache: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RestartApache()
        {
            try
            {
                await _serviceManager.RestartServiceAsync("IsotoneApache");
                _snackbarMessageQueue.Enqueue("Apache service restarted");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to restart Apache: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StartMariaDB()
        {
            try
            {
                await _serviceManager.StartServiceAsync("IsotoneMariaDB");
                _snackbarMessageQueue.Enqueue("MariaDB service started");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to start MariaDB: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StopMariaDB()
        {
            try
            {
                await _serviceManager.StopServiceAsync("IsotoneMariaDB");
                _snackbarMessageQueue.Enqueue("MariaDB service stopped");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to stop MariaDB: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RestartMariaDB()
        {
            try
            {
                await _serviceManager.RestartServiceAsync("IsotoneMariaDB");
                _snackbarMessageQueue.Enqueue("MariaDB service restarted");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to restart MariaDB: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StartMailpit()
        {
            try
            {
                await _serviceManager.StartServiceAsync("IsotoneMailpit");
                _snackbarMessageQueue.Enqueue("Mailpit service started");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to start Mailpit: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StopMailpit()
        {
            try
            {
                await _serviceManager.StopServiceAsync("IsotoneMailpit");
                _snackbarMessageQueue.Enqueue("Mailpit service stopped");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to stop Mailpit: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RestartMailpit()
        {
            try
            {
                await _serviceManager.RestartServiceAsync("IsotoneMailpit");
                _snackbarMessageQueue.Enqueue("Mailpit service restarted");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to restart Mailpit: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StartAllServices()
        {
            try
            {
                await _serviceManager.StartAllServicesAsync();
                _snackbarMessageQueue.Enqueue("All services started");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to start all services: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StopAllServices()
        {
            try
            {
                await _serviceManager.StopAllServicesAsync();
                _snackbarMessageQueue.Enqueue("All services stopped");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to stop all services: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RestartAllServices()
        {
            try
            {
                await _serviceManager.RestartAllServicesAsync();
                _snackbarMessageQueue.Enqueue("All services restarted");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to restart all services: {ex.Message}");
            }
        }

        [RelayCommand]
        private void OpenProjectFolder()
        {
            try
            {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = _configManager.Configuration.IsotonePath,
                    UseShellExecute = true
                });
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to open project folder: {ex.Message}");
            }
        }

        [RelayCommand]
        private void OpenHostsFile()
        {
            try
            {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "notepad.exe",
                    Arguments = @"C:\Windows\System32\drivers\etc\hosts",
                    UseShellExecute = true,
                    Verb = "runas"
                });
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to open hosts file: {ex.Message}");
            }
        }

        [RelayCommand]
        private void RefreshServices()
        {
            _serviceManager.RefreshServices();
            _snackbarMessageQueue.Enqueue("Services refreshed");
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
                        
                        // Disk Usage for C: drive
                        var drive = new System.IO.DriveInfo("C");
                        var totalSize = drive.TotalSize;
                        var freeSpace = drive.TotalFreeSpace;
                        var usedSpace = totalSize - freeSpace;
                        DiskUsage = Math.Round((double)usedSpace / totalSize * 100, 1);
                        
                        var diskFreeGB = Math.Round(freeSpace / (1024.0 * 1024.0 * 1024.0), 1);
                        
                        SystemInfo = $"{freeMemoryGB:F1} GB / {totalMemoryGB:F1} GB RAM • {diskFreeGB:F1} GB Free";
                    }
                    catch
                    {
                        // Simplified fallback
                        var drive = new System.IO.DriveInfo("C");
                        DiskUsage = Math.Round((double)(drive.TotalSize - drive.TotalFreeSpace) / drive.TotalSize * 100, 1);
                        SystemInfo = $"C: {Math.Round(drive.TotalFreeSpace / (1024.0 * 1024.0 * 1024.0), 1):F1} GB Free";
                    }
                }
                catch
                {
                    SystemInfo = "Resource monitoring unavailable";
                }

                await System.Threading.Tasks.Task.Delay(3000); // Update every 3 seconds
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
    }
}