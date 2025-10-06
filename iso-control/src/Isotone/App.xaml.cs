using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Threading;

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
                // Let splash animate for a bit
                await Task.Delay(1500);
                
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
            var message = exception?.Message ?? "An unknown error occurred.";
            MessageBox.Show(
                $"An error occurred:\n\n{message}\n\nThe application will continue running.", 
                "IsotoneStack Error", 
                MessageBoxButton.OK, 
                MessageBoxImage.Error);
        }
    }
}