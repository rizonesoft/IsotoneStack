---
description: MariaDB multi-version migration and management workflow
---

# MariaDB Migration Workflow

Use this workflow when working on MariaDB multi-version setup and migration.

## Target Structure

```
mariadb/
├── 10.11.15/          ← LTS - Production compatible (DEFAULT)
│   ├── bin/
│   ├── lib/
│   └── share/
├── 11.8.5/            ← Current stable branch
├── 12.1.2/            ← Latest (upgraded from 12.0.2)
├── data/
│   ├── 10.11/         ← Version-specific data (migrated)
│   ├── 11.8/          ← Version-specific data
│   └── 12.0/          ← Original 12.0.2 data (preserved)
└── my.ini             ← Active configuration
```

## Current Migration Phases (from TODO-MDB1011.md)

### Phase 1: Pre-Migration Backup
- Full SQL export with `mariadb-dump`
- Structure-only export
- Data directory backup

### Phase 2: Collation Compatibility
- Convert `utf8mb4_uca1400_ai_ci` → `utf8mb4_unicode_ci`
- Critical for 10.11 compatibility

### Phase 3: Multi-Version Setup
- Download: 10.11.15, 11.8.5, 12.1.2
- Preserve 12.0.2 data in `data\12.0\`
- Create version-specific my.ini files

### Phase 4: Initialize and Import
- Initialize 10.11.15 data directory
- Import databases from backup

### Phase 8: Version Switching Script
- Create `Switch-MariaDBVersion.ps1`
- Create `Switch-MariaDBVersion.bat` launcher

## Critical Rules

### Collation
- **ALWAYS use:** `utf8mb4_unicode_ci`
- **NEVER use:** `utf8mb4_uca1400_ai_ci` (MariaDB 12+ only, breaks compatibility)

### Data Directory Isolation
- Each major.minor version has its own data directory
- NEVER share data directories between incompatible versions
- Format: `mariadb\data\{major.minor}\`

### Service Configuration
- Service name: `IsotoneMariaDB`
- Port: 3306 (default)
- Use NSSM or native service registration

## PowerShell Patterns

**Backup database:**
```powershell
$mariadbDump = Join-Path $IsotoneRoot "mariadb\12.0.2\bin\mariadb-dump.exe"
& $mariadbDump -u root --all-databases --routines --triggers > "backup.sql"
```

**Check service status:**
```powershell
$service = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq "Running") {
    Write-Log "MariaDB is running"
}
```

**Switch version pattern:**
```powershell
# 1. Stop service
Stop-Service -Name "IsotoneMariaDB" -Force

# 2. Update service path to new version
# 3. Update my.ini with correct basedir/datadir

# 4. Start service
Start-Service -Name "IsotoneMariaDB"
```

## Development Steps

// turbo
1. Ensure MariaDB service is stopped before major changes:
```powershell
net stop IsotoneMariaDB
```

2. Make your changes (scripts, configs, data migration)

3. Follow script template for new PowerShell scripts:
   - Use `.\scripts\_Template.ps1` as base
   - Create matching `.bat` launcher
   - Log to `logs\isotone\`

// turbo
4. Test the changes:
```powershell
net start IsotoneMariaDB
R:\isotone\mariadb\10.11.15\bin\mysql.exe -u root -e "SELECT VERSION();"
```

## Post-Task: Commit and Push

// turbo
5. Stage changes:
```bash
git add -A
```

// turbo
6. Commit with descriptive message:
```bash
git commit -m "feat(mariadb): <description>"
```

// turbo
7. Push to remote:
```bash
git push
```

## Important Reminders

- ALWAYS backup before any migration
- Test on all target versions (10.11, 11.8, 12.1)
- Preserve original 12.0.2 data - never delete
- Update TODO-MDB1011.md as phases complete
- Collation conversion must happen BEFORE importing to 10.11
