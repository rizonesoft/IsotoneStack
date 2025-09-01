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
    }
}