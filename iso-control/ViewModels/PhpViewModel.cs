using System;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Windows.Input;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MaterialDesignThemes.Wpf;
using Isotone.Utilities;
using Isotone.Services;

namespace Isotone.ViewModels
{
    public partial class PhpViewModel : ObservableObject
    {
        private readonly PHPManager _phpManager;
        private readonly ConfigurationManager _configManager;
        private readonly ServiceManager _serviceManager;
        private readonly ISnackbarMessageQueue _snackbarMessageQueue;

        [ObservableProperty]
        private ObservableCollection<PhpVersion> availableVersions = new();

        [ObservableProperty]
        private PhpVersion? selectedVersion;

        [ObservableProperty]
        private ObservableCollection<PhpExtensionViewModel> availableExtensions = new();

        [ObservableProperty]
        private string currentPhpInfo = "Loading...";

        [ObservableProperty]
        private bool isApacheRunning;

        [ObservableProperty]
        private bool isLoading;

        public PhpViewModel(ConfigurationManager configManager, ServiceManager serviceManager, ISnackbarMessageQueue snackbarMessageQueue)
        {
            _configManager = configManager;
            _serviceManager = serviceManager;
            _snackbarMessageQueue = snackbarMessageQueue;
            _phpManager = new PHPManager(_configManager.Configuration.IsotonePath);

            // Load versions asynchronously to avoid blocking UI
            _ = LoadPhpVersionsAsync();
            _ = UpdateApacheStatusAsync();
        }

        private async System.Threading.Tasks.Task LoadPhpVersionsAsync()
        {
            IsLoading = true;

            try
            {
                // Run detection on background thread
                var versions = await System.Threading.Tasks.Task.Run(() => _phpManager.DetectPhpVersions());
                
                // Update UI on UI thread
                AvailableVersions = new ObservableCollection<PhpVersion>(versions);

                if (versions.Count == 0)
                {
                    CurrentPhpInfo = $"No PHP versions found in {System.IO.Path.Combine(_configManager.Configuration.IsotonePath, "php")}";
                    _snackbarMessageQueue.Enqueue("No PHP versions detected. Check php folder.");
                    return;
                }

                // Select the configured version
                var configuredVersion = _configManager.Configuration.SelectedPhpVersion;
                SelectedVersion = AvailableVersions.FirstOrDefault(v => v.Version == configuredVersion) 
                                ?? AvailableVersions.FirstOrDefault();

                if (SelectedVersion != null)
                {
                    LoadExtensionsForVersion(SelectedVersion);
                }
                else
                {
                    CurrentPhpInfo = "No PHP version selected";
                }

                UpdatePhpInfo();
            }
            catch (Exception ex)
            {
                CurrentPhpInfo = $"Error: {ex.Message}";
                ErrorHandler.HandleException(ex, "PhpViewModel.LoadPhpVersionsAsync", "Failed to load PHP versions");
                _snackbarMessageQueue.Enqueue($"Error loading PHP versions: {ex.Message}");
            }
            finally
            {
                IsLoading = false;
            }
        }

        partial void OnSelectedVersionChanged(PhpVersion? value)
        {
            if (value != null)
            {
                LoadExtensionsForVersion(value);
                UpdatePhpInfo();
            }
        }

        private void LoadExtensionsForVersion(PhpVersion version)
        {
            try
            {
                var extensions = _phpManager.GetAvailableExtensions(version.Version);
                var enabledExtensions = _phpManager.GetEnabledExtensions(version.Version);

                // Check if php.ini exists
                var phpIniPath = System.IO.Path.Combine(_configManager.Configuration.IsotonePath, "php", version.Version, "php.ini");
                if (!System.IO.File.Exists(phpIniPath))
                {
                    CurrentPhpInfo = $"PHP {version.Version} not configured yet.\nRun Configure-IsotoneStack.ps1 to set up PHP.";
                }

                var extViewModels = extensions.Select(ext => new PhpExtensionViewModel
                {
                    Name = ext.Name,
                    DisplayName = ext.DisplayName,
                    Description = ext.Description,
                    IsEnabled = enabledExtensions.Contains(ext.Name)
                }).ToList();

                AvailableExtensions = new ObservableCollection<PhpExtensionViewModel>(extViewModels);
            }
            catch (Exception ex)
            {
                ErrorHandler.HandleException(ex, "PhpViewModel.LoadExtensionsForVersion", "Failed to load PHP extensions");
                _snackbarMessageQueue.Enqueue($"Error loading extensions: {ex.Message}");
            }
        }

        private void UpdatePhpInfo()
        {
            if (SelectedVersion == null)
            {
                CurrentPhpInfo = "No PHP version selected";
                return;
            }

            try
            {
                var phpExe = Path.Combine(SelectedVersion.Path, "php.exe");
                var phpIni = Path.Combine(SelectedVersion.Path, "php.ini");
                var extPath = Path.Combine(SelectedVersion.Path, "ext");

                var info = $"PHP Version: {SelectedVersion.FullVersion}\n";
                info += $"Path: {SelectedVersion.Path}\n";
                info += $"PHP Executable: {(File.Exists(phpExe) ? "Found" : "Missing")}\n";
                info += $"php.ini: {(File.Exists(phpIni) ? "Found" : "Missing")}\n";
                info += $"Extensions Folder: {(Directory.Exists(extPath) ? "Found" : "Missing")}\n";
                info += $"Available Extensions: {AvailableExtensions.Count}\n";
                info += $"Enabled Extensions: {AvailableExtensions.Count(e => e.IsEnabled)}";

                CurrentPhpInfo = info;
            }
            catch (Exception ex)
            {
                CurrentPhpInfo = $"Error getting PHP info: {ex.Message}";
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task ApplyChangesAsync()
        {
            if (SelectedVersion == null)
            {
                _snackbarMessageQueue.Enqueue("No PHP version selected");
                return;
            }

            IsLoading = true;

            try
            {
                // Update extensions in php.ini
                var enabledExtensions = AvailableExtensions.Where(e => e.IsEnabled).Select(e => e.Name).ToList();
                var success = _phpManager.UpdateExtensions(SelectedVersion.Version, enabledExtensions);

                if (!success)
                {
                    _snackbarMessageQueue.Enqueue("Failed to update php.ini");
                    return;
                }

                // Save selected version to configuration
                _configManager.Configuration.SelectedPhpVersion = SelectedVersion.Version;
                _configManager.Configuration.EnabledPhpExtensions = enabledExtensions;
                _configManager.Save();

                // Run the Switch-PHPVersion script
                var scriptPath = Path.Combine(_configManager.Configuration.IsotonePath, "scripts", "Switch-PHPVersion.ps1");
                if (File.Exists(scriptPath))
                {
                    var pwshPath = Path.Combine(_configManager.Configuration.IsotonePath, "pwsh", "pwsh.exe");
                    
                    var process = new Process
                    {
                        StartInfo = new ProcessStartInfo
                        {
                            FileName = pwshPath,
                            Arguments = $"-ExecutionPolicy Bypass -File \"{scriptPath}\" -Version \"{SelectedVersion.Version}\"",
                            UseShellExecute = false,
                            RedirectStandardOutput = true,
                            RedirectStandardError = true,
                            CreateNoWindow = true,
                            WorkingDirectory = _configManager.Configuration.IsotonePath
                        }
                    };

                    process.Start();
                    var output = await process.StandardOutput.ReadToEndAsync();
                    var error = await process.StandardError.ReadToEndAsync();
                    await process.WaitForExitAsync();

                    if (process.ExitCode == 0)
                    {
                        _snackbarMessageQueue.Enqueue($"PHP {SelectedVersion.Version} activated successfully!");
                        UpdatePhpInfo();
                    }
                    else
                    {
                        _snackbarMessageQueue.Enqueue($"Error switching PHP version: {error}");
                    }
                }
                else
                {
                    _snackbarMessageQueue.Enqueue("Switch-PHPVersion.ps1 script not found. Please restart Apache manually.");
                }
            }
            catch (Exception ex)
            {
                ErrorHandler.HandleException(ex, "PhpViewModel.ApplyChangesAsync", "Failed to apply PHP configuration changes");
                _snackbarMessageQueue.Enqueue($"Error applying changes: {ex.Message}");
            }
            finally
            {
                IsLoading = false;
            }
        }

        [RelayCommand]
        private async System.Threading.Tasks.Task RefreshVersions()
        {
            await LoadPhpVersionsAsync();
            _snackbarMessageQueue.Enqueue("PHP versions refreshed");
        }

        [RelayCommand]
        private void SelectAllExtensions()
        {
            foreach (var ext in AvailableExtensions)
            {
                ext.IsEnabled = true;
            }
        }

        [RelayCommand]
        private void DeselectAllExtensions()
        {
            foreach (var ext in AvailableExtensions)
            {
                ext.IsEnabled = false;
            }
        }

        [RelayCommand]
        private void OpenPhpFolder()
        {
            if (SelectedVersion != null && Directory.Exists(SelectedVersion.Path))
            {
                Process.Start("explorer.exe", SelectedVersion.Path);
            }
        }

        [RelayCommand]
        private void OpenPhpIni()
        {
            if (SelectedVersion != null)
            {
                var phpIniPath = Path.Combine(SelectedVersion.Path, "php.ini");
                if (File.Exists(phpIniPath))
                {
                    Process.Start(new ProcessStartInfo
                    {
                        FileName = phpIniPath,
                        UseShellExecute = true
                    });
                }
                else
                {
                    _snackbarMessageQueue.Enqueue("php.ini not found for this version");
                }
            }
        }


        private async System.Threading.Tasks.Task UpdateApacheStatusAsync()
        {
            while (true)
            {
                try
                {
                    var apacheService = _serviceManager.GetAllServices().FirstOrDefault(s => s.Name.Contains("Apache"));
                    IsApacheRunning = apacheService?.IsRunning ?? false;
                }
                catch
                {
                    IsApacheRunning = false;
                }

                await System.Threading.Tasks.Task.Delay(3000);
            }
        }
    }

    public partial class PhpExtensionViewModel : ObservableObject
    {
        [ObservableProperty]
        private string name = string.Empty;

        [ObservableProperty]
        private string displayName = string.Empty;

        [ObservableProperty]
        private string description = string.Empty;

        [ObservableProperty]
        private bool isEnabled;
    }
}
