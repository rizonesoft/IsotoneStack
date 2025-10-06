using System;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Animation;
using System.Windows.Threading;

namespace Isotone
{
    public partial class SplashScreen : Window
    {
        private TextBlock? _loadingText;
        private readonly DispatcherTimer _messageTimer;
        private int _messageIndex = 0;
        private readonly string[] _loadingMessages = new[]
        {
            "Initializing services",
            "Loading configuration",
            "Checking Apache service",
            "Checking MariaDB service",
            "Checking Mailpit service",
            "Preparing dashboard",
            "Starting Control Panel"
        };

        public SplashScreen()
        {
            InitializeComponent();
            
            _loadingText = FindName("LoadingText") as TextBlock;
            
            // Setup timer to cycle through loading messages
            _messageTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(400)
            };
            _messageTimer.Tick += OnMessageTimerTick;
            _messageTimer.Start();
        }

        private void OnMessageTimerTick(object? sender, EventArgs e)
        {
            if (_loadingText != null && _messageIndex < _loadingMessages.Length)
            {
                _loadingText.Text = _loadingMessages[_messageIndex];
                _messageIndex++;
                
                // Add dots animation
                if (_messageIndex > 0)
                {
                    var text = _loadingText.Text;
                    _ = Task.Run(async () =>
                    {
                        for (int i = 0; i < 3; i++)
                        {
                            await Task.Delay(100);
                            await Dispatcher.InvokeAsync(() =>
                            {
                                if (_loadingText != null)
                                    _loadingText.Text = text + new string('.', i + 1);
                            });
                        }
                    });
                }
            }
            else
            {
                _messageTimer.Stop();
            }
        }

        public void ShowWithFadeIn()
        {
            Opacity = 0;
            Show();
            
            var fadeIn = new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(300));
            BeginAnimation(OpacityProperty, fadeIn);
        }

        public async Task CloseWithFadeOut()
        {
            _messageTimer.Stop();
            
            var fadeOut = new DoubleAnimation(1, 0, TimeSpan.FromMilliseconds(200));
            fadeOut.Completed += (s, e) => Close();
            BeginAnimation(OpacityProperty, fadeOut);
            
            await Task.Delay(200);
        }
        
        protected override void OnClosed(EventArgs e)
        {
            _messageTimer?.Stop();
            base.OnClosed(e);
        }
    }
}