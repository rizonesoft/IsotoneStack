<?php
// phpLiteAdmin configuration for IsotoneStack
// Template configuration file - will be customized during setup

// Password for phpLiteAdmin (default: admin)
// IMPORTANT: Change this password for security!
$password = 'admin';

// Directory where SQLite databases are stored
$directory = '{{INSTALL_PATH}}/sqlite';

// Theme (options: Default, AlternateBlue, Modern, Bootstrap, Flat, etc.)
$theme = 'Default';

// Language
$language = 'en';

// Number of rows to display by default
$rowsNum = 30;

// Maximum file size for imports (in bytes)
$maxSavedChars = 100000;

// Enable debugging
$debug = false;

// Custom functions available in SQL queries
$custom_functions = array(
    'md5', 'sha1', 'sha256', 
    'strtoupper', 'strtolower', 
    'ucfirst', 'lcfirst',
    'base64_encode', 'base64_decode',
    'json_encode', 'json_decode'
);

// Supported SQLite extensions
$allowed_extensions = array('db', 'db3', 'sqlite', 'sqlite3', 'sqlitedb');

// Allow creation of new databases
$directory_list = true;

// Rename databases to ".db" on creation
$rename_db_to = 'db';

// Character encoding
$charsetsArray = array(
    'UTF-8' => 'Unicode (UTF-8)',
    'ISO-8859-1' => 'Western European (ISO-8859-1)',
    'ISO-8859-15' => 'Western European (ISO-8859-15)',
);

// Default character set
$charset = 'UTF-8';

// Enable cookie-based authentication
$cookie_name = 'phpliteadmin';

// Cookie lifetime (in seconds)
$cookie_lifetime = 86400; // 24 hours

// Number of recent queries to remember
$num_recent_queries = 10;

// Enable auto-complete for SQL queries
$auto_complete = true;

// Show table comments
$show_table_comment = true;

// Enable foreign key support
$foreign_keys = true;

// SQLite version to use (leave empty for auto-detect)
$sqlite_version = '';

// Scan for databases in subdirectories
$scan_subdirectories = true;

// Maximum directory depth for scanning
$subdirectories_depth = 2;

// Show hidden files (starting with dot)
$show_hidden_files = false;

// Time zone
date_default_timezone_set('America/New_York');

// Error reporting (disable in production)
error_reporting(0);
ini_set('display_errors', '0');

// Memory limit for operations
ini_set('memory_limit', '256M');

// Execution time limit
set_time_limit(300);
?>