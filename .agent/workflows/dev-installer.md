---
description: InnoSetup installer development workflow
---

# Installer Development Workflow

Use this workflow when working on the IsotoneStack InnoSetup installer.

## Project Location
- Main script: `.\distribution\IsotoneStack.iss`
- Build script: `.\distribution\Build-Installer.bat`
- Dependencies: `.\distribution\InnoDependencyInstaller\CodeDependencies.iss`
- Components: `.\distribution\isotone-components\`
- Output: `.\distribution\output\`

## Current Priority Tasks (from TODO-Install.md)

### Phase 1: Critical - Make Components Mandatory
- Remove component selection (users break installs by deselecting)
- Mark all components as `fixed` or skip component page entirely
- Remove `Components:` conditions from [Files] section

### Phase 2: Dynamic Version Detection
- Remove hardcoded versions from component descriptions
- Create version.iss include file for centralized versioning

### Phase 3: Pre-Installation Checks
- Add port conflict detection (80, 3306)
- Check for XAMPP/WAMP/Laragon conflicts

### Phase 4: MariaDB Multi-Version
- Update to versioned directory structure
- Add MariaDB version selection page (like PHP)

## InnoSetup Key Sections

```innosetup
[Setup]        - Installer metadata and behavior
[Types]        - Installation types (full, compact, custom)
[Components]   - Selectable components (use Flags: fixed to lock)
[Tasks]        - Optional tasks (desktop icon, register services)
[Files]        - Files to install
[Dirs]         - Directories to create
[Icons]        - Start menu and desktop shortcuts
[Run]          - Post-install commands
[UninstallRun] - Pre-uninstall commands
[Code]         - Pascal Script for custom logic
```

## Development Steps

1. Edit the InnoSetup script following these patterns:

   **Making components mandatory:**
   ```innosetup
   [Components]
   Name: "core"; Description: "Core Stack"; Types: full; Flags: fixed
   
   ; Skip component page entirely:
   [Code]
   function ShouldSkipPage(PageID: Integer): Boolean;
   begin
     if PageID = wpSelectComponents then Result := True
     else Result := False;
   end;
   ```

   **Adding pre-install check:**
   ```pascal
   function InitializeSetup(): Boolean;
   begin
     // Port check, conflict detection, etc.
     Result := True;
   end;
   ```

// turbo
2. Build the installer:
```powershell
cd R:\isotone\distribution
.\Build-Installer.bat
```

3. Test the installer:
   - Run the generated `.exe` from `.\distribution\output\`
   - Verify all components install correctly
   - Test service registration
   - Test uninstallation

## Post-Task: Commit and Push

// turbo
4. Stage changes:
```bash
git add -A
```

// turbo
5. Commit with descriptive message:
```bash
git commit -m "feat(installer): <description>"
```

// turbo
6. Push to remote:
```bash
git push
```

## Important Rules

- All components should be installed (no optional deselection)
- Dependencies handled by InnoDependencyInstaller (VC++ 2015-2022, .NET 9)
- Use `{app}` for installation directory paths
- Use `{#SourceDir}` and `{#ComponentsDir}` for source paths
- Scripts run via `{app}\pwsh\pwsh.exe` with `-NoProfile -ExecutionPolicy Bypass`
- Admin privileges required (PrivilegesRequired=admin)
