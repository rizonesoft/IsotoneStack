# 📦 MariaDB Migration & Multi-Version Setup Plan

> **Status:** Pending  
> **Created:** January 2026  
> **Primary Target:** MariaDB 10.11.15 LTS (default for production compatibility)  
> **Legend:** 🔥 = Critical | ⚠️ = Important | 💡 = Enhancement | 🧪 = Validation

---

## 📋 Overview

This document outlines the actionable steps to:
1. **Migrate databases** from MariaDB 12.0.2 to MariaDB 10.11.15 LTS
2. **Set up multi-version support** allowing users to switch between MariaDB versions
3. **Preserve the existing 12.0.2 installation** as a versioned option

### Current Environment
- **MariaDB Version:** 12.0.2
- **Installation Path:** `R:\isotone\mariadb`
- **Data Directory:** `R:\isotone\mariadb\data`
- **Databases to Migrate:**
  - `asite_db`
  - `gluonwp_db`
  - `isotone_db`
  - `rizonesoft_db`
  - `securebin_db`
  - `systific_db`
  - `phpmyadmin`
  - `mysql` (system)
  - `performance_schema` (system)
  - `sys` (system)

### Target Multi-Version Structure
```
mariadb/
├── 10.11.15/          ← LTS - Production compatible (DEFAULT)
│   ├── bin/
│   ├── lib/
│   ├── share/
│   └── include/
├── 11.8.5/            ← Current stable branch
│   ├── bin/
│   └── ...
├── 12.1.2/            ← Latest (upgraded from 12.0.2)
│   ├── bin/
│   └── ...
├── data/
│   ├── 10.11/         ← Version-specific data (migrated)
│   ├── 11.8/          ← Version-specific data
│   └── 12.0/          ← Original 12.0.2 data (preserved)
└── my.ini             ← Active configuration (dynamically generated)
```

### Known Compatibility Challenges
- 🔥 **Collation Differences:** MariaDB 12 introduces `utf8mb4_uca1400_ai_ci` (not supported in 10.11)
- ⚠️ **Stored Procedures:** Syntax changes may exist between versions
- ⚠️ **System Tables:** `mysql` database structure differs between versions
- 💡 **Data Isolation:** Each version uses its own data directory to prevent corruption

---

## 🛡️ Phase 1: Pre-Migration Backup (🔥 Critical)
*Goal: Create complete, verified backups before any changes.*

---

### 1.1 Full Database Backup
- [ ] **1.1.1** 🔥 Stop all applications using MariaDB
    - [ ] Close phpMyAdmin, Adminer, and any web applications
    - [ ] Verify no active connections: `SHOW PROCESSLIST;`
- [ ] **1.1.2** 🔥 Create timestamped backup directory
    - [ ] Create: `R:\isotone\backups\mariadb-12.0.2-full-YYYYMMDD`
- [ ] **1.1.3** 🔥 Export each database with full structure and data
    ```powershell
    # For each user database (NOT mysql, performance_schema, sys)
    .\mariadb-dump.exe -u root -p --routines --triggers --events --single-transaction --quick "DATABASE_NAME" > "R:\isotone\backups\mariadb-12.0.2-full-YYYYMMDD\DATABASE_NAME.sql"
    ```
    - [ ] `asite_db.sql`
    - [ ] `gluonwp_db.sql`
    - [ ] `isotone_db.sql`
    - [ ] `rizonesoft_db.sql`
    - [ ] `securebin_db.sql`
    - [ ] `systific_db.sql`
    - [ ] `phpmyadmin.sql`
- [ ] **1.1.4** Verify each SQL file is non-empty
    - [ ] Check file sizes are reasonable (not 0 bytes)
    - [ ] Open each file to verify valid SQL structure

---

### 1.2 Structure-Only Backup
- [ ] **1.2.1** Create structure-only exports for schema verification
    ```powershell
    .\mariadb-dump.exe -u root -p --routines --triggers --events --no-data "DATABASE_NAME" > "R:\isotone\backups\mariadb-12.0.2-full-YYYYMMDD\DATABASE_NAME_structure.sql"
    ```
    - [ ] `systific_db_structure.sql`
    - [ ] `asite_db_structure.sql` (if has procedures)
- [ ] **1.2.2** Document stored procedure inventory
    ```sql
    SELECT ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE 
    FROM information_schema.ROUTINES 
    WHERE ROUTINE_SCHEMA NOT IN ('mysql', 'performance_schema', 'sys');
    ```
    - [ ] Save results to: `procedure_inventory.txt`
- [ ] **1.2.3** Document view inventory
    ```sql
    SELECT TABLE_SCHEMA, TABLE_NAME 
    FROM information_schema.VIEWS 
    WHERE TABLE_SCHEMA NOT IN ('mysql', 'performance_schema', 'sys');
    ```
    - [ ] Save results to: `view_inventory.txt`
- [ ] **1.2.4** Document trigger inventory
    ```sql
    SELECT TRIGGER_SCHEMA, TRIGGER_NAME, EVENT_OBJECT_TABLE 
    FROM information_schema.TRIGGERS 
    WHERE TRIGGER_SCHEMA NOT IN ('mysql', 'performance_schema', 'sys');
    ```
    - [ ] Save results to: `trigger_inventory.txt`

---

### 1.3 Backup Data Directory
- [ ] **1.3.1** 🔥 Stop MariaDB service completely
    ```powershell
    .\Stop-Services.ps1
    # Or: net stop IsotoneMariaDB
    ```
- [ ] **1.3.2** 🔥 Copy entire data directory
    ```powershell
    Copy-Item -Path "R:\isotone\mariadb\data" -Destination "R:\isotone\backups\mariadb-12.0.2-full-YYYYMMDD\data-raw" -Recurse
    ```
- [ ] **1.3.3** Verify copy integrity
    - [ ] Compare folder sizes
    - [ ] Verify all `.frm`, `.ibd`, and aria files copied

---

## 🔧 Phase 2: Collation Compatibility Fixes (⚠️ Important)
*Goal: Convert MariaDB 12-specific collations to 10.11-compatible ones BEFORE exporting.*

---

### 2.1 Identify Incompatible Collations
- [ ] **2.1.1** Start MariaDB 12.0.2 service
- [ ] **2.1.2** Run collation audit
    ```sql
    SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_COLLATION 
    FROM information_schema.TABLES 
    WHERE TABLE_COLLATION LIKE '%uca1400%';
    ```
    - [ ] Document all tables using `utf8mb4_uca1400_ai_ci`
- [ ] **2.1.3** Check default database collations
    ```sql
    SELECT SCHEMA_NAME, DEFAULT_COLLATION_NAME 
    FROM information_schema.SCHEMATA;
    ```

---

### 2.2 Convert Collations to 10.11-Compatible
- [ ] **2.2.1** ⚠️ Generate ALTER TABLE statements for each affected table
    ```sql
    -- For each table with uca1400 collation:
    ALTER TABLE `database_name`.`table_name` 
    CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    ```
- [ ] **2.2.2** Execute collation conversions
    - [ ] `systific_db` tables (known: ~35 tables)
    - [ ] Other databases as identified
- [ ] **2.2.3** Verify conversions
    ```sql
    SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_COLLATION 
    FROM information_schema.TABLES 
    WHERE TABLE_COLLATION LIKE '%uca1400%';
    ```
    - [ ] Result should return 0 rows

---

### 2.3 Re-Export After Collation Fix
- [ ] **2.3.1** 🔥 Create new exports with fixed collations
    ```powershell
    .\mariadb-dump.exe -u root -p --routines --triggers --events --single-transaction --quick "DATABASE_NAME" > "R:\isotone\backups\mariadb-migration-ready\DATABASE_NAME.sql"
    ```
    - [ ] All 7 user databases
- [ ] **2.3.2** 🧪 Validate SQL files for uca1400 references
    ```powershell
    Select-String -Path "R:\isotone\backups\mariadb-migration-ready\*.sql" -Pattern "uca1400"
    ```
    - [ ] Should return no matches

---

## 📥 Phase 3: Multi-Version Directory Setup
*Goal: Set up versioned directory structure and download all MariaDB versions.*

---

### 3.1 Download All MariaDB Versions
- [ ] **3.1.1** Visit MariaDB downloads: https://mariadb.org/download/
- [ ] **3.1.2** Download MariaDB **10.11.15** (LTS - Primary Target)
    - [ ] Select: **Windows x86_64**
    - [ ] Package: **ZIP file** (portable, no installer)
    - [ ] Save to: `R:\isotone\downloads\mariadb-10.11.15-winx64.zip`
- [ ] **3.1.3** Download MariaDB **11.8.5** (Current Stable)
    - [ ] Select: **Windows x86_64**
    - [ ] Package: **ZIP file**
    - [ ] Save to: `R:\isotone\downloads\mariadb-11.8.5-winx64.zip`
- [ ] **3.1.4** Download MariaDB **12.1.2** (Latest)
    - [ ] Select: **Windows x86_64**
    - [ ] Package: **ZIP file**
    - [ ] Save to: `R:\isotone\downloads\mariadb-12.1.2-winx64.zip`

---

### 3.2 Create Multi-Version Directory Structure
- [ ] **3.2.1** 🔥 Stop MariaDB 12.0.2 service
    ```powershell
    .\Stop-Services.ps1
    # Or: net stop IsotoneMariaDB
    ```
- [ ] **3.2.2** 🔥 Preserve existing 12.0.2 data directory
    ```powershell
    # Create the new data folder structure
    New-Item -Path "R:\isotone\mariadb\data-new" -ItemType Directory
    
    # Move existing data to version-specific folder (PRESERVE - DO NOT DELETE!)
    Move-Item -Path "R:\isotone\mariadb\data" -Destination "R:\isotone\mariadb\data-new\12.0"
    
    # Rename to final location
    Rename-Item -Path "R:\isotone\mariadb\data-new" -NewName "data"
    ```
- [ ] **3.2.3** Verify 12.0.2 data preserved
    - [ ] Check `R:\isotone\mariadb\data\12.0\mysql` exists
    - [ ] Check `R:\isotone\mariadb\data\12.0\systific_db` exists
    - [ ] All database folders should be present

---

### 3.3 Move Current 12.0.2 Binaries to Versioned Folder
- [ ] **3.3.1** Create versioned folder for current installation
    ```powershell
    New-Item -Path "R:\isotone\mariadb\12.0.2" -ItemType Directory
    ```
- [ ] **3.3.2** Move binaries to versioned folder (keep for reference/rollback)
    ```powershell
    # Move all directories except 'data' to versioned folder
    Move-Item -Path "R:\isotone\mariadb\bin" -Destination "R:\isotone\mariadb\12.0.2\"
    Move-Item -Path "R:\isotone\mariadb\lib" -Destination "R:\isotone\mariadb\12.0.2\"
    Move-Item -Path "R:\isotone\mariadb\share" -Destination "R:\isotone\mariadb\12.0.2\"
    Move-Item -Path "R:\isotone\mariadb\include" -Destination "R:\isotone\mariadb\12.0.2\"
    
    # Keep my.ini at root as the active config
    # Copy to version folder for reference
    Copy-Item -Path "R:\isotone\mariadb\my.ini" -Destination "R:\isotone\mariadb\12.0.2\my.ini.original"
    ```

---

### 3.4 Extract New MariaDB Versions
- [ ] **3.4.1** Extract MariaDB 10.11.15
    ```powershell
    Expand-Archive -Path "R:\isotone\downloads\mariadb-10.11.15-winx64.zip" -DestinationPath "R:\isotone\mariadb\temp-10.11"
    
    # Move contents to versioned folder (zip usually has a subfolder)
    Move-Item -Path "R:\isotone\mariadb\temp-10.11\mariadb-10.11.15-winx64" -Destination "R:\isotone\mariadb\10.11.15"
    Remove-Item -Path "R:\isotone\mariadb\temp-10.11" -Recurse
    ```
- [ ] **3.4.2** Extract MariaDB 11.8.5
    ```powershell
    Expand-Archive -Path "R:\isotone\downloads\mariadb-11.8.5-winx64.zip" -DestinationPath "R:\isotone\mariadb\temp-11.8"
    Move-Item -Path "R:\isotone\mariadb\temp-11.8\mariadb-11.8.5-winx64" -Destination "R:\isotone\mariadb\11.8.5"
    Remove-Item -Path "R:\isotone\mariadb\temp-11.8" -Recurse
    ```
- [ ] **3.4.3** Extract MariaDB 12.1.2 (upgrade from 12.0.2)
    ```powershell
    Expand-Archive -Path "R:\isotone\downloads\mariadb-12.1.2-winx64.zip" -DestinationPath "R:\isotone\mariadb\temp-12.1"
    Move-Item -Path "R:\isotone\mariadb\temp-12.1\mariadb-12.1.2-winx64" -Destination "R:\isotone\mariadb\12.1.2"
    Remove-Item -Path "R:\isotone\mariadb\temp-12.1" -Recurse
    ```
- [ ] **3.4.4** 💡 Optional: Remove old 12.0.2 binaries (keep data!)
    ```powershell
    # Only after 12.1.2 is working
    # Remove-Item -Path "R:\isotone\mariadb\12.0.2" -Recurse
    ```

---

### 3.5 Verify Directory Structure
- [ ] **3.5.1** Confirm final structure matches target
    ```powershell
    Get-ChildItem -Path "R:\isotone\mariadb" -Directory | Select-Object Name
    # Should show: 10.11.15, 11.8.5, 12.0.2 (or 12.1.2), data
    
    Get-ChildItem -Path "R:\isotone\mariadb\data" -Directory | Select-Object Name
    # Should show: 12.0 (original data preserved)
    ```
- [ ] **3.5.2** Verify each version has required executables
    - [ ] `R:\isotone\mariadb\10.11.15\bin\mariadbd.exe` or `mysqld.exe`
    - [ ] `R:\isotone\mariadb\11.8.5\bin\mariadbd.exe`
    - [ ] `R:\isotone\mariadb\12.1.2\bin\mariadbd.exe`

---

### 3.6 Create Version-Specific my.ini Configuration
- [ ] **3.6.1** Create `my.ini` for 10.11.15 (primary target)
    ```ini
    [mysqld]
    basedir=R:/isotone/mariadb/10.11.15
    datadir=R:/isotone/mariadb/data/10.11
    port=3306
    character-set-server=utf8mb4
    collation-server=utf8mb4_unicode_ci
    innodb_file_per_table=1
    innodb_buffer_pool_size=256M
    max_connections=50
    
    [client]
    port=3306
    ```
    - [ ] Save to: `R:\isotone\mariadb\10.11.15\my.ini`
- [ ] **3.6.2** Copy and adapt for other versions
    ```powershell
    # 11.8.5
    Copy-Item "R:\isotone\mariadb\10.11.15\my.ini" "R:\isotone\mariadb\11.8.5\my.ini"
    # Update basedir and datadir paths in the file
    
    # 12.1.2
    Copy-Item "R:\isotone\mariadb\10.11.15\my.ini" "R:\isotone\mariadb\12.1.2\my.ini"
    # Update basedir and datadir paths in the file

---

## 🗄️ Phase 4: Initialize and Import Data
*Goal: Set up fresh MariaDB 10.11.15 data directory and import all databases.*

---

### 4.1 Initialize Fresh 10.11 Data Directory
- [ ] **4.1.1** Create version-specific data directory
    ```powershell
    New-Item -Path "R:\isotone\mariadb\data\10.11" -ItemType Directory
    ```
- [ ] **4.1.2** Initialize MariaDB 10.11.15 system databases
    ```powershell
    cd R:\isotone\mariadb\10.11.15\bin
    .\mariadb-install-db.exe --datadir="R:/isotone/mariadb/data/10.11"
    ```
    - [ ] Verify `mysql` and `performance_schema` directories created in `data\10.11\`

---

### 4.2 Start MariaDB 10.11.15
- [ ] **4.2.1** Start in console mode (first time, for testing)
    ```powershell
    cd R:\isotone\mariadb\10.11.15\bin
    .\mysqld.exe --defaults-file="R:\isotone\mariadb\10.11.15\my.ini" --console
    ```
- [ ] **4.2.2** 🔥 Set root password (in another terminal)
    ```powershell
    cd R:\isotone\mariadb\10.11.15\bin
    .\mysql.exe -u root
    ```
    ```sql
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'your_password';
    FLUSH PRIVILEGES;
    EXIT;
    ```
- [ ] **4.2.3** Verify connection and version
    ```powershell
    .\mysql.exe -u root -p -e "SELECT VERSION();"
    ```
    - [ ] Confirm version shows `10.11.15-MariaDB`
- [ ] **4.2.4** Stop console mode (Ctrl+C) after testing

---

### 4.3 Create Databases
- [ ] **4.3.1** Start MariaDB and connect
    ```powershell
    cd R:\isotone\mariadb\10.11.15\bin
    .\mysql.exe -u root -p
    ```
- [ ] **4.3.2** Create each database with proper character set
    ```sql
    CREATE DATABASE `asite_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE DATABASE `gluonwp_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE DATABASE `isotone_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE DATABASE `rizonesoft_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE DATABASE `securebin_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE DATABASE `systific_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE DATABASE `phpmyadmin` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    ```
- [ ] **4.3.3** Verify databases created
    ```sql
    SHOW DATABASES;
    ```

---

### 4.4 Import Data
- [ ] **4.4.1** 🔥 Import each database from the migration-ready backups
    ```powershell
    cd R:\isotone\mariadb\10.11.15\bin
    
    # For each database:
    .\mysql.exe -u root -p asite_db < "R:\isotone\backups\mariadb-migration-ready\asite_db.sql"
    .\mysql.exe -u root -p gluonwp_db < "R:\isotone\backups\mariadb-migration-ready\gluonwp_db.sql"
    .\mysql.exe -u root -p isotone_db < "R:\isotone\backups\mariadb-migration-ready\isotone_db.sql"
    .\mysql.exe -u root -p rizonesoft_db < "R:\isotone\backups\mariadb-migration-ready\rizonesoft_db.sql"
    .\mysql.exe -u root -p securebin_db < "R:\isotone\backups\mariadb-migration-ready\securebin_db.sql"
    .\mysql.exe -u root -p systific_db < "R:\isotone\backups\mariadb-migration-ready\systific_db.sql"
    .\mysql.exe -u root -p phpmyadmin < "R:\isotone\backups\mariadb-migration-ready\phpmyadmin.sql"
    ```

- [ ] **4.4.2** ⚠️ Handle import errors
    - [ ] Note any collation errors (should be none after Phase 2)
    - [ ] Note any syntax errors in stored procedures
    - [ ] Fix and re-run problematic imports

---

## 🧪 Phase 5: Validation and Testing
*Goal: Verify all data, objects, and functionality are intact.*

---

### 5.1 Table Count Verification
- [ ] **5.1.1** Compare table counts for each database
    ```sql
    SELECT TABLE_SCHEMA, COUNT(*) as table_count 
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA NOT IN ('mysql', 'performance_schema', 'sys', 'information_schema')
    GROUP BY TABLE_SCHEMA;
    ```
    - [ ] Record results and compare with pre-migration inventory

---

### 5.2 Data Integrity Verification
- [ ] **5.2.1** Run row count verification on key tables
    ```sql
    -- systific_db example:
    SELECT 'users' as tbl, COUNT(*) FROM systific_db.users
    UNION ALL SELECT 'clients', COUNT(*) FROM systific_db.clients
    UNION ALL SELECT 'projects', COUNT(*) FROM systific_db.projects
    UNION ALL SELECT 'time_entries', COUNT(*) FROM systific_db.time_entries;
    ```
    - [ ] Compare with pre-migration counts
- [ ] **5.2.2** 🧪 Run application-specific tests
    - [ ] Test Systific login and basic operations
    - [ ] Test phpMyAdmin access
    - [ ] Test other applications

---

### 5.3 Stored Procedure Verification
- [ ] **5.3.1** Compare procedure counts
    ```sql
    SELECT ROUTINE_SCHEMA, COUNT(*) 
    FROM information_schema.ROUTINES 
    WHERE ROUTINE_SCHEMA NOT IN ('mysql', 'performance_schema', 'sys')
    GROUP BY ROUTINE_SCHEMA;
    ```
    - [ ] Match against `procedure_inventory.txt`
- [ ] **5.3.2** 🧪 Test key stored procedures
    ```sql
    -- systific_db example:
    CALL sp_calculate_sla_available_hours(1, '2026-01-01', @avail, @budget, @used, @roll, @add);
    SELECT @avail, @budget, @used, @roll, @add;
    ```
    - [ ] Verify no syntax errors
    - [ ] Verify expected results

---

### 5.4 View Verification
- [ ] **5.4.1** Compare view counts
    ```sql
    SELECT TABLE_SCHEMA, COUNT(*) 
    FROM information_schema.VIEWS 
    WHERE TABLE_SCHEMA NOT IN ('mysql', 'performance_schema', 'sys')
    GROUP BY TABLE_SCHEMA;
    ```
    - [ ] Match against `view_inventory.txt`
- [ ] **5.4.2** 🧪 Query key views
    ```sql
    -- systific_db example:
    SELECT * FROM v_sla_contract_usage_summary LIMIT 5;
    ```
    - [ ] Verify views execute without errors

---

### 5.5 Trigger Verification
- [ ] **5.5.1** Compare trigger counts
    ```sql
    SELECT TRIGGER_SCHEMA, COUNT(*) 
    FROM information_schema.TRIGGERS 
    WHERE TRIGGER_SCHEMA NOT IN ('mysql', 'performance_schema', 'sys')
    GROUP BY TRIGGER_SCHEMA;
    ```
    - [ ] Match against `trigger_inventory.txt`
- [ ] **5.5.2** 🧪 Test trigger functionality
    - [ ] Perform INSERT/UPDATE on tables with triggers
    - [ ] Verify trigger-populated columns/logs

---

### 5.6 Foreign Key Verification
- [ ] **5.6.1** Count foreign key constraints
    ```sql
    SELECT TABLE_SCHEMA, COUNT(*) 
    FROM information_schema.TABLE_CONSTRAINTS 
    WHERE CONSTRAINT_TYPE = 'FOREIGN KEY' 
    AND TABLE_SCHEMA NOT IN ('mysql', 'performance_schema', 'sys')
    GROUP BY TABLE_SCHEMA;
    ```
    - [ ] Compare with pre-migration counts (systific_db: 155 FKs expected)

---

## 🔄 Phase 6: Service Configuration Update
*Goal: Update Isotone Stack scripts for MariaDB 10.11.*

---

### 6.1 Update Service Registration
- [ ] **6.1.1** Review `Register-Services.ps1` for MariaDB paths
    - [ ] Verify service executable paths are correct
- [ ] **6.1.2** Re-register MariaDB service if needed
    ```powershell
    .\Register-Services.ps1
    ```
- [ ] **6.1.3** Verify service starts correctly
    ```powershell
    .\Start-Services.ps1
    Get-Service *MariaDB*
    ```

---

### 6.2 Update Application Configurations
- [ ] **6.2.1** Verify database connections work
    - [ ] Test PHP applications
    - [ ] Test any other connected services
- [ ] **6.2.2** Update any version-specific configurations
    - [ ] Check for MariaDB 12-specific settings in apps
    - [ ] Adjust if necessary

---

## ✅ Phase 7: Cleanup and Documentation
*Goal: Remove temporary files and document the migration.*

---

### 7.1 Cleanup
- [ ] **7.1.1** 💡 Optional: Archive the old MariaDB 12 installation
    ```powershell
    Compress-Archive -Path "R:\isotone\mariadb-12.0.2-backup" -DestinationPath "R:\isotone\backups\mariadb-12.0.2-archive.zip"
    ```
- [ ] **7.1.2** 💡 Optional: Remove temporary backup after confirmed success
    - [ ] Keep backups for at least 30 days
    - [ ] Remove only after extended validation

---

### 7.2 Migration Documentation
- [ ] **7.2.1** Record migration date and details
    - [ ] Source version: 12.0.2
    - [ ] Target version: 10.11.x
    - [ ] Databases migrated: 7
    - [ ] Issues encountered: (document any)
- [ ] **7.2.2** Update any version documentation
    - [ ] README.md if applicable
    - [ ] Configuration files

---

## 🔀 Phase 8: MariaDB Version Switching Script (💡 Enhancement)
*Goal: Create `Switch-MariaDBVersion.ps1` to enable users to switch between installed MariaDB versions.*

> **Note:** Directory structure was already set up in Phase 3. This phase focuses on the switching script.

---

### 8.1 Create Switch-MariaDBVersion.ps1 Script
- [ ] **8.1.1** Create script file based on `Switch-PHPVersion.ps1` pattern
    - [ ] File: `R:\isotone\scripts\Switch-MariaDBVersion.ps1`
    - [ ] Parameters: `-Version` (required), `-NoRestart` (optional), `-ListVersions` (optional)
- [ ] **8.1.2** Implement version discovery
    ```powershell
    # List available versions
    function Get-AvailableMariaDBVersions {
        $mariadbPath = Join-Path $isotonePath "mariadb"
        $versions = Get-ChildItem -Path $mariadbPath -Directory |
            Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
            Select-Object -ExpandProperty Name
        return $versions
    }
    # Available: 10.11.15, 11.8.5, 12.1.2
    ```
- [ ] **8.1.3** Implement version validation
    ```powershell
    # Check if requested version exists
    $mariadbVersionPath = Join-Path $isotonePath "mariadb\$Version"
    if (!(Test-Path $mariadbVersionPath)) {
        Write-Log "[ERROR] MariaDB version $Version not found" "ERROR"
        Write-Log "Available versions: $(Get-AvailableMariaDBVersions -join ', ')" "INFO"
        exit 1
    }
    
    # Verify binary exists
    $mariadbExe = Join-Path $mariadbVersionPath "bin\mariadbd.exe"
    if (!(Test-Path $mariadbExe)) {
        $mariadbExe = Join-Path $mariadbVersionPath "bin\mysqld.exe"
    }
    ```
- [ ] **8.1.4** Implement data directory mapping
    ```powershell
    # Map version to data directory (major.minor only)
    $versionParts = $Version.Split('.')
    $dataDirName = "$($versionParts[0]).$($versionParts[1])"  # e.g., "10.11"
    $dataDir = "R:/isotone/mariadb/data/$dataDirName"
    
    # Verify data directory exists
    if (!(Test-Path $dataDir)) {
        Write-Log "[WARNING] Data directory not found: $dataDir" "WARNING"
        Write-Log "Run mariadb-install-db.exe to initialize, or migrate data from another version" "INFO"
    }
    ```

---

### 8.2 Implement Service Reconfiguration
- [ ] **8.2.1** Implement service stop/reconfigure/start
    ```powershell
    # Stop existing MariaDB service
    $serviceName = "IsotoneMariaDB"
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    
    if ($service -and $service.Status -eq "Running") {
        Write-Log "Stopping MariaDB service..." "INFO"
        Stop-Service -Name $serviceName -Force
        Start-Sleep -Seconds 2
    }
    
    # Get the my.ini path for this version
    $myIniPath = Join-Path $mariadbVersionPath "my.ini"
    
    # Update service binary path to new version
    $binPath = "`"$mariadbExe`" --defaults-file=`"$myIniPath`""
    sc.exe config $serviceName binPath= $binPath | Out-Null
    
    Write-Log "[OK] Service configured for MariaDB $Version" "SUCCESS"
    ```
- [ ] **8.2.2** Implement service restart (if not -NoRestart)
    ```powershell
    if (-not $NoRestart) {
        Write-Log "Starting MariaDB $Version..." "INFO"
        Start-Service -Name $serviceName
        Start-Sleep -Seconds 3
        
        # Verify version
        $versionCheck = & "$mariadbVersionPath\bin\mysql.exe" -u root -e "SELECT VERSION();" 2>&1
        Write-Log "[OK] MariaDB $Version is now active" "SUCCESS"
    }
    ```

---

### 8.3 Add Safety Features
- [ ] **8.3.1** Display current vs target version
    ```powershell
    # Get current version before switching
    $currentVersion = & "R:\isotone\mariadb\$currentVersionFolder\bin\mysql.exe" -u root -e "SELECT VERSION();" 2>&1
    Write-Log "Current: $currentVersion" "INFO"
    Write-Log "Target:  MariaDB $Version" "INFO"
    ```
- [ ] **8.3.2** Add data compatibility warning
    ```powershell
    Write-Log "" "INFO"
    Write-Log "⚠️  IMPORTANT: Each version uses its own data directory" "WARNING"
    Write-Log "   10.11.15 → data/10.11/" "INFO"
    Write-Log "   11.8.5   → data/11.8/" "INFO"
    Write-Log "   12.1.2   → data/12.1/" "INFO"
    Write-Log "" "INFO"
    Write-Log "Data is NOT shared between versions. Use Migrate-MariaDBData.ps1 to copy data." "WARNING"
    ```

---

### 8.4 Create Wrapper Batch File
- [ ] **8.4.1** Create `Switch-MariaDBVersion.bat`
    - [ ] File: `R:\isotone\scripts\Switch-MariaDBVersion.bat`
    ```batch
    @echo off
    PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Switch-MariaDBVersion.ps1" %*
    ```

---

### 8.5 Data Migration Helper (Optional)
- [ ] **8.5.1** Create `Migrate-MariaDBData.ps1` for data migration between versions
    - [ ] Export from source version using mariadb-dump
    - [ ] Convert collations if needed (uca1400 → unicode_ci)
    - [ ] Import to target version
- [ ] **8.5.2** Example usage
    ```powershell
    # Migrate systific_db from 12.0 data to 10.11 data
    .\Migrate-MariaDBData.ps1 -SourceVersion "12.1.2" -TargetVersion "10.11.15" -Database "systific_db"
    
    # Migrate all databases
    .\Migrate-MariaDBData.ps1 -SourceVersion "12.1.2" -TargetVersion "10.11.15" -All
    ```

---

### 8.6 Documentation and Testing
- [ ] **8.6.1** Add usage examples to script help
    ```powershell
    # Switch to MariaDB 10.11
    .\Switch-MariaDBVersion.ps1 -Version "10.11.10"
    
    # Switch without restarting service
    .\Switch-MariaDBVersion.ps1 -Version "12.0.2" -NoRestart
    ```
- [ ] **8.6.2** Test switching between versions
    - [ ] Switch from 10.11 to 12.0.2
    - [ ] Verify data directory isolation
    - [ ] Switch back to 10.11
    - [ ] Verify applications work correctly
- [ ] **8.6.3** Update Isotone README.md
    - [ ] Document MariaDB version switching capability
    - [ ] Note data directory separation requirement
    - [ ] Add troubleshooting section

---

## �🔄 Progress Tracking

| Phase | Status | Progress | Notes |
|-------|--------|----------|-------|
| Phase 1: Pre-Migration Backup | ⏳ Not Started | 0% | CRITICAL - Do not skip |
| Phase 2: Collation Fixes | ⏳ Not Started | 0% | Must complete before export |
| Phase 3: Download & Prepare 10.11 | ⏳ Not Started | 0% | |
| Phase 4: Initialize & Import | ⏳ Not Started | 0% | |
| Phase 5: Validation & Testing | ⏳ Not Started | 0% | |
| Phase 6: Service Configuration | ⏳ Not Started | 0% | |
| Phase 7: Cleanup & Documentation | ⏳ Not Started | 0% | |
| Phase 8: Version Switching Feature | ⏳ Not Started | 0% | Enhancement - Similar to PHP switching |

---

## 🚨 Rollback Plan

If the migration fails at any point:

1. **Stop MariaDB 10.11**
   ```powershell
   .\Stop-Services.ps1
   ```

2. **Restore Original Installation**
   ```powershell
   Remove-Item -Path "R:\isotone\mariadb" -Recurse -Force
   Rename-Item -Path "R:\isotone\mariadb-12.0.2-backup" -NewName "mariadb"
   ```

3. **Restart MariaDB 12.0.2**
   ```powershell
   .\Start-Services.ps1
   ```

4. **Verify Services**
   ```powershell
   .\mysql.exe -u root -p -e "SELECT VERSION();"
   # Should show 12.0.2-MariaDB
   ```

---

## 📋 Quick Reference: Key Commands

| Action | Command |
|--------|---------|
| Check Version | `.\mysql.exe -u root -p -e "SELECT VERSION();"` |
| Show Databases | `.\mysql.exe -u root -p -e "SHOW DATABASES;"` |
| Export Database | `.\mariadb-dump.exe -u root -p --routines --triggers --events --single-transaction "DB_NAME" > backup.sql` |
| Import Database | `.\mysql.exe -u root -p DB_NAME < backup.sql` |
| Stop Service | `.\Stop-Services.ps1` |
| Start Service | `.\Start-Services.ps1` |
| Initialize Data | `.\mariadb-install-db.exe --datadir="R:/isotone/mariadb/data"` |

---

> **Last Updated:** 2026-01-09  
> **Author:** IsotoneStack Team  
> **Estimated Duration:** 2-4 hours (depending on database sizes)
