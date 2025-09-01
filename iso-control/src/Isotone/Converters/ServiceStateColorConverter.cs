using System;
using System.Globalization;
using System.Windows.Data;
using System.Windows.Media;

namespace Isotone.Converters
{
    public class ServiceStateColorConverter : IValueConverter
    {
        private static ServiceStateColorConverter _instance;
        public static ServiceStateColorConverter Instance => _instance ??= new ServiceStateColorConverter();

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is string state)
            {
                return state switch
                {
                    "Running" => new SolidColorBrush(Color.FromRgb(76, 175, 80)),  // Green
                    "Stopped" => new SolidColorBrush(Color.FromRgb(158, 158, 158)), // Gray
                    "Starting" => new SolidColorBrush(Color.FromRgb(255, 193, 7)), // Amber
                    "Stopping" => new SolidColorBrush(Color.FromRgb(255, 152, 0)), // Orange
                    "Restarting" => new SolidColorBrush(Color.FromRgb(3, 169, 244)), // Light Blue
                    "Error" => new SolidColorBrush(Color.FromRgb(244, 67, 54)), // Red
                    _ => new SolidColorBrush(Color.FromRgb(158, 158, 158)) // Gray
                };
            }
            return new SolidColorBrush(Colors.Gray);
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}