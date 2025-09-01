using System;
using System.Globalization;
using System.Windows.Data;

namespace Isotone.Converters
{
    public class GreaterThanConverter : IValueConverter
    {
        private static GreaterThanConverter _instance;
        public static GreaterThanConverter Instance => _instance ??= new GreaterThanConverter();

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is double doubleValue && parameter is string paramString)
            {
                if (double.TryParse(paramString, out double threshold))
                {
                    return doubleValue > threshold;
                }
            }
            return false;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}