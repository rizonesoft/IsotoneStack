using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Threading;
using Isotone.Utilities;

namespace Isotone
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        private Thread? _splashThread;
        private SplashScreen? _splashScreen;
        
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            
            // Set up any global exception handling
            AppDomain.CurrentDomain.UnhandledException += OnUnhandledException;
            DispatcherUnhandledException += OnDispatcherUnhandledException;
            
            // Create and show splash screen on separate thread
            ManualResetEvent splashShown = new ManualResetEvent(false);
            _splashThread = new Thread(() =>
            {
                _splashScreen = new SplashScreen();
                _splashScreen.Show();
                splashShown.Set();
                
                // Run dispatcher for this thread
                Dispatcher.Run();
            });
            _splashThread.SetApartmentState(ApartmentState.STA);
            _splashThread.Start();
            
            // Wait for splash to be shown
            splashShown.WaitOne();
            
            // Create main window after splash is showing
            Task.Run(async () =>
            {
                // Brief delay to ensure smooth splash display
                await Task.Delay(300);
                
                // Create main window on main UI thread
                await Dispatcher.InvokeAsync(() =>
                {
                    var mainWindow = new MainWindow();
                    mainWindow.DataContext = new ViewModels.MainViewModel();
                    MainWindow = mainWindow;
                    mainWindow.Show();
                    
                    // Close splash screen
                    CloseSplash();
                });
            });
        }
        
        private void CloseSplash()
        {
            if (_splashScreen != null && _splashThread != null)
            {
                _splashScreen.Dispatcher.InvokeAsync(async () =>
                {
                    await _splashScreen.CloseWithFadeOut();
                    _splashScreen.Dispatcher.InvokeShutdown();
                });
            }
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
            if (exception != null)
            {
                ErrorHandler.HandleException(
                    exception,
                    "Application",
                    "An unhandled error occurred in the application. The application will continue running."
                );
            }
            else
            {
                ErrorHandler.ShowError(
                    "Unknown Error",
                    "An unknown error occurred.",
                    "No exception information is available. The application will continue running."
                );
            }
        }
    }
}