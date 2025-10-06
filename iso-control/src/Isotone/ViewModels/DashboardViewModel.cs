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
        private TimeSpan apacheUptime;

        [ObservableProperty]
        private TimeSpan mariaDBUptime;

        [ObservableProperty]
        private TimeSpan mailpitUptime;

        [ObservableProperty]
        private DateTime? apacheStartTime;

        [ObservableProperty]
        private DateTime? mariaDBStartTime;

        [ObservableProperty]
        private DateTime? mailpitStartTime;

        [ObservableProperty]
        private bool isApacheLoading;

        [ObservableProperty]
        private bool isMariaDBLoading;

        [ObservableProperty]
        private bool isMailpitLoading;

        [ObservableProperty]
        private Brush apacheStatusColor = Brushes.Gray;

        [ObservableProperty]
        private Brush mariaDBStatusColor = Brushes.Gray;

        [ObservableProperty]
        private Brush mailpitStatusColor = Brushes.Gray;

        [ObservableProperty]
        private Brush apacheStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));

        [ObservableProperty]
        private Brush mariaDBStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));

        [ObservableProperty]
        private Brush mailpitStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));

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
        private bool isApacheInstalled;

        [ObservableProperty]
        private bool isMariaDBInstalled;

        [ObservableProperty]
        private bool isMailpitInstalled;

        [ObservableProperty]
        private string isotonePath;

        [ObservableProperty]
        private string phpVersion = "Checking...";

        [ObservableProperty]
        private string apacheVersion = "Checking...";

        [ObservableProperty]
        private string mariaDBVersion = "Checking...";

        [ObservableProperty]
        private string mailpitVersion = "Checking...";

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
            _ = GetServiceVersionsAsync();
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
                ApacheStatus = "Not Available";
                ApacheStatusColor = Brushes.Gray;
                ApacheStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));
                CanStartApache = false;
                CanStopApache = false;
                CanRestartApache = false;
                ApacheUptime = TimeSpan.Zero;
                IsApacheInstalled = false;
                return;
            }

            IsApacheInstalled = service.IsInstalled;
            System.Diagnostics.Debug.WriteLine($"Apache IsInstalled: {IsApacheInstalled}");

            if (!service.IsInstalled)
            {
                ApacheStatus = "Not Installed";
                ApacheStatusColor = Brushes.Gray;
                ApacheStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));
                CanStartApache = false;
                CanStopApache = false;
                CanRestartApache = false;
                ApacheUptime = TimeSpan.Zero;
                return;
            }

            if (!IsApacheLoading)
            {
                ApacheStatus = service.IsRunning ? "Running" : "Stopped";
                
                if (service.IsRunning)
                {
                    ApacheStatusColor = new SolidColorBrush(Color.FromRgb(76, 175, 80));
                    ApacheStatusBackground = new SolidColorBrush(Color.FromArgb(20, 76, 175, 80));
                    
                    if (ApacheStartTime == null)
                        ApacheStartTime = DateTime.Now;
                    
                    ApacheUptime = DateTime.Now - ApacheStartTime.Value;
                }
                else
                {
                    ApacheStatusColor = new SolidColorBrush(Color.FromRgb(158, 158, 158));
                    ApacheStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));
                    ApacheStartTime = null;
                    ApacheUptime = TimeSpan.Zero;
                }
            }
            
            CanStartApache = !service.IsRunning && !IsApacheLoading;
            CanStopApache = service.IsRunning && !IsApacheLoading;
            CanRestartApache = service.IsRunning && !IsApacheLoading;
        }

        private void UpdateMariaDBStatus(ServiceInfo? service)
        {
            if (service == null)
            {
                MariaDBStatus = "Not Available";
                MariaDBStatusColor = Brushes.Gray;
                MariaDBStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));
                CanStartMariaDB = false;
                CanStopMariaDB = false;
                CanRestartMariaDB = false;
                MariaDBUptime = TimeSpan.Zero;
                IsMariaDBInstalled = false;
                return;
            }

            IsMariaDBInstalled = service.IsInstalled;
            System.Diagnostics.Debug.WriteLine($"MariaDB IsInstalled: {IsMariaDBInstalled}");

            if (!service.IsInstalled)
            {
                MariaDBStatus = "Not Installed";
                MariaDBStatusColor = Brushes.Gray;
                MariaDBStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));
                CanStartMariaDB = false;
                CanStopMariaDB = false;
                CanRestartMariaDB = false;
                MariaDBUptime = TimeSpan.Zero;
                return;
            }

            if (!IsMariaDBLoading)
            {
                MariaDBStatus = service.IsRunning ? "Running" : "Stopped";
                
                if (service.IsRunning)
                {
                    MariaDBStatusColor = new SolidColorBrush(Color.FromRgb(76, 175, 80));
                    MariaDBStatusBackground = new SolidColorBrush(Color.FromArgb(20, 76, 175, 80));
                    
                    if (MariaDBStartTime == null)
                        MariaDBStartTime = DateTime.Now;
                    
                    MariaDBUptime = DateTime.Now - MariaDBStartTime.Value;
                }
                else
                {
                    MariaDBStatusColor = new SolidColorBrush(Color.FromRgb(158, 158, 158));
                    MariaDBStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));
                    MariaDBStartTime = null;
                    MariaDBUptime = TimeSpan.Zero;
                }
            }
            
            CanStartMariaDB = !service.IsRunning && !IsMariaDBLoading;
            CanStopMariaDB = service.IsRunning && !IsMariaDBLoading;
            CanRestartMariaDB = service.IsRunning && !IsMariaDBLoading;
        }

        private void UpdateMailpitStatus(ServiceInfo? service)
        {
            if (service == null)
            {
                MailpitStatus = "Not Available";
                MailpitStatusColor = Brushes.Gray;
                MailpitStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));
                CanStartMailpit = false;
                CanStopMailpit = false;
                CanRestartMailpit = false;
                MailpitUptime = TimeSpan.Zero;
                IsMailpitInstalled = false;
                return;
            }

            IsMailpitInstalled = service.IsInstalled;
            System.Diagnostics.Debug.WriteLine($"Mailpit IsInstalled: {IsMailpitInstalled}");

            if (!service.IsInstalled)
            {
                MailpitStatus = "Not Installed";
                MailpitStatusColor = Brushes.Gray;
                MailpitStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));
                CanStartMailpit = false;
                CanStopMailpit = false;
                CanRestartMailpit = false;
                MailpitUptime = TimeSpan.Zero;
                return;
            }

            if (!IsMailpitLoading)
            {
                MailpitStatus = service.IsRunning ? "Running" : "Stopped";
                
                if (service.IsRunning)
                {
                    MailpitStatusColor = new SolidColorBrush(Color.FromRgb(76, 175, 80));
                    MailpitStatusBackground = new SolidColorBrush(Color.FromArgb(20, 76, 175, 80));
                    
                    if (MailpitStartTime == null)
                        MailpitStartTime = DateTime.Now;
                    
                    MailpitUptime = DateTime.Now - MailpitStartTime.Value;
                }
                else
                {
                    MailpitStatusColor = new SolidColorBrush(Color.FromRgb(158, 158, 158));
                    MailpitStatusBackground = new SolidColorBrush(Color.FromArgb(20, 158, 158, 158));
                    MailpitStartTime = null;
                    MailpitUptime = TimeSpan.Zero;
                }
            }
            
            CanStartMailpit = !service.IsRunning && !IsMailpitLoading;
            CanStopMailpit = service.IsRunning && !IsMailpitLoading;
            CanRestartMailpit = service.IsRunning && !IsMailpitLoading;
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StartApache()
        {
            try
            {
                IsApacheLoading = true;
                ApacheStatus = "Starting";
                ApacheStatusColor = new SolidColorBrush(Color.FromRgb(255, 193, 7));
                
                await _serviceManager.StartServiceAsync("IsotoneApache");
                _snackbarMessageQueue.Enqueue("Apache service started");
            }
            catch (Exception ex)
            {
                ApacheStatus = "Error";
                ApacheStatusColor = new SolidColorBrush(Color.FromRgb(244, 67, 54));
                _snackbarMessageQueue.Enqueue($"Failed to start Apache: {ex.Message}");
            }
            finally
            {
                IsApacheLoading = false;
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StopApache()
        {
            try
            {
                IsApacheLoading = true;
                ApacheStatus = "Stopping";
                ApacheStatusColor = new SolidColorBrush(Color.FromRgb(255, 152, 0));
                
                await _serviceManager.StopServiceAsync("IsotoneApache");
                _snackbarMessageQueue.Enqueue("Apache service stopped");
            }
            catch (Exception ex)
            {
                ApacheStatus = "Error";
                ApacheStatusColor = new SolidColorBrush(Color.FromRgb(244, 67, 54));
                _snackbarMessageQueue.Enqueue($"Failed to stop Apache: {ex.Message}");
            }
            finally
            {
                IsApacheLoading = false;
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RestartApache()
        {
            try
            {
                IsApacheLoading = true;
                ApacheStatus = "Restarting";
                ApacheStatusColor = new SolidColorBrush(Color.FromRgb(3, 169, 244));
                
                await _serviceManager.RestartServiceAsync("IsotoneApache");
                ApacheStartTime = DateTime.Now;
                _snackbarMessageQueue.Enqueue("Apache service restarted");
            }
            catch (Exception ex)
            {
                ApacheStatus = "Error";
                ApacheStatusColor = new SolidColorBrush(Color.FromRgb(244, 67, 54));
                _snackbarMessageQueue.Enqueue($"Failed to restart Apache: {ex.Message}");
            }
            finally
            {
                IsApacheLoading = false;
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StartMariaDB()
        {
            try
            {
                IsMariaDBLoading = true;
                MariaDBStatus = "Starting";
                MariaDBStatusColor = new SolidColorBrush(Color.FromRgb(255, 193, 7));
                
                await _serviceManager.StartServiceAsync("IsotoneMariaDB");
                _snackbarMessageQueue.Enqueue("MariaDB service started");
            }
            catch (Exception ex)
            {
                MariaDBStatus = "Error";
                MariaDBStatusColor = new SolidColorBrush(Color.FromRgb(244, 67, 54));
                _snackbarMessageQueue.Enqueue($"Failed to start MariaDB: {ex.Message}");
            }
            finally
            {
                IsMariaDBLoading = false;
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StopMariaDB()
        {
            try
            {
                IsMariaDBLoading = true;
                MariaDBStatus = "Stopping";
                MariaDBStatusColor = new SolidColorBrush(Color.FromRgb(255, 152, 0));
                
                await _serviceManager.StopServiceAsync("IsotoneMariaDB");
                _snackbarMessageQueue.Enqueue("MariaDB service stopped");
            }
            catch (Exception ex)
            {
                MariaDBStatus = "Error";
                MariaDBStatusColor = new SolidColorBrush(Color.FromRgb(244, 67, 54));
                _snackbarMessageQueue.Enqueue($"Failed to stop MariaDB: {ex.Message}");
            }
            finally
            {
                IsMariaDBLoading = false;
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RestartMariaDB()
        {
            try
            {
                IsMariaDBLoading = true;
                MariaDBStatus = "Restarting";
                MariaDBStatusColor = new SolidColorBrush(Color.FromRgb(3, 169, 244));
                
                await _serviceManager.RestartServiceAsync("IsotoneMariaDB");
                MariaDBStartTime = DateTime.Now;
                _snackbarMessageQueue.Enqueue("MariaDB service restarted");
            }
            catch (Exception ex)
            {
                MariaDBStatus = "Error";
                MariaDBStatusColor = new SolidColorBrush(Color.FromRgb(244, 67, 54));
                _snackbarMessageQueue.Enqueue($"Failed to restart MariaDB: {ex.Message}");
            }
            finally
            {
                IsMariaDBLoading = false;
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StartMailpit()
        {
            try
            {
                IsMailpitLoading = true;
                MailpitStatus = "Starting";
                MailpitStatusColor = new SolidColorBrush(Color.FromRgb(255, 193, 7));
                
                await _serviceManager.StartServiceAsync("IsotoneMailpit");
                _snackbarMessageQueue.Enqueue("Mailpit service started");
            }
            catch (Exception ex)
            {
                MailpitStatus = "Error";
                MailpitStatusColor = new SolidColorBrush(Color.FromRgb(244, 67, 54));
                _snackbarMessageQueue.Enqueue($"Failed to start Mailpit: {ex.Message}");
            }
            finally
            {
                IsMailpitLoading = false;
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StopMailpit()
        {
            try
            {
                IsMailpitLoading = true;
                MailpitStatus = "Stopping";
                MailpitStatusColor = new SolidColorBrush(Color.FromRgb(255, 152, 0));
                
                await _serviceManager.StopServiceAsync("IsotoneMailpit");
                _snackbarMessageQueue.Enqueue("Mailpit service stopped");
            }
            catch (Exception ex)
            {
                MailpitStatus = "Error";
                MailpitStatusColor = new SolidColorBrush(Color.FromRgb(244, 67, 54));
                _snackbarMessageQueue.Enqueue($"Failed to stop Mailpit: {ex.Message}");
            }
            finally
            {
                IsMailpitLoading = false;
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RestartMailpit()
        {
            try
            {
                IsMailpitLoading = true;
                MailpitStatus = "Restarting";
                MailpitStatusColor = new SolidColorBrush(Color.FromRgb(3, 169, 244));
                
                await _serviceManager.RestartServiceAsync("IsotoneMailpit");
                MailpitStartTime = DateTime.Now;
                _snackbarMessageQueue.Enqueue("Mailpit service restarted");
            }
            catch (Exception ex)
            {
                MailpitStatus = "Error";
                MailpitStatusColor = new SolidColorBrush(Color.FromRgb(244, 67, 54));
                _snackbarMessageQueue.Enqueue($"Failed to restart Mailpit: {ex.Message}");
            }
            finally
            {
                IsMailpitLoading = false;
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

        [RelayCommand]
        private async System.Threading.Tasks.Task ConfigureApache()
        {
            try
            {
                var wasInstalled = IsApacheInstalled;
                var scriptsPath = System.IO.Path.Combine(_configManager.Configuration.IsotonePath, "scripts");
                var scriptPath = wasInstalled 
                    ? System.IO.Path.Combine(scriptsPath, "Unregister-Services.bat")
                    : System.IO.Path.Combine(scriptsPath, "Register-Services.bat");
                    
                if (System.IO.File.Exists(scriptPath))
                {
                    var process = new System.Diagnostics.Process
                    {
                        StartInfo = new System.Diagnostics.ProcessStartInfo
                        {
                            FileName = scriptPath,
                            Arguments = "-Apache",
                            UseShellExecute = true,
                            Verb = "runas"
                        }
                    };
                    process.Start();
                    await System.Threading.Tasks.Task.Run(() => process.WaitForExit());
                    
                    // Wait a moment for Windows to register/unregister the service
                    await System.Threading.Tasks.Task.Delay(2000);
                    
                    // Force refresh on UI thread
                    await System.Windows.Application.Current.Dispatcher.InvokeAsync(() =>
                    {
                        _serviceManager.RefreshServices();
                        var apacheService = _serviceManager.GetService("IsotoneApache");
                        UpdateApacheStatus(apacheService);
                        // Force property change notification
                        OnPropertyChanged(nameof(IsApacheInstalled));
                    });
                    
                    _snackbarMessageQueue.Enqueue(wasInstalled ? "Apache service uninstalled" : "Apache service installed");
                }
                else
                {
                    _snackbarMessageQueue.Enqueue($"Script not found: {scriptPath}");
                }
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to configure Apache: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task ConfigureMariaDB()
        {
            try
            {
                var wasInstalled = IsMariaDBInstalled;
                var scriptsPath = System.IO.Path.Combine(_configManager.Configuration.IsotonePath, "scripts");
                var scriptPath = wasInstalled 
                    ? System.IO.Path.Combine(scriptsPath, "Unregister-Services.bat")
                    : System.IO.Path.Combine(scriptsPath, "Register-Services.bat");
                    
                if (System.IO.File.Exists(scriptPath))
                {
                    var process = new System.Diagnostics.Process
                    {
                        StartInfo = new System.Diagnostics.ProcessStartInfo
                        {
                            FileName = scriptPath,
                            Arguments = "-MariaDB",
                            UseShellExecute = true,
                            Verb = "runas"
                        }
                    };
                    process.Start();
                    await System.Threading.Tasks.Task.Run(() => process.WaitForExit());
                    
                    // Wait a moment for Windows to register/unregister the service
                    await System.Threading.Tasks.Task.Delay(2000);
                    
                    // Force refresh on UI thread
                    await System.Windows.Application.Current.Dispatcher.InvokeAsync(() =>
                    {
                        _serviceManager.RefreshServices();
                        var mariadbService = _serviceManager.GetService("IsotoneMariaDB");
                        UpdateMariaDBStatus(mariadbService);
                        // Force property change notification
                        OnPropertyChanged(nameof(IsMariaDBInstalled));
                    });
                    
                    _snackbarMessageQueue.Enqueue(wasInstalled ? "MariaDB service uninstalled" : "MariaDB service installed");
                }
                else
                {
                    _snackbarMessageQueue.Enqueue($"Script not found: {scriptPath}");
                }
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to configure MariaDB: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task ConfigureMailpit()
        {
            try
            {
                var wasInstalled = IsMailpitInstalled;
                var scriptsPath = System.IO.Path.Combine(_configManager.Configuration.IsotonePath, "scripts");
                var scriptPath = wasInstalled 
                    ? System.IO.Path.Combine(scriptsPath, "Unregister-Services.bat")
                    : System.IO.Path.Combine(scriptsPath, "Register-Services.bat");
                    
                if (System.IO.File.Exists(scriptPath))
                {
                    var process = new System.Diagnostics.Process
                    {
                        StartInfo = new System.Diagnostics.ProcessStartInfo
                        {
                            FileName = scriptPath,
                            Arguments = "-Mailpit",
                            UseShellExecute = true,
                            Verb = "runas"
                        }
                    };
                    process.Start();
                    await System.Threading.Tasks.Task.Run(() => process.WaitForExit());
                    
                    // Wait a moment for Windows to register/unregister the service
                    await System.Threading.Tasks.Task.Delay(2000);
                    
                    // Force refresh on UI thread
                    await System.Windows.Application.Current.Dispatcher.InvokeAsync(() =>
                    {
                        _serviceManager.RefreshServices();
                        var mailpitService = _serviceManager.GetService("IsotoneMailpit");
                        UpdateMailpitStatus(mailpitService);
                        // Force property change notification
                        OnPropertyChanged(nameof(IsMailpitInstalled));
                    });
                    
                    _snackbarMessageQueue.Enqueue(wasInstalled ? "Mailpit service uninstalled" : "Mailpit service installed");
                }
                else
                {
                    _snackbarMessageQueue.Enqueue($"Script not found: {scriptPath}");
                }
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to configure Mailpit: {ex.Message}");
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

        private async System.Threading.Tasks.Task GetServiceVersionsAsync()
        {
            await System.Threading.Tasks.Task.Run(() =>
            {
                // Get Apache version
                try
                {
                    var apachePath = System.IO.Path.Combine(_configManager.Configuration.IsotonePath, "apache24", "bin", "httpd.exe");
                    if (System.IO.File.Exists(apachePath))
                    {
                        var process = new System.Diagnostics.Process
                        {
                            StartInfo = new System.Diagnostics.ProcessStartInfo
                            {
                                FileName = apachePath,
                                Arguments = "-v",
                                UseShellExecute = false,
                                RedirectStandardOutput = true,
                                CreateNoWindow = true
                            }
                        };
                        process.Start();
                        var output = process.StandardOutput.ReadToEnd();
                        process.WaitForExit();
                        
                        // Parse version from output like "Server version: Apache/2.4.58 (Win64)"
                        var match = System.Text.RegularExpressions.Regex.Match(output, @"Apache/([\d\.]+)");
                        if (match.Success)
                        {
                            ApacheVersion = match.Groups[1].Value;
                        }
                        else
                        {
                            ApacheVersion = "2.4.x";
                        }
                    }
                }
                catch
                {
                    ApacheVersion = "2.4.x";
                }

                // Get MariaDB version
                try
                {
                    var mariadbPath = System.IO.Path.Combine(_configManager.Configuration.IsotonePath, "mariadb", "bin", "mysqld.exe");
                    if (System.IO.File.Exists(mariadbPath))
                    {
                        var process = new System.Diagnostics.Process
                        {
                            StartInfo = new System.Diagnostics.ProcessStartInfo
                            {
                                FileName = mariadbPath,
                                Arguments = "--version",
                                UseShellExecute = false,
                                RedirectStandardOutput = true,
                                CreateNoWindow = true
                            }
                        };
                        process.Start();
                        var output = process.StandardOutput.ReadToEnd();
                        process.WaitForExit();
                        
                        // Parse version from output like "mysqld  Ver 11.5.2-MariaDB for Win64"
                        var match = System.Text.RegularExpressions.Regex.Match(output, @"Ver\s+([\d\.]+)");
                        if (match.Success)
                        {
                            MariaDBVersion = match.Groups[1].Value;
                        }
                        else
                        {
                            MariaDBVersion = "11.x";
                        }
                    }
                }
                catch
                {
                    MariaDBVersion = "11.x";
                }

                // Get Mailpit version
                try
                {
                    var mailpitPath = System.IO.Path.Combine(_configManager.Configuration.IsotonePath, "mailpit", "mailpit.exe");
                    if (System.IO.File.Exists(mailpitPath))
                    {
                        var process = new System.Diagnostics.Process
                        {
                            StartInfo = new System.Diagnostics.ProcessStartInfo
                            {
                                FileName = mailpitPath,
                                Arguments = "version",
                                UseShellExecute = false,
                                RedirectStandardOutput = true,
                                CreateNoWindow = true
                            }
                        };
                        process.Start();
                        var output = process.StandardOutput.ReadToEnd();
                        process.WaitForExit();
                        
                        // Parse version from output like "Mailpit v1.21.5"
                        var match = System.Text.RegularExpressions.Regex.Match(output, @"v([\d\.]+)");
                        if (match.Success)
                        {
                            MailpitVersion = match.Groups[1].Value;
                        }
                        else
                        {
                            MailpitVersion = "1.x";
                        }
                    }
                }
                catch
                {
                    MailpitVersion = "1.x";
                }

                // Get PHP version
                try
                {
                    var phpPath = System.IO.Path.Combine(_configManager.Configuration.IsotonePath, "php", "php.exe");
                    if (System.IO.File.Exists(phpPath))
                    {
                        var process = new System.Diagnostics.Process
                        {
                            StartInfo = new System.Diagnostics.ProcessStartInfo
                            {
                                FileName = phpPath,
                                Arguments = "-v",
                                UseShellExecute = false,
                                RedirectStandardOutput = true,
                                CreateNoWindow = true
                            }
                        };
                        process.Start();
                        var output = process.StandardOutput.ReadToEnd();
                        process.WaitForExit();
                        
                        // Parse version from output like "PHP 8.3.14 (cli)"
                        var match = System.Text.RegularExpressions.Regex.Match(output, @"PHP\s+([\d\.]+)");
                        if (match.Success)
                        {
                            PhpVersion = match.Groups[1].Value;
                        }
                        else
                        {
                            PhpVersion = "8.3.x";
                        }
                    }
                }
                catch
                {
                    PhpVersion = "8.3.x";
                }
            });
        }
    }
}