using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows.Media;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MaterialDesignThemes.Wpf;
using Isotone.Services;
using Isotone.Utilities;

namespace Isotone.ViewModels
{
    public partial class ServicesViewModel : ObservableObject
    {
        private readonly ServiceManager _serviceManager;
        private readonly ConfigurationManager _configManager;
        private readonly ISnackbarMessageQueue _snackbarMessageQueue;

        [ObservableProperty]
        private ObservableCollection<ServiceItemViewModel> services;

        public ServicesViewModel(ServiceManager serviceManager, ConfigurationManager configManager, ISnackbarMessageQueue snackbarMessageQueue)
        {
            _serviceManager = serviceManager;
            _configManager = configManager;
            _snackbarMessageQueue = snackbarMessageQueue;

            Services = new ObservableCollection<ServiceItemViewModel>();
            LoadServices();

            _ = UpdateServiceStatusAsync();
        }

        private void LoadServices()
        {
            var serviceList = _serviceManager.GetAllServices();
            
            Services.Clear();
            foreach (var service in serviceList)
            {
                Services.Add(new ServiceItemViewModel(service));
            }
        }

        private async System.Threading.Tasks.Task UpdateServiceStatusAsync()
        {
            while (true)
            {
                try
                {
                    foreach (var serviceVm in Services)
                    {
                        var service = _serviceManager.GetService(serviceVm.Name);
                        if (service != null)
                        {
                            serviceVm.UpdateFromServiceInfo(service);
                        }
                    }
                }
                catch
                {
                    // Silently handle errors in background update
                }

                await System.Threading.Tasks.Task.Delay(2000);
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StartService(ServiceItemViewModel service)
        {
            try
            {
                await _serviceManager.StartServiceAsync(service.Name);
                _snackbarMessageQueue.Enqueue($"{service.DisplayName} started");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to start {service.DisplayName}: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task StopService(ServiceItemViewModel service)
        {
            try
            {
                await _serviceManager.StopServiceAsync(service.Name);
                _snackbarMessageQueue.Enqueue($"{service.DisplayName} stopped");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to stop {service.DisplayName}: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RestartService(ServiceItemViewModel service)
        {
            try
            {
                await _serviceManager.RestartServiceAsync(service.Name);
                _snackbarMessageQueue.Enqueue($"{service.DisplayName} restarted");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to restart {service.DisplayName}: {ex.Message}");
            }
        }

        [RelayCommand]
        private void ConfigureService(ServiceItemViewModel service)
        {
            _snackbarMessageQueue.Enqueue($"Configuration for {service.DisplayName} coming soon");
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RegisterServices()
        {
            try
            {
                // This would call a script to register all services
                _snackbarMessageQueue.Enqueue("Registering services...");
                await System.Threading.Tasks.Task.Delay(1000);
                LoadServices();
                _snackbarMessageQueue.Enqueue("Services registered successfully");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to register services: {ex.Message}");
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task UnregisterServices()
        {
            try
            {
                // This would call a script to unregister all services
                _snackbarMessageQueue.Enqueue("Unregistering services...");
                await System.Threading.Tasks.Task.Delay(1000);
                LoadServices();
                _snackbarMessageQueue.Enqueue("Services unregistered successfully");
            }
            catch (Exception ex)
            {
                _snackbarMessageQueue.Enqueue($"Failed to unregister services: {ex.Message}");
            }
        }
    }

    public partial class ServiceItemViewModel : ObservableObject
    {
        [ObservableProperty]
        private string name;

        [ObservableProperty]
        private string displayName;

        [ObservableProperty]
        private string status;

        [ObservableProperty]
        private Brush statusColor;

        [ObservableProperty]
        private bool isInstalled;

        [ObservableProperty]
        private bool canStart;

        [ObservableProperty]
        private bool canStop;

        [ObservableProperty]
        private bool canRestart;

        [ObservableProperty]
        private string startupType;

        public ObservableCollection<string> StartupTypes { get; }

        public ServiceItemViewModel(ServiceInfo serviceInfo)
        {
            Name = serviceInfo.Name;
            DisplayName = serviceInfo.DisplayName;
            StartupTypes = new ObservableCollection<string> { "Automatic", "Manual", "Disabled" };
            UpdateFromServiceInfo(serviceInfo);
        }

        public void UpdateFromServiceInfo(ServiceInfo serviceInfo)
        {
            IsInstalled = serviceInfo.IsInstalled;
            
            if (serviceInfo.IsInstalled)
            {
                Status = serviceInfo.IsRunning ? "Running" : "Stopped";
                StatusColor = serviceInfo.IsRunning ? Brushes.LightGreen : Brushes.OrangeRed;
                CanStart = !serviceInfo.IsRunning;
                CanStop = serviceInfo.IsRunning;
                CanRestart = serviceInfo.IsRunning;
                StartupType = serviceInfo.StartupType;
            }
            else
            {
                Status = "Not Installed";
                StatusColor = Brushes.Gray;
                CanStart = false;
                CanStop = false;
                CanRestart = false;
                StartupType = "Manual";
            }
        }
    }
}