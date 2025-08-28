# IsotoneStack Development Setup

## Overview

IsotoneStack uses a split structure to keep the Git repository lightweight while maintaining full functionality for testing and development.

## Directory Structure

```
C:\isotone\                    # Git repository (scripts, configs, docs)
C:\isotone-components\         # Binary components (Apache, PHP, MariaDB, etc.)
```

## Initial Setup for Developers

1. **Clone the repository:**
   ```bash
   git clone https://github.com/rizonesoft/IsotoneStack.git C:\isotone
   ```

2. **Download components:**
   - Download the latest IsotoneStack release assets
   - Extract to `C:\isotone-components\`
   - You should have:
     - `C:\isotone-components\apache24\`
     - `C:\isotone-components\mariadb\`
     - `C:\isotone-components\php\`
     - `C:\isotone-components\phpmyadmin\`
     - `C:\isotone-components\pwsh\`
     - `C:\isotone-components\bin\`

3. **Run setup script (as Administrator):**
   ```bash
   cd C:\isotone\scripts
   .\Setup-Development.bat
   ```
   
   This creates symbolic links from the repository to the components folder.

## Working with the Development Environment

### Testing Changes

The symbolic links make the components appear to be in the repository folder, so all scripts work normally:

```bash
# Configure components
.\scripts\Configure-IsotoneStack.bat

# Register services
.\scripts\Register-Services.bat

# Start/stop services
.\scripts\Start-Services.bat
.\scripts\Stop-Services.bat
```

### Removing Symbolic Links

To clean up the repository (remove all symlinks):

```bash
.\scripts\Setup-Development.bat -Remove
```

### Using a Different Components Path

If you want to store components elsewhere:

```bash
.\scripts\Setup-Development.ps1 -ComponentsPath "D:\MyComponents"
```

## Why This Structure?

1. **Small Repository:** The Git repository stays under 10MB instead of 800MB+
2. **Fast Operations:** Git operations (clone, pull, push) are much faster
3. **Clean History:** Binary files don't bloat the Git history
4. **Easy Testing:** Symbolic links make everything work seamlessly
5. **No Git Warnings:** Avoids "too many changes" warnings in Git GUIs

## Troubleshooting

### "Too many changes detected" in Git GUI

This happens when binary components are directly in the repository folder instead of symlinked:

1. Move components to `C:\isotone-components\`
2. Run `Setup-Development.bat` to create symlinks

### Symbolic links not working

- Ensure you're running as Administrator
- Windows 10/11 Developer Mode can help with symlink permissions
- Check that target directories exist in `C:\isotone-components\`

### Scripts can't find components

- Verify symbolic links exist: `dir C:\isotone`
- Ensure components are in the correct location
- Re-run `Setup-Development.bat`

## Distribution

For end users, provide:

1. **Installer package** with everything bundled
2. **Separate downloads:**
   - Repository ZIP (scripts and configs)
   - Components ZIP (binaries)

End users don't need symbolic links - they extract everything to `C:\isotone\` directly.