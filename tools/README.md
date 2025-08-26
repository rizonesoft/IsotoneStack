# IsotoneStack Tools

This folder contains all hash generation and verification utilities for IsotoneStack.

## Hash Tools Available

### 1. Verify-Hashes.bat
Interactive hash verification tool with menu system.
- Create hashes for downloaded files
- Verify files against known hashes  
- Check hash of any single file
- Generate hash manifests

### 2. Get-CDN-Hashes.bat
Generates SHA256 and MD5 hashes for files to be uploaded to the CDN.

**Usage from tools folder:**
```batch
cd tools
Get-CDN-Hashes.bat
```

This will scan:
- `..\bin\` for binaries (wget.exe, 7z.exe, 7z.dll)
- `..\downloads\` for archives (Apache, PHP, MariaDB, phpMyAdmin)

Output shows hashes that should be added to the official `hashes.txt` on the CDN.

### 3. Verify-CDN-Downloads.bat
Verifies downloaded files against known hashes configured in the script.

### 4. Get-IsotoneHashes.ps1
PowerShell hash tool with advanced features:
- Multiple hash algorithms (SHA256, MD5, SHA1, SHA384, SHA512)
- JSON output format
- Export reports
- Individual file checking

**Usage from tools folder:**
```powershell
cd tools
.\Get-IsotoneHashes.ps1 -Action Create    # Create hashes
.\Get-IsotoneHashes.ps1 -Action Verify    # Verify hashes
.\Get-IsotoneHashes.ps1 -Action Export    # Export report
```

## Shortcuts Available in Root

For convenience, shortcuts are provided in the root directory:

- **Verify-Hashes.bat** - Shortcut to tools\Verify-Hashes.bat
- **Get-Hashes.bat** - Menu to access all hash tools

## Directory Structure

```
C:\isotone\
├── bin\                    (binaries checked by tools)
├── downloads\              (archives checked by tools)
├── Verify-Hashes.bat       (shortcut)
├── Get-Hashes.bat          (menu shortcut)
└── tools\                  (this folder)
    ├── Get-CDN-Hashes.bat
    ├── Get-IsotoneHashes.ps1
    ├── Verify-CDN-Downloads.bat
    ├── Verify-Hashes.bat
    └── README.md
```

All tools automatically adjust paths to work from the `tools` folder, looking for files in the parent directory.