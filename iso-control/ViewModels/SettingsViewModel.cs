using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Isotone.Utilities;

namespace Isotone.ViewModels
{
    public partial class SettingsViewModel : ObservableObject
    {
        private readonly ConfigurationManager _configManager;

        [ObservableProperty]
        private bool autoStartServices;

        [ObservableProperty]
        private bool minimizeToTray;

        [ObservableProperty]
        private bool autoCheckUpdates;

        [ObservableProperty]
        private string isotonePath;

        [ObservableProperty]
        private string webRootPath;

        [ObservableProperty]
        private string apachePort = "80";

        [ObservableProperty]
        private string apacheSSLPort = "443";

        [ObservableProperty]
        private string mariaDBPort = "3306";

        public SettingsViewModel(ConfigurationManager configManager)
        {
            _configManager = configManager;
            LoadSettings();
        }

        private void LoadSettings()
        {
            var config = _configManager.Configuration;
            IsotonePath = config.IsotonePath;
            WebRootPath = System.IO.Path.Combine(config.IsotonePath, "www");
            AutoStartServices = config.AutoStartServices;
            MinimizeToTray = config.MinimizeToTray;
            AutoCheckUpdates = config.AutoCheckUpdates;
        }

        [RelayCommand]
        private void SaveSettings()
        {
            var config = _configManager.Configuration;
            config.AutoStartServices = AutoStartServices;
            config.MinimizeToTray = MinimizeToTray;
            config.AutoCheckUpdates = AutoCheckUpdates;
            _configManager.Save();
        }

        [RelayCommand]
        private void ResetSettings()
        {
            LoadSettings();
        }

        [RelayCommand]
        private void OpenErrorLog()
        {
            try
            {
                ErrorHandler.OpenErrorLog();
            }
            catch (System.Exception ex)
            {
                ErrorHandler.HandleException(ex, "SettingsViewModel.OpenErrorLog", "Failed to open error log");
            }
        }

        [RelayCommand]
        private void ClearErrorLog()
        {
            try
            {
                var result = System.Windows.MessageBox.Show(
                    "Are you sure you want to clear the error log? This action cannot be undone.",
                    "Clear Error Log",
                    System.Windows.MessageBoxButton.YesNo,
                    System.Windows.MessageBoxImage.Question
                );

                if (result == System.Windows.MessageBoxResult.Yes)
                {
                    ErrorHandler.ClearErrorLog();
                    System.Windows.MessageBox.Show(
                        "Error log has been cleared successfully.",
                        "Success",
                        System.Windows.MessageBoxButton.OK,
                        System.Windows.MessageBoxImage.Information
                    );
                }
            }
            catch (System.Exception ex)
            {
                ErrorHandler.HandleException(ex, "SettingsViewModel.ClearErrorLog", "Failed to clear error log");
            }
        }

        [RelayCommand]
        private void ShowErrorLogPath()
        {
            try
            {
                var path = ErrorHandler.GetErrorLogPath();
                System.Windows.MessageBox.Show(
                    $"Error log location:\n\n{path}",
                    "Error Log Path",
                    System.Windows.MessageBoxButton.OK,
                    System.Windows.MessageBoxImage.Information
                );
            }
            catch (System.Exception ex)
            {
                ErrorHandler.HandleException(ex, "SettingsViewModel.ShowErrorLogPath", "Failed to get error log path");
            }
        }
    }
}