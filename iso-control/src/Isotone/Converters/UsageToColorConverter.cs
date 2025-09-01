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
                if (usage > 89)
                    return new SolidColorBrush(Color.FromRgb(0xB8, 0x1C, 0x1C)); // #B81C1C - Red
                else if (usage > 69)
                    return new SolidColorBrush(Color.FromRgb(0xFF, 0x98, 0x00)); // #FF9800 - Orange
                else
                    return new SolidColorBrush(Color.FromRgb(0x22, 0xD3, 0xEE)); // #22D3EE - Cyan
            }
            return new SolidColorBrush(Color.FromRgb(0x22, 0xD3, 0xEE)); // Default cyan
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}