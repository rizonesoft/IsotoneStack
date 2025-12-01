# PHP Configuration Template

## Overview

This folder contains the **master php.ini template** used for all PHP versions in IsotoneStack.

## File: `php.ini`

**Purpose:** Base configuration applied to all PHP versions (8.3.x, 8.4.x, 8.5.x, etc.)

**Location:** `R:\isotone\config\php\php.ini`

**Applied To:**
- `R:\isotone\php\8.3.28\php.ini`
- `R:\isotone\php\8.4.15\php.ini`
- `R:\isotone\php\8.5.0\php.ini`
- Any future PHP versions you add

## How It Works

### 1. During Configuration

When you run `Configure-IsotoneStack.ps1`:

```
For each PHP version:
  1. Read config\php\php.ini (this template)
  2. Replace {{INSTALL_PATH}} with actual path
  3. Replace extension_dir with version-specific path
  4. Write to php\<version>\php.ini
```

### 2. Template Variables

The following variables are automatically replaced:

| Variable | Replaced With | Example |
|----------|---------------|---------|
| `{{INSTALL_PATH}}` | IsotoneStack root path | `R:/isotone` |
| `{{INSTALL_PATH_BS}}` | Path with backslashes | `R:\isotone` |
| `extension_dir` | Version-specific ext folder | `R:\isotone\php\8.4.15\ext` |

### 3. Version-Specific Adjustments

**Only these values are version-specific:**
- `extension_dir` - Points to each version's ext\ folder
- Everything else remains the same across all versions

## Compatibility

### ✅ What's Compatible Across All PHP 8.x Versions

- **Core Settings:** memory_limit, max_execution_time, upload_max_filesize
- **Error Handling:** error_reporting, display_errors, log_errors
- **Extensions:** Standard extension loading syntax
- **Paths:** Session, upload, temp directories
- **Security:** disable_functions, open_basedir
- **Performance:** opcache settings, realpath_cache

### ⚠️ What to Avoid

- **Deprecated Directives:** Removed in newer PHP versions
- **Experimental Features:** Specific to one PHP version
- **Version-Specific Extensions:** Not available in all versions

### 📋 Recommended Extensions (All PHP 8.x)

These extensions are available in all PHP 8.x versions:

```ini
; File handling
extension=fileinfo
extension=zip

; Database
extension=mysqli
extension=pdo_mysql
extension=pdo_sqlite
extension=sqlite3

; String handling
extension=mbstring
extension=iconv

; Network
extension=curl
extension=openssl
extension=sockets

; Graphics
extension=gd
extension=exif

; Performance
extension=opcache

; Encryption
extension=sodium

; Other
extension=intl
extension=xml
extension=json
```

## Editing the Template

### Making Changes

1. **Edit:** `config\php\php.ini` (this file)
2. **Don't Edit:** `php\<version>\php.ini` directly (will be overwritten)
3. **Apply Changes:** Run `Configure-IsotoneStack.ps1` to regenerate

### Re-applying Template

To apply template changes to all PHP versions:

```powershell
cd R:\isotone\scripts
.\Configure-IsotoneStack.bat
```

This will:
- ✅ Keep existing php.ini if you have custom changes
- ✅ Only update if template is newer or you use `-Force`

**Force re-apply:**
```powershell
.\Configure-IsotoneStack.ps1 -Force
```

## Per-Version Customization

If you need different settings for specific PHP versions:

### Option 1: Edit After Configuration
```powershell
# Configure all versions first
.\Configure-IsotoneStack.bat

# Then customize specific versions
notepad R:\isotone\php\8.4.15\php.ini
```

### Option 2: Use iso-control
1. Launch iso-control
2. Navigate to PHP page
3. Select version
4. Enable/disable extensions
5. Click "Open php.ini" for advanced edits

## Common Scenarios

### Scenario 1: Same Settings for All Versions
✅ **Use this template** - Perfect for your use case
- Edit `config\php\php.ini`
- Run `Configure-IsotoneStack.ps1`
- All versions get same settings

### Scenario 2: Different Extensions Per Version
✅ **Use iso-control**
- Template creates base configuration
- Enable/disable extensions per version in iso-control
- Each version's php.ini tracks its own extensions

### Scenario 3: Version-Specific Settings
✅ **Manual edit after configuration**
- Run `Configure-IsotoneStack.ps1` to create base
- Edit specific version's php.ini manually
- Re-run config with `-Force` only when needed

## Best Practices

### 1. Keep Template Generic
- Use settings compatible with all PHP 8.x
- Don't include version-specific directives
- Test on lowest supported PHP version

### 2. Use Template Variables
```ini
; Good - uses variable
upload_tmp_dir = "{{INSTALL_PATH}}/tmp"

; Bad - hardcoded
upload_tmp_dir = "C:/isotone/tmp"
```

### 3. Document Custom Changes
Add comments in the template:
```ini
; IsotoneStack Default: Increased for large uploads
upload_max_filesize = 128M
post_max_size = 128M
```

### 4. Version Control Your Template
- Keep backups of `config\php\php.ini`
- Document why settings were changed
- Test after PHP version updates

## Troubleshooting

### Template Not Applied
**Problem:** Changes to template don't appear in php\<version>\php.ini

**Solution:**
```powershell
# Force re-apply template
cd R:\isotone\scripts
.\Configure-IsotoneStack.ps1 -Force
```

### Extension Not Available
**Problem:** Extension enabled in template but not loading

**Check:**
1. Does the extension exist in `php\<version>\ext\`?
2. Is it compatible with that PHP version?
3. Check PHP error log for loading issues

### Different Behavior Per Version
**Problem:** Same setting behaves differently in different PHP versions

**Reason:** PHP version differences (expected)

**Solution:** 
- Use version-specific php.ini edits
- Or disable problematic directives in template

## Summary

✅ **One template for all PHP versions** (your current approach)
✅ **Automatically applied** during configuration
✅ **Version-specific paths** handled automatically
✅ **Easy to maintain** - edit one file, apply to all
✅ **Per-version customization** available when needed

**Your `config\php\php.ini` is the single source of truth for PHP configuration across all versions!**
