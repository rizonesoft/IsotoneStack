using System;
using System.Globalization;
using System.Windows.Data;

namespace Isotone.Converters
{
    public class UptimeConverter : IValueConverter
    {
        private static UptimeConverter _instance;
        public static UptimeConverter Instance => _instance ??= new UptimeConverter();

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is TimeSpan uptime)
            {
                if (uptime.TotalDays >= 1)
                {
                    return $"{(int)uptime.TotalDays}d {uptime.Hours}h {uptime.Minutes}m";
                }
                else if (uptime.TotalHours >= 1)
                {
                    return $"{uptime.Hours}h {uptime.Minutes}m";
                }
                else if (uptime.TotalMinutes >= 1)
                {
                    return $"{uptime.Minutes}m {uptime.Seconds}s";
                }
                else
                {
                    return $"{uptime.Seconds}s";
                }
            }
            return "—";
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}