using System;
using System.Windows;

namespace Isotone
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            
            // Set up any global exception handling
            AppDomain.CurrentDomain.UnhandledException += OnUnhandledException;
            DispatcherUnhandledException += OnDispatcherUnhandledException;
        }

        private void OnUnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            var exception = e.ExceptionObject as Exception;
            ShowErrorDialog(exception);
        }

        private void OnDispatcherUnhandledException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
        {
            ShowErrorDialog(e.Exception);
            e.Handled = true;
        }

        private void ShowErrorDialog(Exception? exception)
        {
            var message = exception?.Message ?? "An unknown error occurred.";
            MessageBox.Show(
                $"An error occurred:\n\n{message}\n\nThe application will continue running.", 
                "IsotoneStack Error", 
                MessageBoxButton.OK, 
                MessageBoxImage.Error);
        }
    }
}