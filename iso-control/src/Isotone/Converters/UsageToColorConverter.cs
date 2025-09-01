using System;
using System.Globalization;
using System.Windows.Data;
using System.Windows.Media;

namespace Isotone.Converters
{
    public class UsageToColorConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is double usage)
            {
                // Create gradient brush with smooth color transitions
                var gradientBrush = new LinearGradientBrush();
                gradientBrush.StartPoint = new System.Windows.Point(0, 0);
                gradientBrush.EndPoint = new System.Windows.Point(1, 0);
                
                if (usage > 90)
                {
                    // Critical - Red with pulsing glow
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0xD3, 0x2F, 0x2F), 0.0)); // #D32F2F
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0xEF, 0x53, 0x50), 0.5)); // #EF5350
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0xB7, 0x1C, 0x1C), 1.0)); // #B71C1C
                }
                else if (usage > 80)
                {
                    // Warning - Orange to red gradient
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0xFF, 0x6F, 0x00), 0.0)); // #FF6F00
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0xFF, 0x98, 0x00), 0.5)); // #FF9800
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0xEF, 0x6C, 0x00), 1.0)); // #EF6C00
                }
                else if (usage > 60)
                {
                    // Moderate - Yellow to orange gradient
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0xFF, 0xD5, 0x4F), 0.0)); // #FFD54F
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0xFF, 0xCA, 0x28), 0.5)); // #FFCA28
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0xFF, 0xB3, 0x00), 1.0)); // #FFB300
                }
                else if (usage > 40)
                {
                    // Normal - Cyan gradient
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0x00, 0xE5, 0xFF), 0.0)); // #00E5FF
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0x22, 0xD3, 0xEE), 0.5)); // #22D3EE
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0x00, 0xB8, 0xD4), 1.0)); // #00B8D4
                }
                else
                {
                    // Low usage - Green gradient
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0x66, 0xBB, 0x6A), 0.0)); // #66BB6A
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0x4C, 0xAF, 0x50), 0.5)); // #4CAF50
                    gradientBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0x2E, 0x7D, 0x32), 1.0)); // #2E7D32
                }
                
                // Add subtle animation to the gradient
                gradientBrush.GradientStops[1].Offset = 0.3 + (usage / 100.0 * 0.4); // Dynamic middle point
                
                return gradientBrush;
            }
            
            // Default cyan gradient
            var defaultBrush = new LinearGradientBrush();
            defaultBrush.StartPoint = new System.Windows.Point(0, 0);
            defaultBrush.EndPoint = new System.Windows.Point(1, 0);
            defaultBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0x00, 0xE5, 0xFF), 0.0));
            defaultBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0x22, 0xD3, 0xEE), 0.5));
            defaultBrush.GradientStops.Add(new GradientStop(Color.FromRgb(0x00, 0xB8, 0xD4), 1.0));
            return defaultBrush;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}