using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Threading.Tasks;

namespace Isotone.Services
{
    public class ServiceManager
    {
        private readonly string _isotonePath;
        private readonly Dictionary<string, ServiceInfo> _services;

        public ServiceManager(string isotonePath)
        {
            _isotonePath = isotonePath;
            _services = new Dictionary<string, ServiceInfo>
            {
                ["IsotoneApache"] = new ServiceInfo 
                { 
                    Name = "IsotoneApache", 
                    DisplayName = "IsotoneStack Apache Service",
                    Description = "Apache HTTP Server for IsotoneStack"
                },
                ["IsotoneMariaDB"] = new ServiceInfo 
                { 
                    Name = "IsotoneMariaDB", 
                    DisplayName = "IsotoneStack MariaDB Service",
                    Description = "MariaDB Database Server for IsotoneStack"
                },
                ["IsotoneMailpit"] = new ServiceInfo 
                { 
                    Name = "IsotoneMailpit", 
                    DisplayName = "IsotoneStack Mailpit Service",
                    Description = "Email testing tool for IsotoneStack"
                }
            };

            RefreshServices();
        }

        public void RefreshServices()
        {
            foreach (var serviceName in _services.Keys.ToList())
            {
                try
                {
                    using var controller = new ServiceController(serviceName);
                    var service = _services[serviceName];
                    service.IsInstalled = true;
                    service.IsRunning = controller.Status == ServiceControllerStatus.Running;
                    service.StartupType = GetStartupType(controller);
                }
                catch (InvalidOperationException)
                {
                    // Service doesn't exist
                    _services[serviceName].IsInstalled = false;
                    _services[serviceName].IsRunning = false;
                }
            }
        }

        private string GetStartupType(ServiceController controller)
        {
            // This would normally query the service startup type
            // For now, returning a default value
            return "Manual";
        }

        public ServiceInfo? GetService(string name)
        {
            RefreshServices();
            return _services.TryGetValue(name, out var service) ? service : null;
        }

        public List<ServiceInfo> GetAllServices()
        {
            RefreshServices();
            return _services.Values.ToList();
        }

        public async Task StartServiceAsync(string serviceName)
        {
            await Task.Run(() =>
            {
                using var controller = new ServiceController(serviceName);
                if (controller.Status != ServiceControllerStatus.Running)
                {
                    controller.Start();
                    controller.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromSeconds(30));
                }
            });
            RefreshServices();
        }

        public async Task StopServiceAsync(string serviceName)
        {
            await Task.Run(() =>
            {
                using var controller = new ServiceController(serviceName);
                if (controller.Status != ServiceControllerStatus.Stopped)
                {
                    controller.Stop();
                    controller.WaitForStatus(ServiceControllerStatus.Stopped, TimeSpan.FromSeconds(30));
                }
            });
            RefreshServices();
        }

        public async Task RestartServiceAsync(string serviceName)
        {
            await StopServiceAsync(serviceName);
            await StartServiceAsync(serviceName);
        }

        public async Task StartAllServicesAsync()
        {
            foreach (var serviceName in _services.Keys)
            {
                try
                {
                    await StartServiceAsync(serviceName);
                }
                catch { }
            }
        }

        public async Task StopAllServicesAsync()
        {
            foreach (var serviceName in _services.Keys)
            {
                try
                {
                    await StopServiceAsync(serviceName);
                }
                catch { }
            }
        }

        public async Task RestartAllServicesAsync()
        {
            await StopAllServicesAsync();
            await StartAllServicesAsync();
        }
    }

    public class ServiceInfo
    {
        public string Name { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public bool IsInstalled { get; set; }
        public bool IsRunning { get; set; }
        public string StartupType { get; set; } = "Manual";
    }
}