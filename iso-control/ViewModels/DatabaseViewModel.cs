using CommunityToolkit.Mvvm.ComponentModel;
using Isotone.Utilities;

namespace Isotone.ViewModels
{
    public partial class DatabaseViewModel : ObservableObject
    {
        private readonly ConfigurationManager _configManager;

        public DatabaseViewModel(ConfigurationManager configManager)
        {
            _configManager = configManager;
        }
    }
}