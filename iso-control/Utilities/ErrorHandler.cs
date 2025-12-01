using System;
using System.IO;
using System.Windows;

namespace Isotone.Utilities
{
    /// <summary>
    /// Centralized error handling system
    /// </summary>
    public static class ErrorHandler
    {
        private static readonly string ErrorLogPath;
        private static readonly object LogLock = new object();

        static ErrorHandler()
        {
            // Initialize error log path
            var appDataPath = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "IsotoneStack",
                "Logs"
            );

            Directory.CreateDirectory(appDataPath);
            ErrorLogPath = Path.Combine(appDataPath, "errors.log");
        }

        /// <summary>
        /// Handles an exception with detailed error dialog
        /// </summary>
        public static void HandleException(Exception exception, string? source = null, string? customMessage = null)
        {
            var errorInfo = ErrorInfo.FromException(exception, source, customMessage);
            ShowErrorDialog(errorInfo);
            LogError(errorInfo);
        }

        /// <summary>
        /// Shows an error with detailed error dialog
        /// </summary>
        public static void ShowError(string title, string message, string? details = null)
        {
            var errorInfo = ErrorInfo.CreateError(title, message, details);
            ShowErrorDialog(errorInfo);
            LogError(errorInfo);
        }

        /// <summary>
        /// Shows a warning with detailed dialog
        /// </summary>
        public static void ShowWarning(string title, string message, string? details = null)
        {
            var errorInfo = ErrorInfo.CreateWarning(title, message, details);
            ShowErrorDialog(errorInfo);
            LogError(errorInfo);
        }

        /// <summary>
        /// Shows a critical error with detailed dialog
        /// </summary>
        public static void ShowCritical(string title, string message, string? details = null)
        {
            var errorInfo = ErrorInfo.CreateCritical(title, message, details);
            ShowErrorDialog(errorInfo);
            LogError(errorInfo);
        }

        /// <summary>
        /// Logs error to file without showing dialog
        /// </summary>
        public static void LogError(ErrorInfo errorInfo)
        {
            try
            {
                lock (LogLock)
                {
                    File.AppendAllText(ErrorLogPath, errorInfo.GetFormattedError() + Environment.NewLine);
                }
            }
            catch
            {
                // Silently fail if logging fails
            }
        }

        /// <summary>
        /// Shows the error details dialog
        /// </summary>
        private static void ShowErrorDialog(ErrorInfo errorInfo)
        {
            try
            {
                Application.Current.Dispatcher.Invoke(() =>
                {
                    var errorWindow = new Windows.ErrorDetailsWindow(errorInfo);
                    errorWindow.ShowDialog();
                });
            }
            catch
            {
                // Fallback to simple message box if dialog fails
                MessageBox.Show(
                    errorInfo.Message,
                    errorInfo.Title,
                    MessageBoxButton.OK,
                    GetMessageBoxImage(errorInfo.Severity)
                );
            }
        }

        /// <summary>
        /// Gets the error log file path
        /// </summary>
        public static string GetErrorLogPath() => ErrorLogPath;

        /// <summary>
        /// Opens the error log file in default text editor
        /// </summary>
        public static void OpenErrorLog()
        {
            try
            {
                if (File.Exists(ErrorLogPath))
                {
                    System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                    {
                        FileName = ErrorLogPath,
                        UseShellExecute = true
                    });
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"Failed to open error log: {ex.Message}",
                    "Error",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error
                );
            }
        }

        /// <summary>
        /// Clears the error log file
        /// </summary>
        public static void ClearErrorLog()
        {
            try
            {
                lock (LogLock)
                {
                    if (File.Exists(ErrorLogPath))
                    {
                        File.Delete(ErrorLogPath);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"Failed to clear error log: {ex.Message}",
                    "Error",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error
                );
            }
        }

        private static MessageBoxImage GetMessageBoxImage(ErrorSeverity severity)
        {
            return severity switch
            {
                ErrorSeverity.Information => MessageBoxImage.Information,
                ErrorSeverity.Warning => MessageBoxImage.Warning,
                ErrorSeverity.Error => MessageBoxImage.Error,
                ErrorSeverity.Critical => MessageBoxImage.Error,
                _ => MessageBoxImage.Error
            };
        }
    }
}
