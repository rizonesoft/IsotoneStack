using System;
using System.Text;

namespace Isotone.Utilities
{
    /// <summary>
    /// Represents detailed information about an error
    /// </summary>
    public class ErrorInfo
    {
        public string Title { get; set; } = "Error";
        public string Message { get; set; } = string.Empty;
        public string? Details { get; set; }
        public string? StackTrace { get; set; }
        public DateTime Timestamp { get; set; } = DateTime.Now;
        public string? Source { get; set; }
        public Exception? Exception { get; set; }
        public ErrorSeverity Severity { get; set; } = ErrorSeverity.Error;

        /// <summary>
        /// Gets a formatted string representation of the error
        /// </summary>
        public string GetFormattedError()
        {
            var sb = new StringBuilder();
            
            sb.AppendLine($"Error Report - {Timestamp:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine(new string('=', 60));
            sb.AppendLine();
            
            sb.AppendLine($"Title: {Title}");
            sb.AppendLine($"Severity: {Severity}");
            
            if (!string.IsNullOrEmpty(Source))
            {
                sb.AppendLine($"Source: {Source}");
            }
            
            sb.AppendLine();
            sb.AppendLine("Message:");
            sb.AppendLine(Message);
            
            if (!string.IsNullOrEmpty(Details))
            {
                sb.AppendLine();
                sb.AppendLine("Details:");
                sb.AppendLine(Details);
            }
            
            if (Exception != null)
            {
                sb.AppendLine();
                sb.AppendLine("Exception Type:");
                sb.AppendLine(Exception.GetType().FullName);
                
                if (Exception.InnerException != null)
                {
                    sb.AppendLine();
                    sb.AppendLine("Inner Exception:");
                    sb.AppendLine(Exception.InnerException.Message);
                }
            }
            
            if (!string.IsNullOrEmpty(StackTrace))
            {
                sb.AppendLine();
                sb.AppendLine("Stack Trace:");
                sb.AppendLine(StackTrace);
            }
            
            sb.AppendLine();
            sb.AppendLine(new string('=', 60));
            
            return sb.ToString();
        }

        /// <summary>
        /// Creates an ErrorInfo from an Exception
        /// </summary>
        public static ErrorInfo FromException(Exception exception, string? source = null, string? customMessage = null)
        {
            return new ErrorInfo
            {
                Title = "Application Error",
                Message = customMessage ?? exception.Message,
                Details = exception.InnerException?.Message,
                StackTrace = exception.StackTrace ?? string.Empty,
                Source = source ?? exception.Source,
                Exception = exception,
                Severity = ErrorSeverity.Error
            };
        }

        /// <summary>
        /// Creates a warning ErrorInfo
        /// </summary>
        public static ErrorInfo CreateWarning(string title, string message, string? details = null)
        {
            return new ErrorInfo
            {
                Title = title,
                Message = message,
                Details = details,
                Severity = ErrorSeverity.Warning
            };
        }

        /// <summary>
        /// Creates an error ErrorInfo
        /// </summary>
        public static ErrorInfo CreateError(string title, string message, string? details = null)
        {
            return new ErrorInfo
            {
                Title = title,
                Message = message,
                Details = details,
                Severity = ErrorSeverity.Error
            };
        }

        /// <summary>
        /// Creates a critical ErrorInfo
        /// </summary>
        public static ErrorInfo CreateCritical(string title, string message, string? details = null)
        {
            return new ErrorInfo
            {
                Title = title,
                Message = message,
                Details = details,
                Severity = ErrorSeverity.Critical
            };
        }
    }

    public enum ErrorSeverity
    {
        Information,
        Warning,
        Error,
        Critical
    }
}
