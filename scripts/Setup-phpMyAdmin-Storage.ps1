# Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}"
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}"
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}"
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}"
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}"
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}"
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"

# Load settings from config file
$settingsFile = Join-Path $isotonePath "config\isotone-settings.json"
$settings = @{
    logging = @{
        defaultLogLevel = "INFO"
        maxLogSizeMB = 10
        maxLogAgeDays = 30
        verbose = $false
        cleanupEnabled = $true
        logToFile = $true
        logToConsole = $true
        consoleLogLevels = @("ERROR", "WARNING", "SUCCESS")
        archiveOldLogs = $true
    }
}

# Try to load settings file
if (Test-Path $settingsFile) {
    try {
        $loadedSettings = Get-Content -Path $settingsFile -Raw | ConvertFrom-Json
        # Merge loaded settings with defaults
        if ($loadedSettings.logging) {
            foreach ($key in $loadedSettings.logging.PSObject.Properties.Name) {
                $settings.logging[$key] = $loadedSettings.logging.$key
            }
        }
    }
    catch {
        # If settings file is corrupted, use defaults
        Write-Warning "Failed to load settings file: # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}"
    }
}

# Create logs directory if it doesn't exist
if (!(Test-Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Initialize log file - single rotating log per script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFile = Join-Path $logsPath "$scriptName.log"

# Apply settings (command line parameters override settings file)
$maxLogSize = $settings.logging.maxLogSizeMB * 1MB
$maxLogAge = $settings.logging.maxLogAgeDays
$logToFile = $settings.logging.logToFile
$logToConsole = $settings.logging.logToConsole
$consoleLogLevels = $settings.logging.consoleLogLevels
$cleanupEnabled = $settings.logging.cleanupEnabled
$archiveOldLogs = $settings.logging.archiveOldLogs

# Determine log level (command line -Verbose overrides settings)
if ($Verbose) {
    $logLevel = "DEBUG"
} elseif ($settings.logging.verbose) {
    $logLevel = "DEBUG"
    $Verbose = $true  # Set verbose flag based on settings
} else {
    $logLevel = $settings.logging.defaultLogLevel
}

# Rotate log if it's too large and archiving is enabled
if ($logToFile -and $archiveOldLogs -and (Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
    $archiveFile = Join-Path $logsPath "$scriptName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Move-Item -Path $logFile -Destination $archiveFile -Force
    
    # Clean up old archived logs if cleanup is enabled
    if ($cleanupEnabled) {
        Get-ChildItem -Path $logsPath -Filter "$scriptName`_*.log" | 
            Where-Object { # Setup-phpMyAdmin-Storage.ps1
# Sets up phpMyAdmin configuration storage database and tables
# This enables advanced features like bookmarks, history, designer, etc.

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$Force               # Force recreate tables if they exist
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force
    }
}

# Define log level priorities
$logLevels = @{
    "ERROR"   = 1
    "WARNING" = 2
    "INFO"    = 3
    "SUCCESS" = 3
    "DEBUG"   = 4
}

# Get current log level priority
$currentLogLevel = $logLevels[$logLevel]
if (-not $currentLogLevel) { $currentLogLevel = 3 }  # Default to INFO

# Logging function - only logs important events
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$NoConsole,
        [switch]$AlwaysLog  # Force logging regardless of level
    )
    
    # Determine if we should log this message to file
    $levelPriority = $logLevels[$Level]
    if (-not $levelPriority) { $levelPriority = 3 }
    
    # Only log to file if logging is enabled and message level is important enough or AlwaysLog is set
    if ($logToFile -and ($AlwaysLog -or $levelPriority -le $currentLogLevel)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Write to log file
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    }
    
    # Show in console based on settings
    if ($logToConsole -and -not $NoConsole) {
        # Check if this level should be shown in console based on settings
        $showInConsole = $false
        
        # Always show levels defined in consoleLogLevels setting
        if ($Level -in $consoleLogLevels) {
            $showInConsole = $true
        }
        # In verbose mode, show everything
        elseif ($Verbose) {
            $showInConsole = $true
        }
        # Special display levels always show
        elseif ($Level -in @("CYAN", "MAGENTA", "YELLOW")) {
            $showInConsole = $true
        }
        
        if ($showInConsole) {
            switch ($Level) {
                "ERROR"   { Write-Host $Message -ForegroundColor Red }
                "WARNING" { Write-Host $Message -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $Message -ForegroundColor Green }
                "INFO"    { Write-Host $Message -ForegroundColor White }
                "DEBUG"   { Write-Host $Message -ForegroundColor Gray }
                "CYAN"    { Write-Host $Message -ForegroundColor Cyan }
                "MAGENTA" { Write-Host $Message -ForegroundColor Magenta }
                "YELLOW"  { Write-Host $Message -ForegroundColor Yellow }
                default   { Write-Host $Message }
            }
        }
    }
}



try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== phpMyAdmin Configuration Storage Setup ===" "MAGENTA"
    Write-Host ""
    
    # Check if MariaDB service is running
    $mariadbService = Get-Service -Name "IsotoneMariaDB" -ErrorAction SilentlyContinue
    if (!$mariadbService) {
        Write-Log "[ERROR] IsotoneMariaDB service not found. Please run Register-Services.ps1 first." "ERROR"
        exit 1
    }
    
    if ($mariadbService.Status -ne 'Running') {
        Write-Log "Starting MariaDB service..." "INFO"
        Start-Service -Name "IsotoneMariaDB" -ErrorAction Stop
        Start-Sleep -Seconds 3
    }
    Write-Log "[OK] MariaDB service is running" "SUCCESS"
    Write-Host ""
    
    # Find MariaDB executable
    $mariadbBin = Join-Path $isotonePath "mariadb\bin"
    $mysqlExe = $null
    
    if (Test-Path (Join-Path $mariadbBin "mariadb.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mariadb.exe"
    } elseif (Test-Path (Join-Path $mariadbBin "mysql.exe")) {
        $mysqlExe = Join-Path $mariadbBin "mysql.exe"
    } else {
        Write-Log "[ERROR] MariaDB client not found in: $mariadbBin" "ERROR"
        exit 1
    }
    Write-Log "Using MariaDB client: $mysqlExe" "DEBUG"
    
    # Find phpMyAdmin create_tables.sql
    $createTablesPaths = @(
        (Join-Path $isotonePath "phpmyadmin\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\resources\sql\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\scripts\create_tables.sql"),
        (Join-Path $isotonePath "phpmyadmin\examples\create_tables.sql")
    )
    
    $createTablesSQL = $null
    foreach ($path in $createTablesPaths) {
        if (Test-Path $path) {
            $createTablesSQL = $path
            break
        }
    }
    
    if (!$createTablesSQL) {
        Write-Log "[WARNING] create_tables.sql not found in phpMyAdmin directory" "WARNING"
        Write-Log "Creating custom SQL script..." "INFO"
        
        # Create the SQL script manually with essential tables
        $sqlContent = @'
-- phpMyAdmin Configuration Storage Tables
-- Version 5.2+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `phpmyadmin`;

-- Table structure for table `pma__bookmark`
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dbase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `query` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bookmarks';

-- Table structure for table `pma__central_columns`
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `col_length` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_collation` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `col_isNull` boolean NOT NULL,
  `col_extra` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `col_default` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Central list of columns';

-- Table structure for table `pma__column_info`
CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Column information for phpMyAdmin';

-- Table structure for table `pma__history`
CREATE TABLE IF NOT EXISTS `pma__history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SQL history for phpMyAdmin';

-- Table structure for table `pma__pdf_pages`
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `page_nr` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_descr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `db_name` (`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF relation pages for phpMyAdmin';

-- Table structure for table `pma__recent`
CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recently accessed tables';

-- Table structure for table `pma__favorite`
CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tables` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Favorite tables';

-- Table structure for table `pma__table_uiprefs`
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefs` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tables'' UI preferences';

-- Table structure for table `pma__relation`
CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  KEY `foreign_field` (`foreign_db`,`foreign_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relation table';

-- Table structure for table `pma__table_coords`
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `pdf_page_number` int(10) unsigned NOT NULL DEFAULT 0,
  `x` float unsigned NOT NULL DEFAULT 0,
  `y` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table coordinates for phpMyAdmin PDF output';

-- Table structure for table `pma__table_info`
CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table information for phpMyAdmin';

-- Table structure for table `pma__tracking`
CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema_sql` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_sql` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_active` int(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Database changes tracking for phpMyAdmin';

-- Table structure for table `pma__userconfig`
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User preferences storage for phpMyAdmin';

-- Table structure for table `pma__users`
CREATE TABLE IF NOT EXISTS `pma__users` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Users and their assignments to user groups';

-- Table structure for table `pma__usergroups`
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`,`allowed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User groups with configured menu items';

-- Table structure for table `pma__navigationhiding`
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hidden items of navigation tree';

-- Table structure for table `pma__savedsearches`
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved searches';

-- Table structure for table `pma__designer_settings`
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Settings related to Designer';

-- Table structure for table `pma__export_templates`
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `export_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved export templates';

-- Create control user
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '6&94Zrw|C>(=0f){Ni;T#>C#';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `phpmyadmin`.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
'@
        
        $createTablesSQL = Join-Path $env:TEMP "pma_create_tables.sql"
        Set-Content -Path $createTablesSQL -Value $sqlContent -Encoding UTF8
        Write-Log "Created custom SQL script: $createTablesSQL" "DEBUG"
    } else {
        Write-Log "Found create_tables.sql: $createTablesSQL" "SUCCESS"
    }
    
    # Build MySQL command
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    Write-Log "Creating phpMyAdmin configuration storage database..." "INFO"
    
    # Execute SQL script
    try {
        # Convert path to use forward slashes for MySQL source command
        $sqlPath = $createTablesSQL -replace '\\', '/'
        
        # Execute the SQL file using input redirection instead of source command
        $result = Get-Content $createTablesSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
        } else {
            Write-Log "[OK] phpMyAdmin tables created successfully" "SUCCESS"
        }
    } catch {
        Write-Log "[ERROR] Failed to execute SQL: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration..." "INFO"
    
    $phpmyadminConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $phpmyadminConfig) {
        $configContent = Get-Content -Path $phpmyadminConfig -Raw
        
        # Check if configuration storage is already configured
        if ($configContent -notmatch "\`$cfg\['Servers'\]\[\`$i\]\['controluser'\]") {
            Write-Log "Adding configuration storage settings to config.inc.php..." "INFO"
            
            # Add configuration storage settings before the closing ?>
            $storageConfig = @'

/* Storage database and tables */
$cfg['Servers'][$i]['controlhost'] = 'localhost';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database name */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';

/* Storage tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
'@
            
            # Insert before closing ?> or at the end
            if ($configContent -match '\?>') {
                $configContent = $configContent -replace '\?>', "$storageConfig`n?>"
            } else {
                $configContent += "`n$storageConfig"
            }
            
            Set-Content -Path $phpmyadminConfig -Value $configContent -Encoding UTF8
            Write-Log "[OK] Configuration storage settings added to config.inc.php" "SUCCESS"
        } else {
            Write-Log "Configuration storage already configured in config.inc.php" "INFO"
        }
    } else {
        Write-Log "[WARNING] config.inc.php not found at: $phpmyadminConfig" "WARNING"
        Write-Log "Please run Configure-IsotoneStack.ps1 first" "WARNING"
    }
    
    # Clean up temp file if we created it
    if ((Test-Path $createTablesSQL) -and ($createTablesSQL -like "*\Temp\*")) {
        Remove-Item -Path $createTablesSQL -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Setup Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage has been set up successfully!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Database: phpmyadmin" "INFO"
    Write-Log "Control User: pma" "INFO"
    Write-Log "Control Password: [Configured in config.inc.php]" "INFO"
    Write-Log "" "INFO"
    Write-Log "You may need to:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. Log out and back into phpMyAdmin" "DEBUG"
    Write-Log "" "INFO"
    Write-Log "The warning about configuration storage should now be resolved." "SUCCESS"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin configuration storage setup completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Setup failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}
