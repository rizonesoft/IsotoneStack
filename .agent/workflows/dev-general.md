---
description: General development workflow with rules and auto-commit
---

# IsotoneStack Development Workflow

Use this workflow for any development task in the IsotoneStack project.

## Pre-Task Checklist

Before starting any task, verify:
1. You are NOT working in the `www/` folder (user content - completely ignore)
2. You know which type of file you're creating (PowerShell, Batch, C#, Config)

## Critical Rules Summary

### PowerShell Scripts (.ps1)
- Place in `.\scripts\` folder
- Use `.\scripts\_Template.ps1` as base
- Create matching `.bat` launcher using `.\scripts\_Template.ps1.bat`
- Use `$PSScriptRoot` for paths, never hardcode
- ASCII only: [OK], [WARNING], [ERROR] - no Unicode symbols
- Log to `logs\isotone\` with timestamps

### Batch Files (.bat)
// turbo
- Simple launchers only - no complex logic
- Self-elevate if admin needed:
```batch
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)
```

### C# iso-control
- Location: `.\iso-control\` (WPF, .NET 9)
- MVVM pattern: ViewModels/, Views/, Services/, Utilities/
- Use MaterialDesignInXAML and CommunityToolkit.Mvvm

### Apache Configuration
- NEVER add `<FilesMatch>`, `SetHandler`, or `DirectoryIndex` in Directory blocks
- Keep alias configs minimal: Alias + Directory with Options/AllowOverride/Require only

### MariaDB Configuration
- Multi-version: 10.11.15, 11.8.5, 12.1.2
- Data directories: `mariadb\data\{major.minor}\`
- Use utf8mb4_unicode_ci collation (NOT utf8mb4_uca1400_ai_ci)

## Task Execution

// turbo
1. Complete the requested task following the rules above

// turbo
2. Verify the changes work correctly (build, run tests if applicable)

## Post-Task: Commit and Push

After completing the task successfully:

// turbo
3. Stage all changed files:
```bash
git add -A
```

// turbo
4. Commit with a descriptive message:
```bash
git commit -m "<type>: <description>"
```

Commit types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style/formatting
- `refactor`: Code refactoring
- `chore`: Maintenance tasks
- `scripts`: PowerShell/Batch script changes

// turbo
5. Push to remote:
```bash
git push
```

## Excluded from Git

These are automatically excluded (defined in .gitignore):
- `www/` - User content
- `apache24/`, `mariadb/`, `php/`, `pwsh/` - Bundled components
- `logs/`, `tmp/`, `backups/` - Runtime data
- `.vs/`, `bin/`, `obj/` - Build artifacts
