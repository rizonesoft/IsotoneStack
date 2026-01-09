---
description: iso-control WPF Control Panel development workflow
---

# iso-control Development Workflow

Use this workflow when developing the iso-control WPF Control Panel application.

## Project Location
- Solution: `.\iso-control\Isotone.sln`
- Project: `.\iso-control\Isotone.csproj`
- Framework: .NET 9.0 Windows (net9.0-windows)
- UI: WPF with MaterialDesignInXAML

## Architecture (MVVM Pattern)

```
iso-control/
├── ViewModels/     - ObservableObject classes with [RelayCommand]
├── Views/          - XAML UserControls
├── Services/       - ServiceManager, ViewCache
├── Utilities/      - ConfigurationManager, ErrorHandler, PHPManager
├── Converters/     - IValueConverter implementations
├── Windows/        - Dialog windows
└── assets/         - Icons and resources
```

## Current Priority Tasks (from TODO-Control.md)

### Phase 1: Critical - Complete Stub Views
- `DatabaseViewModel.cs` - Only 15 lines, needs full implementation
- `LogsViewModel.cs` - Has placeholder content, needs real log loading

### Phase 2: MariaDB Multi-Version UI
- Add MariaDB version selector (like PHP version switching)
- Detect versions from `mariadb\{version}\bin\mariadbd.exe`

### Phase 3: Service Configuration Dialogs
- Replace "coming soon" messages with actual config dialogs
- Apache, MariaDB, Mailpit configuration windows

## Development Steps

// turbo
1. Open the solution and verify it builds:
```powershell
cd R:\isotone\iso-control
dotnet build
```

2. Make your changes following MVVM pattern:
   - ViewModel: Add `[ObservableProperty]` for bindable properties
   - ViewModel: Add `[RelayCommand]` for button actions
   - View: Bind to ViewModel properties with `{Binding PropertyName}`
   - Use `async` for long-running operations

3. Key patterns to follow:
```csharp
// ViewModel property
[ObservableProperty]
private string myProperty;

// ViewModel command
[RelayCommand]
private async Task DoSomethingAsync()
{
    try {
        // Implementation
        _snackbarMessageQueue.Enqueue("Success message");
    } catch (Exception ex) {
        ErrorHandler.HandleException(ex, "Context", "User message");
    }
}
```

// turbo
4. Build and verify no errors:
```powershell
dotnet build --configuration Release
```

// turbo
5. Run the application to test:
```powershell
dotnet run
```

## Post-Task: Commit and Push

// turbo
6. Stage changes:
```bash
git add -A
```

// turbo
7. Commit with descriptive message:
```bash
git commit -m "feat(iso-control): <description>"
```

// turbo
8. Push to remote:
```bash
git push
```

## Important Rules

- Use `ISnackbarMessageQueue` for user feedback
- Use `ErrorHandler.HandleException()` for error handling
- Inject dependencies via constructor (ServiceManager, ConfigurationManager)
- Service names: IsotoneApache, IsotoneMariaDB, IsotoneMailpit
- Dark theme is default - use MaterialDesign theme resources
