# Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
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
        Write-Warning "Failed to load settings file: # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
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
        Write-Warning "Failed to load settings file: # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
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
        Write-Warning "Failed to load settings file: # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
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
        Write-Warning "Failed to load settings file: # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
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
        Write-Warning "Failed to load settings file: # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
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
        Write-Warning "Failed to load settings file: # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
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
        Write-Warning "Failed to load settings file: # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up old logs on script completion (runs even if script fails) - only if cleanup is enabled
    if ($cleanupEnabled -and (Test-Path $logsPath)) {
        Get-ChildItem -Path $logsPath -Filter "*.log" | 
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
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
        Write-Warning "Failed to load settings file: # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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
            Where-Object { # Secure-phpMyAdmin-ControlUser.ps1
# Generates and sets a secure random password for the phpMyAdmin control user
# This improves security by replacing the default password

param(
    [string]$RootPassword = "",  # MariaDB root password (empty by default,`n    [switch]$Verbose,`n    [switch]$Debug)
    [switch]$ShowPassword        # Display the generated password
)

#Requires -Version 5.1

# Get script locations using portable paths
$scriptPath = $PSScriptRoot
$isotonePath = Split-Path -Parent $scriptPath
$logsPath = Join-Path $isotonePath "logs\isotone"



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
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



# Function to generate secure random password
function New-SecurePassword {
    param(
        [int]$Length = 24
    ,`n    [switch]$Verbose,`n    [switch]$Debug)
    
    $chars = @(
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '0123456789',
        '!@#$%^&*()_+-=[]{}|;:,.<>?'
    )
    
    $password = ''
    $random = New-Object System.Random
    
    # Ensure at least one character from each set
    foreach ($charSet in $chars) {
        $password += $charSet[$random.Next($charSet.Length)]
    }
    
    # Fill the rest with random characters from all sets
    $allChars = $chars -join ''
    for ($i = $password.Length; $i -lt $Length; $i++) {
        $password += $allChars[$random.Next($allChars.Length)]
    }
    
    # Shuffle the password
    $passwordArray = $password.ToCharArray()
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next($i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    
    return -join $passwordArray
}

try {
    # Start logging
    
    Write-Log "$scriptName Started (IsotoneStack: $isotonePath)" "INFO" -AlwaysLog
    
    
    
    Write-Host ""
    Write-Log "=== Securing phpMyAdmin Control User ===" "MAGENTA"
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
    
    # Generate secure password
    Write-Log "Generating secure random password..." "INFO"
    $newPassword = New-SecurePassword -Length 24
    
    # Escape special characters for SQL
    $sqlPassword = $newPassword -replace "'", "''"
    
    # Build MySQL command arguments
    $mysqlArgs = @()
    if ($RootPassword) {
        $mysqlArgs += "-u", "root", "-p$RootPassword"
    } else {
        $mysqlArgs += "-u", "root"
    }
    
    # Update password in database
    Write-Log "Updating control user password in database..." "INFO"
    
    $sqlCommands = @"
-- Update pma user password
ALTER USER 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
FLUSH PRIVILEGES;

-- Verify the user exists and has correct privileges
SHOW GRANTS FOR 'pma'@'localhost';
"@
    
    try {
        $result = $sqlCommands | & $mysqlExe $mysqlArgs 2>&1 | Out-String
        
        if ($result -match "ERROR") {
            Write-Log "SQL execution output: $result" "WARNING"
            
            # Try to create user if it doesn't exist
            Write-Log "Attempting to create control user..." "INFO"
            $createUserSQL = @"
-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'pma'@'localhost' IDENTIFIED BY '$sqlPassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON phpmyadmin.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
"@
            $result = $createUserSQL | & $mysqlExe $mysqlArgs 2>&1 | Out-String
            
            if ($result -match "ERROR") {
                Write-Log "[ERROR] Failed to update control user: $result" "ERROR"
                exit 1
            }
        }
        
        Write-Log "[OK] Control user password updated in database" "SUCCESS"
    } catch {
        Write-Log "[ERROR] Failed to update database: $_" "ERROR"
        exit 1
    }
    
    # Update phpMyAdmin configuration
    Write-Log "Updating phpMyAdmin configuration files..." "INFO"
    
    # Update main config
    $mainConfig = Join-Path $isotonePath "phpmyadmin\config.inc.php"
    if (Test-Path $mainConfig) {
        $configContent = Get-Content -Path $mainConfig -Raw
        
        # Escape special characters for regex
        $escapedPassword = [regex]::Escape($newPassword)
        
        # Update control password
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $mainConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated main configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Main config not found at: $mainConfig" "WARNING"
    }
    
    # Update template config
    $templateConfig = Join-Path $isotonePath "config\phpmyadmin\config.inc.php"
    if (Test-Path $templateConfig) {
        $configContent = Get-Content -Path $templateConfig -Raw
        
        # Update control password in template
        $configContent = $configContent -replace "\`$cfg\['Servers'\]\[\`$i\]\['controlpass'\]\s*=\s*'[^']*';", "`$cfg['Servers'][\`$i]['controlpass'] = '$newPassword';"
        
        Set-Content -Path $templateConfig -Value $configContent -Encoding UTF8
        Write-Log "[OK] Updated template configuration" "SUCCESS"
    } else {
        Write-Log "[WARNING] Template config not found at: $templateConfig" "WARNING"
    }
    
    # Save password to secure location
    $passwordFile = Join-Path $isotonePath "config\phpmyadmin\.pma_pass"
    Set-Content -Path $passwordFile -Value $newPassword -Encoding UTF8
    
    # Set file as hidden and system
    $file = Get-Item $passwordFile -Force
    $file.Attributes = 'Hidden', 'System'
    
    Write-Log "Password saved to secure location: $passwordFile" "DEBUG"
    
    Write-Host ""
    Write-Log "========================================" "CYAN"
    Write-Log "    Security Update Summary" "CYAN"
    Write-Log "========================================" "CYAN"
    Write-Host ""
    
    Write-Log "phpMyAdmin control user has been secured!" "SUCCESS"
    Write-Log "" "INFO"
    Write-Log "Control User: pma" "INFO"
    
    if ($ShowPassword) {
        Write-Log "New Password: $newPassword" "YELLOW"
        Write-Log "" "INFO"
        Write-Log "[WARNING] This password is displayed for your reference." "WARNING"
        Write-Log "It has been saved to: config\phpmyadmin\.pma_pass" "INFO"
    } else {
        Write-Log "New password has been generated and saved securely." "INFO"
        Write-Log "Password file: config\phpmyadmin\.pma_pass (hidden)" "DEBUG"
    }
    
    Write-Log "" "INFO"
    Write-Log "Next steps:" "YELLOW"
    Write-Log "  1. Restart Apache service" "DEBUG"
    Write-Log "  2. Clear browser cache" "DEBUG"
    Write-Log "  3. The security warning should now be resolved" "DEBUG"
    
    Write-Host ""
    
    Write-Log "phpMyAdmin control user security update completed" "SUCCESS"
    Write-Log "Log file: $logFile" "INFO"
    
    
} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Security update failed with fatal error" "ERROR"
    Write-Host ""
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
}.LastWriteTime -lt (Get-Date).AddDays(-$maxLogAge) } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}
