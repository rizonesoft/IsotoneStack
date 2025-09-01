using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Isotone.Utilities;

namespace Isotone.ViewModels
{
    public partial class LogsViewModel : ObservableObject
    {
        private readonly ConfigurationManager _configManager;

        [ObservableProperty]
        private ObservableCollection<string> logFiles;

        [ObservableProperty]
        private string? selectedLogFile;

        [ObservableProperty]
        private string logContent = "Select a log file to view its contents...";

        public LogsViewModel(ConfigurationManager configManager)
        {
            _configManager = configManager;

            LogFiles = new ObservableCollection<string>
            {
                "Apache Error Log",
                "Apache Access Log",
                "MariaDB Error Log",
                "PHP Error Log",
                "IsotoneStack Log"
            };
        }

        partial void OnSelectedLogFileChanged(string? value)
        {
            if (value != null)
            {
                LoadLogContent(value);
            }
        }

        private void LoadLogContent(string logFile)
        {
            // Placeholder for loading actual log content
            LogContent = $"Contents of {logFile} will be displayed here...";
        }

        [RelayCommand]
        private void Refresh()
        {
            if (SelectedLogFile != null)
            {
                LoadLogContent(SelectedLogFile);
            }
        }

        [RelayCommand]
        private void ClearLog()
        {
            if (SelectedLogFile != null)
            {
                LogContent = "Log cleared.";
            }
        }
    }
}