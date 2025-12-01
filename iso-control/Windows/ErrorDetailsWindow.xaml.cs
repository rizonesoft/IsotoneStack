using System.Windows;
using System.Windows.Media;
using Isotone.Utilities;

namespace Isotone.Windows
{
    public partial class ErrorDetailsWindow : Window
    {
        private readonly ErrorInfo _errorInfo;
        private bool _isStackTraceVisible = false;

        public ErrorDetailsWindow(ErrorInfo errorInfo)
        {
            InitializeComponent();
            _errorInfo = errorInfo;
            LoadErrorInfo();
        }

        private void LoadErrorInfo()
        {
            // Set title and timestamp
            ErrorTitle.Text = _errorInfo.Title;
            ErrorTimestamp.Text = _errorInfo.Timestamp.ToString("yyyy-MM-dd HH:mm:ss");

            // Set icon and color based on severity
            switch (_errorInfo.Severity)
            {
                case ErrorSeverity.Information:
                    ErrorIcon.Kind = MaterialDesignThemes.Wpf.PackIconKind.Information;
                    ErrorIcon.Foreground = new SolidColorBrush(Color.FromRgb(74, 158, 255)); // Blue
                    break;
                case ErrorSeverity.Warning:
                    ErrorIcon.Kind = MaterialDesignThemes.Wpf.PackIconKind.AlertCircle;
                    ErrorIcon.Foreground = new SolidColorBrush(Color.FromRgb(255, 165, 0)); // Orange
                    break;
                case ErrorSeverity.Error:
                    ErrorIcon.Kind = MaterialDesignThemes.Wpf.PackIconKind.AlertCircle;
                    ErrorIcon.Foreground = new SolidColorBrush(Color.FromRgb(255, 82, 82)); // Red
                    break;
                case ErrorSeverity.Critical:
                    ErrorIcon.Kind = MaterialDesignThemes.Wpf.PackIconKind.AlertOctagon;
                    ErrorIcon.Foreground = new SolidColorBrush(Color.FromRgb(200, 30, 30)); // Dark Red
                    break;
            }

            // Set message
            ErrorMessage.Text = _errorInfo.Message;

            // Show details if available
            if (!string.IsNullOrEmpty(_errorInfo.Details))
            {
                DetailsSection.Visibility = Visibility.Visible;
                ErrorDetails.Text = _errorInfo.Details;
            }

            // Show source if available
            if (!string.IsNullOrEmpty(_errorInfo.Source))
            {
                SourceSection.Visibility = Visibility.Visible;
                ErrorSource.Text = _errorInfo.Source;
            }

            // Show stack trace if available
            if (!string.IsNullOrEmpty(_errorInfo.StackTrace))
            {
                StackTraceSection.Visibility = Visibility.Visible;
                ErrorStackTrace.Text = _errorInfo.StackTrace;
            }

            // Show exception type if available
            if (_errorInfo.Exception != null)
            {
                ExceptionTypeSection.Visibility = Visibility.Visible;
                ExceptionType.Text = _errorInfo.Exception.GetType().FullName ?? "Unknown";
            }
        }

        private void ToggleStackTrace_Click(object sender, RoutedEventArgs e)
        {
            _isStackTraceVisible = !_isStackTraceVisible;
            
            if (_isStackTraceVisible)
            {
                StackTraceContent.Visibility = Visibility.Visible;
                ToggleStackTraceButton.Content = "Hide";
            }
            else
            {
                StackTraceContent.Visibility = Visibility.Collapsed;
                ToggleStackTraceButton.Content = "Show";
            }
        }

        private void Copy_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var formattedError = _errorInfo.GetFormattedError();
                Clipboard.SetText(formattedError);
                
                // Visual feedback
                CopyButton.Content = new System.Windows.Controls.StackPanel
                {
                    Orientation = System.Windows.Controls.Orientation.Horizontal,
                    Children =
                    {
                        new MaterialDesignThemes.Wpf.PackIcon
                        {
                            Kind = MaterialDesignThemes.Wpf.PackIconKind.Check,
                            VerticalAlignment = VerticalAlignment.Center,
                            Margin = new Thickness(0, 0, 8, 0)
                        },
                        new System.Windows.Controls.TextBlock
                        {
                            Text = "Copied!",
                            VerticalAlignment = VerticalAlignment.Center
                        }
                    }
                };

                // Reset button after 2 seconds
                var timer = new System.Windows.Threading.DispatcherTimer
                {
                    Interval = System.TimeSpan.FromSeconds(2)
                };
                timer.Tick += (s, args) =>
                {
                    timer.Stop();
                    CopyButton.Content = new System.Windows.Controls.StackPanel
                    {
                        Orientation = System.Windows.Controls.Orientation.Horizontal,
                        Children =
                        {
                            new MaterialDesignThemes.Wpf.PackIcon
                            {
                                Kind = MaterialDesignThemes.Wpf.PackIconKind.ContentCopy,
                                VerticalAlignment = VerticalAlignment.Center,
                                Margin = new Thickness(0, 0, 8, 0)
                            },
                            new System.Windows.Controls.TextBlock
                            {
                                Text = "Copy Error",
                                VerticalAlignment = VerticalAlignment.Center
                            }
                        }
                    };
                };
                timer.Start();
            }
            catch (System.Exception ex)
            {
                MessageBox.Show(
                    $"Failed to copy to clipboard: {ex.Message}",
                    "Copy Failed",
                    MessageBoxButton.OK,
                    MessageBoxImage.Warning
                );
            }
        }

        private void ViewLog_Click(object sender, RoutedEventArgs e)
        {
            ErrorHandler.OpenErrorLog();
        }

        private void Close_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}
