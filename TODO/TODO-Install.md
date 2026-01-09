# 🔧 IsotoneStack Installer Improvements Plan

> **Status:** Pending  
> **Created:** January 2026  
> **Target File:** `R:\isotone\distribution\IsotoneStack.iss`  
> **Legend:** 🔥 = Critical | ⚠️ = Important | 💡 = Enhancement | 🧪 = Testing

---

## 📋 Overview

This document outlines improvements to the IsotoneStack InnoSetup installer based on a comprehensive analysis of the current implementation.

### Current Issues Identified
1. **Component Selection** - Users can currently deselect components, causing broken shortcuts and functionality
2. **Version Hardcoding** - Component versions are hardcoded in descriptions
3. **Missing Validation** - No pre-installation checks for port conflicts or existing installations
4. **Limited User Feedback** - Post-install validation could be more informative
5. **MariaDB Multi-Version** - Doesn't support the new multi-version MariaDB structure

---

## 🔥 Phase 1: Make All Components Mandatory (Critical)
*Goal: Prevent users from creating broken installations by deselecting required components.*

---

### 1.1 Remove Component Selection Entirely
- [ ] **1.1.1** 🔥 Change from selectable to fixed installation
    
    **Current (allows selection):**
    ```innosetup
    [Types]
    Name: "full"; Description: "Full installation (all components)"
    Name: "compact"; Description: "Compact installation (core only)"
    Name: "custom"; Description: "Custom installation"; Flags: iscustom
    ```
    
    **Proposed (single type):**
    ```innosetup
    [Types]
    Name: "full"; Description: "Complete installation"
    ```

- [ ] **1.1.2** 🔥 Mark ALL components as fixed (not removable)
    
    **Current:**
    ```innosetup
    Name: "tools"; Description: "Database Management Tools"; Types: full
    Name: "tools\phpmyadmin"; Description: "phpMyAdmin 5.2.2"; Types: full
    Name: "extras"; Description: "Extra Components"; Types: full
    Name: "extras\mailpit"; Description: "Mailpit 1.27.7"; Types: full
    ```
    
    **Proposed:**
    ```innosetup
    ; All components are now fixed - no user selection
    Name: "core"; Description: "Core Stack"; Types: full; Flags: fixed
    Name: "core\apache"; Description: "Apache Web Server"; Types: full; Flags: fixed
    Name: "core\php"; Description: "PHP Runtime"; Types: full; Flags: fixed
    Name: "core\mariadb"; Description: "MariaDB Database"; Types: full; Flags: fixed
    Name: "core\pwsh"; Description: "PowerShell 7"; Types: full; Flags: fixed
    Name: "core\bin"; Description: "System Utilities"; Types: full; Flags: fixed
    Name: "tools"; Description: "Database Tools"; Types: full; Flags: fixed
    Name: "tools\phpmyadmin"; Description: "phpMyAdmin"; Types: full; Flags: fixed
    Name: "tools\phpliteadmin"; Description: "phpLiteAdmin"; Types: full; Flags: fixed
    Name: "tools\adminer"; Description: "Adminer"; Types: full; Flags: fixed
    Name: "extras"; Description: "Extra Components"; Types: full; Flags: fixed
    Name: "extras\mailpit"; Description: "Mailpit"; Types: full; Flags: fixed
    Name: "extras\python"; Description: "Python Runtime"; Types: full; Flags: fixed
    Name: "extras\browser"; Description: "Chromium Browser"; Types: full; Flags: fixed
    Name: "controlpanel"; Description: "iso-control GUI"; Types: full; Flags: fixed
    ```

- [ ] **1.1.3** 💡 Alternative: Hide component selection page entirely
    ```innosetup
    [Setup]
    ; Add this line to skip the component selection page
    DisableWelcomePage=no
    DisableProgramGroupPage=yes
    ; Hide components page since everything is mandatory
    ```
    
    And in `[Code]`:
    ```pascal
    function ShouldSkipPage(PageID: Integer): Boolean;
    begin
      Result := False;
      // Skip the components selection page - everything is installed
      if PageID = wpSelectComponents then
        Result := True;
    end;
    ```

---

### 1.2 Update File Entries
- [ ] **1.2.1** Remove component conditions from mandatory files
    
    **Current (conditional):**
    ```innosetup
    Source: "{#ComponentsDir}\phpmyadmin\*"; ...; Components: tools\phpmyadmin
    Source: "{#ComponentsDir}\mailpit\*"; ...; Components: extras\mailpit
    ```
    
    **Proposed (unconditional):**
    ```innosetup
    ; All components are always installed
    Source: "{#ComponentsDir}\phpmyadmin\*"; DestDir: "{app}\phpmyadmin"; Flags: ignoreversion recursesubdirs createallsubdirs
    Source: "{#ComponentsDir}\mailpit\*"; DestDir: "{app}\mailpit"; Flags: ignoreversion recursesubdirs createallsubdirs
    ```

---

## ⚠️ Phase 2: Dynamic Version Detection (Important)
*Goal: Automatically detect and display component versions instead of hardcoding.*

---

### 2.1 Remove Hardcoded Versions from Descriptions
- [ ] **2.1.1** Update component descriptions to remove static versions
    
    **Current:**
    ```innosetup
    Name: "core\apache"; Description: "Apache Web Server 2.4.65"
    Name: "core\php"; Description: "PHP 8.4.11"
    Name: "core\mariadb"; Description: "MariaDB 12.0.2"
    Name: "tools\phpmyadmin"; Description: "phpMyAdmin 5.2.2"
    ```
    
    **Proposed:**
    ```innosetup
    Name: "core\apache"; Description: "Apache Web Server"
    Name: "core\php"; Description: "PHP Runtime (Multi-Version)"
    Name: "core\mariadb"; Description: "MariaDB Database (Multi-Version)"
    Name: "tools\phpmyadmin"; Description: "phpMyAdmin"
    ```

- [ ] **2.1.2** 💡 Add version detection in `[Code]` section (optional enhancement)
    ```pascal
    function GetApacheVersion(): String;
    var
      CmdOutput: TArrayOfString;
      ResultCode: Integer;
    begin
      Result := 'Unknown';
      // Could read from httpd.exe -v or version file
    end;
    ```

---

### 2.2 Update Version Define
- [ ] **2.2.1** Create version constants file
    ```innosetup
    ; Create R:\isotone\distribution\version.iss
    #define MyAppVersion "2.0.0"
    #define ApacheVersion "2.4.65"
    #define PhpVersions "8.3, 8.4, 8.5"
    #define MariaDBVersions "10.11, 11.8, 12.1"
    #define PhpMyAdminVersion "5.2.2"
    ```
    
- [ ] **2.2.2** Include in main script
    ```innosetup
    #include "version.iss"
    ```

---

## 💡 Phase 3: Pre-Installation Checks (Enhancement)
*Goal: Detect potential conflicts before installation begins.*

---

### 3.1 Port Conflict Detection
- [ ] **3.1.1** Add port checking in `InitializeSetup`
    ```pascal
    function IsPortInUse(Port: Integer): Boolean;
    var
      ResultCode: Integer;
      Output: String;
    begin
      Result := False;
      // Check if port 80 (Apache), 3306 (MariaDB) are in use
      if Exec('netstat', '-an | findstr :' + IntToStr(Port), '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      begin
        Result := (ResultCode = 0);
      end;
    end;
    
    function InitializeSetup(): Boolean;
    begin
      // Existing dependency checks...
      Dependency_AddVC2015To2022;
      Dependency_AddDotNet90Desktop;
      
      // New: Port conflict check
      if IsPortInUse(80) then
      begin
        if MsgBox('Port 80 is already in use (possibly by another web server).' + #13#10 +
                  'This may cause Apache to fail to start.' + #13#10#13#10 +
                  'Do you want to continue anyway?',
                  mbConfirmation, MB_YESNO) = IDNO then
        begin
          Result := False;
          Exit;
        end;
      end;
      
      if IsPortInUse(3306) then
      begin
        if MsgBox('Port 3306 is already in use (possibly by MySQL/MariaDB).' + #13#10 +
                  'This may cause MariaDB to fail to start.' + #13#10#13#10 +
                  'Do you want to continue anyway?',
                  mbConfirmation, MB_YESNO) = IDNO then
        begin
          Result := False;
          Exit;
        end;
      end;
      
      Result := True;
    end;
    ```

---

### 3.2 Existing Installation Detection
- [ ] **3.2.1** Check for XAMPP, WAMP, or other stacks
    ```pascal
    function CheckForConflictingStacks(): Boolean;
    var
      ConflictMsg: String;
    begin
      Result := True;
      ConflictMsg := '';
      
      // Check for XAMPP
      if DirExists('C:\xampp') or DirExists('D:\xampp') then
        ConflictMsg := ConflictMsg + '- XAMPP detected' + #13#10;
      
      // Check for WAMP
      if DirExists('C:\wamp') or DirExists('C:\wamp64') then
        ConflictMsg := ConflictMsg + '- WAMP detected' + #13#10;
      
      // Check for Laragon
      if DirExists('C:\laragon') then
        ConflictMsg := ConflictMsg + '- Laragon detected' + #13#10;
      
      if ConflictMsg <> '' then
      begin
        if MsgBox('The following development stacks were detected:' + #13#10 + 
                  ConflictMsg + #13#10 +
                  'These may conflict with IsotoneStack if running simultaneously.' + #13#10 +
                  'Make sure to stop their services before starting IsotoneStack.' + #13#10#13#10 +
                  'Continue installation?',
                  mbConfirmation, MB_YESNO) = IDNO then
        begin
          Result := False;
        end;
      end;
    end;
    ```

---

### 3.3 Disk Space Check Enhancement
- [ ] **3.3.1** Add realistic disk space requirement
    ```innosetup
    [Setup]
    ; Current components need approximately 2GB
    ExtraDiskSpaceRequired=2147483648
    ```

---

## 💡 Phase 4: MariaDB Multi-Version Support
*Goal: Update installer to support the new multi-version MariaDB structure.*

---

### 4.1 Update MariaDB Structure
- [ ] **4.1.1** Modify MariaDB source to support versioned structure
    ```innosetup
    ; Old structure:
    ; Source: "{#ComponentsDir}\mariadb\*"; DestDir: "{app}\mariadb"; ...
    
    ; New structure for multi-version:
    Source: "{#ComponentsDir}\mariadb\10.11.15\*"; DestDir: "{app}\mariadb\10.11.15"; Flags: ignoreversion recursesubdirs createallsubdirs
    Source: "{#ComponentsDir}\mariadb\11.8.5\*"; DestDir: "{app}\mariadb\11.8.5"; Flags: ignoreversion recursesubdirs createallsubdirs
    Source: "{#ComponentsDir}\mariadb\12.1.2\*"; DestDir: "{app}\mariadb\12.1.2"; Flags: ignoreversion recursesubdirs createallsubdirs
    ```

- [ ] **4.1.2** Create data directory structure
    ```innosetup
    [Dirs]
    ; MariaDB version-specific data directories
    Name: "{app}\mariadb\data"; Flags: uninsneveruninstall
    Name: "{app}\mariadb\data\10.11"; Flags: uninsneveruninstall
    Name: "{app}\mariadb\data\11.8"; Flags: uninsneveruninstall
    Name: "{app}\mariadb\data\12.1"; Flags: uninsneveruninstall
    ```

---

### 4.2 Add MariaDB Version Selection Page
- [ ] **4.2.1** Create wizard page for default MariaDB version (similar to PHP)
    ```pascal
    var
      MariaDBVersionPage: TInputOptionWizardPage;
      MariaDBVersions: TStringList;
      SelectedMariaDBVersion: String;
    
    procedure DetectMariaDBVersions();
    var
      FindRec: TFindRec;
      MariaDBPath: String;
    begin
      MariaDBVersions := TStringList.Create;
      MariaDBPath := ExpandConstant('{#ComponentsDir}\mariadb');
      
      if FindFirst(MariaDBPath + '\*', FindRec) then
      begin
        try
          repeat
            if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
            begin
              if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
              begin
                // Check if this folder contains mariadbd.exe
                if FileExists(MariaDBPath + '\' + FindRec.Name + '\bin\mariadbd.exe') then
                  MariaDBVersions.Add(FindRec.Name);
              end;
            end;
          until not FindNext(FindRec);
        finally
          FindClose(FindRec);
        end;
      end;
      
      MariaDBVersions.Sort;
    end;
    ```

---

## 💡 Phase 5: Post-Installation Improvements
*Goal: Better feedback and validation after installation.*

---

### 5.1 Installation Verification
- [ ] **5.1.1** Add post-install verification step
    ```pascal
    procedure CurStepChanged(CurStep: TSetupStep);
    var
      Errors: String;
    begin
      if CurStep = ssPostInstall then
      begin
        Errors := '';
        
        // Verify critical files exist
        if not FileExists(ExpandConstant('{app}\apache24\bin\httpd.exe')) then
          Errors := Errors + '- Apache binary missing' + #13#10;
        
        if not FileExists(ExpandConstant('{app}\mariadb\10.11.15\bin\mariadbd.exe')) then
          Errors := Errors + '- MariaDB 10.11.15 binary missing' + #13#10;
        
        if not FileExists(ExpandConstant('{app}\php\8.4.15\php.exe')) then
          Errors := Errors + '- PHP 8.4.15 binary missing' + #13#10;
        
        if not FileExists(ExpandConstant('{app}\iso-control\Isotone.exe')) then
          Errors := Errors + '- Control Panel binary missing' + #13#10;
        
        if Errors <> '' then
        begin
          MsgBox('Warning: Some components may not have installed correctly:' + #13#10#13#10 +
                 Errors + #13#10 +
                 'Please check the installation or try reinstalling.',
                 mbError, MB_OK);
        end;
        
        // Copy default files (existing code)
        if not FileExists(ExpandConstant('{app}\www\index.php')) then
        begin
          CopyFile(
            ExpandConstant('{app}\default\index.php'),
            ExpandConstant('{app}\www\index.php'),
            False
          );
        end;
      end;
    end;
    ```

---

### 5.2 First-Run Welcome
- [ ] **5.2.1** Add optional README display
    ```innosetup
    [Run]
    ; Show documentation after install
    Filename: "{app}\README.md"; Description: "View README documentation"; Flags: nowait postinstall skipifsilent shellexec unchecked
    ```

- [ ] **5.2.2** Add web browser launch option
    ```innosetup
    [Run]
    ; Open localhost in browser
    Filename: "http://localhost/"; Description: "Open localhost in browser"; Flags: nowait postinstall skipifsilent shellexec unchecked
    ```

---

## 💡 Phase 6: Build Process Improvements
*Goal: Enhance the build script for better automation.*

---

### 6.1 Update Build-Installer.bat
- [ ] **6.1.1** Add version extraction from source
    ```batch
    :: Extract version from script
    for /f "tokens=2 delims==" %%a in ('findstr /c:"#define MyAppVersion" IsotoneStack.iss') do (
        set "VERSION=%%~a"
        set "VERSION=!VERSION:~2,-1!"
    )
    echo [INFO] Building version: %VERSION%
    ```

- [ ] **6.1.2** Add build timestamp
    ```batch
    :: Add build date to output filename
    for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set "DT=%%a"
    set "BUILD_DATE=%DT:~0,8%"
    echo [INFO] Build date: %BUILD_DATE%
    ```

- [ ] **6.1.3** Add checksum generation
    ```batch
    :: Generate SHA256 checksum
    certutil -hashfile "%OUTPUT_FILE%" SHA256 > "%OUTPUT_FILE%.sha256"
    echo [OK] Checksum generated
    ```

---

### 6.2 Component Preparation
- [ ] **6.2.1** Create component update script
    - [ ] Script to download latest versions from official sources
    - [ ] Script to update `version.iss` with new versions
    - [ ] Script to validate component integrity

---

## 💡 Phase 7: Uninstallation Improvements
*Goal: Cleaner uninstallation with better user options.*

---

### 7.1 Data Preservation Options
- [ ] **7.1.1** Add uninstall dialog for data preservation
    ```pascal
    procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
    begin
      if CurUninstallStep = usUninstall then
      begin
        if MsgBox('Do you want to keep your data (databases, www files, configurations)?' + #13#10 +
                  'Click YES to keep data, NO to remove everything.',
                  mbConfirmation, MB_YESNO) = IDYES then
        begin
          // Data directories already have uninsneveruninstall flag
          // Just confirm to user
        end
        else
        begin
          // Remove data directories
          DelTree(ExpandConstant('{app}\www'), True, True, True);
          DelTree(ExpandConstant('{app}\mariadb\data'), True, True, True);
          DelTree(ExpandConstant('{app}\logs'), True, True, True);
        end;
      end;
    end;
    ```

---

### 7.2 Service Cleanup Enhancement
- [ ] **7.2.1** Add timeout for service stop
    ```innosetup
    [UninstallRun]
    ; Add timeout and force kill if needed
    Filename: "{cmd}"; Parameters: "/C taskkill /F /IM httpd.exe 2>nul"; Flags: runhidden; RunOnceId: "KillApache"
    Filename: "{cmd}"; Parameters: "/C taskkill /F /IM mariadbd.exe 2>nul"; Flags: runhidden; RunOnceId: "KillMariaDB"
    Filename: "{cmd}"; Parameters: "/C taskkill /F /IM mysqld.exe 2>nul"; Flags: runhidden; RunOnceId: "KillMySQL"
    Filename: "{cmd}"; Parameters: "/C taskkill /F /IM mailpit.exe 2>nul"; Flags: runhidden; RunOnceId: "KillMailpit"
    ; Then unregister services
    Filename: "{app}\pwsh\pwsh.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\Stop-Services.ps1"""; ...
    Filename: "{app}\pwsh\pwsh.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\Unregister-Services.ps1"""; ...
    ```

---

## 🔄 Progress Tracking

| Phase | Status | Priority | Notes |
|-------|--------|----------|-------|
| Phase 1: Make Components Mandatory | ⏳ Not Started | 🔥 Critical | Prevents broken installations |
| Phase 2: Dynamic Versions | ⏳ Not Started | ⚠️ Important | Reduces maintenance |
| Phase 3: Pre-Installation Checks | ⏳ Not Started | 💡 Enhancement | Better UX |
| Phase 4: MariaDB Multi-Version | ⏳ Not Started | ⚠️ Important | Sync with TODO-MDB1011 |
| Phase 5: Post-Installation | ⏳ Not Started | 💡 Enhancement | Better feedback |
| Phase 6: Build Process | ⏳ Not Started | 💡 Enhancement | Automation |
| Phase 7: Uninstallation | ⏳ Not Started | 💡 Enhancement | Clean removal |

---

## 📋 Quick Reference: Key Files

| File | Purpose |
|------|---------|
| `distribution/IsotoneStack.iss` | Main InnoSetup script |
| `distribution/Build-Installer.bat` | Build automation script |
| `distribution/InnoDependencyInstaller/CodeDependencies.iss` | Runtime dependency handling |
| `distribution/isotone-components/` | Source components directory |
| `distribution/output/` | Built installer output |

---

## 🔗 Dependencies

| Task | Depends On |
|------|------------|
| Phase 4 (MariaDB Multi-Version) | TODO-MDB1011.md completion |
| Phase 6 (Build Process) | All other phases |
| Phase 2 (Dynamic Versions) | Phase 4 for MariaDB |

---

> **Last Updated:** 2026-01-09  
> **Author:** IsotoneStack Team
