# Error Handling System

## Overview

iso-control now features a comprehensive error handling system that provides detailed error information, easy copying of error details, and centralized error logging.

## Features

### 1. **Detailed Error Dialog**
When an error occurs, a modern, user-friendly dialog displays:
- **Error Title** - Clear identification of the error
- **Timestamp** - When the error occurred
- **Error Message** - Primary error description
- **Additional Details** - Extra context about the error
- **Source** - Where the error originated
- **Exception Type** - Technical exception information
- **Stack Trace** - Full stack trace (collapsible for advanced users)

### 2. **Error Severity Levels**
Errors are categorized by severity:
- **Information** (Blue icon) - Informational messages
- **Warning** (Orange icon) - Warning messages
- **Error** (Red icon) - Standard errors
- **Critical** (Dark Red icon) - Critical system errors

### 3. **Copy to Clipboard**
- One-click copy of complete error details
- Formatted for easy sharing with support or developers
- Includes all error information in a structured format

### 4. **Error Logging**
- All errors are automatically logged to file
- Log location: `%LocalAppData%\IsotoneStack\Logs\errors.log`
- Persistent logging across application sessions
- Formatted with timestamps and full details

### 5. **Error Log Management**
Available in **Settings** > **Error Log Management**:
- **Open Error Log** - View errors in default text editor
- **Show Log Path** - Display the log file location
- **Clear Log** - Remove all logged errors (with confirmation)

## Usage

### For Developers

#### Basic Error Handling
```csharp
using Isotone.Utilities;

try
{
    // Your code here
}
catch (Exception ex)
{
    ErrorHandler.HandleException(ex, "ComponentName.MethodName", "Custom error message");
}
```

#### Show Custom Errors
```csharp
// Show an error
ErrorHandler.ShowError("Title", "Message", "Optional details");

// Show a warning
ErrorHandler.ShowWarning("Warning Title", "Warning message");

// Show a critical error
ErrorHandler.ShowCritical("Critical Error", "Critical message");
```

#### Log Errors Without Showing Dialog
```csharp
var errorInfo = ErrorInfo.FromException(exception);
ErrorHandler.LogError(errorInfo);
```

#### Create Custom ErrorInfo
```csharp
var errorInfo = new ErrorInfo
{
    Title = "Custom Error",
    Message = "Something went wrong",
    Details = "Additional details here",
    Severity = ErrorSeverity.Error,
    Source = "MyComponent"
};
ErrorHandler.ShowErrorDialog(errorInfo);
```

### For Users

#### Viewing Error Details
1. When an error occurs, the error dialog appears automatically
2. Review the error message and details
3. Expand "Stack Trace" section for technical details (if needed)
4. Click "Copy Error" to copy full error details to clipboard
5. Click "View Error Log" to open the complete error log file

#### Managing Error Logs
1. Navigate to **Settings**
2. Scroll to **Error Log Management** section
3. Use the available buttons:
   - **Open Error Log** - View all logged errors
   - **Show Log Path** - See where errors are stored
   - **Clear Log** - Remove all logged errors

#### Sharing Error Information
When reporting issues:
1. Click "Copy Error" in the error dialog
2. Paste into email, issue tracker, or support ticket
3. Or open the error log file and copy relevant sections

## Error Log Format

```
Error Report - 2024-11-24 19:00:00
============================================================

Title: Application Error
Severity: Error
Source: PhpViewModel.LoadPhpVersions

Message:
Failed to load PHP versions

Details:
Could not access directory: R:\isotone\php

Exception Type:
System.IO.DirectoryNotFoundException

Inner Exception:
Access to the path is denied.

Stack Trace:
   at Isotone.ViewModels.PhpViewModel.LoadPhpVersions()
   at Isotone.ViewModels.PhpViewModel..ctor()
   ...

============================================================
```

## Global Exception Handling

The application automatically catches and logs:
- **Unhandled Exceptions** - Any exception not caught by try-catch blocks
- **Dispatcher Exceptions** - UI thread exceptions
- **Application Domain Exceptions** - Domain-level exceptions

All are logged and displayed to the user with full details.

## Best Practices

### For Developers

1. **Always use ErrorHandler** instead of generic MessageBox for errors
2. **Provide context** - Include component/method name in the source parameter
3. **Add helpful messages** - Customize the error message for better UX
4. **Log important operations** - Even if they don't throw exceptions
5. **Use appropriate severity** - Match the error level to the issue

### For Users

1. **Don't ignore errors** - Read the error message carefully
2. **Copy error details** when reporting issues
3. **Check error logs** for patterns if issues recur
4. **Clear logs periodically** to keep file size manageable

## Architecture

### Components

- **ErrorInfo.cs** - Error data model with severity levels
- **ErrorHandler.cs** - Central error handling and logging
- **ErrorDetailsWindow.xaml** - Error display UI
- **App.xaml.cs** - Global exception hooks
- **ViewModels** - Use ErrorHandler for local error handling

### Error Flow

```
Exception Occurs
    ↓
ErrorHandler.HandleException()
    ↓
├─→ ErrorInfo Created
├─→ Error Logged to File
└─→ ErrorDetailsWindow Displayed
    ↓
User Can:
├─→ View Details
├─→ Copy Error
└─→ View Error Log
```

## Troubleshooting

### Error Log Not Opening
- Check if default text editor is configured
- Verify log path exists: `%LocalAppData%\IsotoneStack\Logs\`
- Try "Show Log Path" to manually navigate to file

### Error Dialog Not Showing
- Check if application has proper UI thread access
- Verify ErrorDetailsWindow.xaml is properly compiled
- Look for exceptions in Windows Event Viewer

### Log File Growing Too Large
- Use "Clear Log" in Settings regularly
- Consider implementing automatic log rotation (future enhancement)

## Future Enhancements

Potential improvements:
- [ ] Automatic log rotation (by size or date)
- [ ] Error reporting to server (opt-in)
- [ ] Export errors to JSON/CSV
- [ ] Search/filter errors in log viewer
- [ ] Email error reports directly from dialog
- [ ] Error statistics and trends
