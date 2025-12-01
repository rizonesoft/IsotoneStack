using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace Isotone.Utilities
{
    public class PHPManager
    {
        private readonly string _isotonePath;
        private readonly string _phpBasePath;

        public PHPManager(string isotonePath)
        {
            _isotonePath = isotonePath;
            _phpBasePath = Path.Combine(isotonePath, "php");
        }

        /// <summary>
        /// Detects all PHP versions installed in the php folder
        /// </summary>
        public List<PhpVersion> DetectPhpVersions()
        {
            var versions = new List<PhpVersion>();

            if (!Directory.Exists(_phpBasePath))
                return versions;

            try
            {
                var directories = Directory.GetDirectories(_phpBasePath);
                
                foreach (var dir in directories)
                {
                    var dirName = Path.GetFileName(dir);
                    var phpExe = Path.Combine(dir, "php.exe");
                    var phpDll = Path.Combine(dir, "php8apache2_4.dll");

                    // Check if it's a valid PHP installation
                    if (File.Exists(phpExe) && File.Exists(phpDll))
                    {
                        var version = new PhpVersion
                        {
                            Version = dirName,
                            Path = dir,
                            IsValid = true,
                            FullVersion = dirName // Use directory name directly (fast)
                        };

                        versions.Add(version);
                    }
                }

                // Sort versions (newest first)
                versions = versions.OrderByDescending(v => v.Version).ToList();
            }
            catch (Exception ex)
            {
                // Log error if needed
                Console.WriteLine($"Error detecting PHP versions: {ex.Message}");
            }

            return versions;
        }

        /// <summary>
        /// Gets available PHP extensions for a specific version
        /// </summary>
        public List<PhpExtension> GetAvailableExtensions(string version)
        {
            var extensions = new List<PhpExtension>();
            var extPath = Path.Combine(_phpBasePath, version, "ext");

            if (!Directory.Exists(extPath))
                return extensions;

            try
            {
                var dllFiles = Directory.GetFiles(extPath, "php_*.dll");
                
                foreach (var dll in dllFiles)
                {
                    var fileName = Path.GetFileNameWithoutExtension(dll);
                    // Remove "php_" prefix
                    var extName = fileName.Substring(4);
                    
                    extensions.Add(new PhpExtension
                    {
                        Name = extName,
                        DisplayName = GetExtensionDisplayName(extName),
                        Description = GetExtensionDescription(extName),
                        FilePath = dll
                    });
                }

                extensions = extensions.OrderBy(e => e.DisplayName).ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting PHP extensions: {ex.Message}");
            }

            return extensions;
        }

        /// <summary>
        /// Gets currently enabled extensions from php.ini
        /// </summary>
        public List<string> GetEnabledExtensions(string version)
        {
            var enabled = new List<string>();
            var phpIniPath = Path.Combine(_phpBasePath, version, "php.ini");

            if (!File.Exists(phpIniPath))
                return enabled;

            try
            {
                var lines = File.ReadAllLines(phpIniPath);
                foreach (var line in lines)
                {
                    var trimmed = line.Trim();
                    if (trimmed.StartsWith("extension=") && !trimmed.StartsWith(";"))
                    {
                        var extName = trimmed.Substring(10).Trim();
                        
                        // Handle both formats: "curl" and "php_curl.dll"
                        if (extName.StartsWith("php_"))
                        {
                            extName = extName.Substring(4); // Remove "php_" prefix
                        }
                        if (extName.EndsWith(".dll"))
                        {
                            extName = extName.Substring(0, extName.Length - 4); // Remove ".dll" suffix
                        }
                        
                        enabled.Add(extName);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error reading php.ini: {ex.Message}");
            }

            return enabled;
        }

        /// <summary>
        /// Updates php.ini to enable/disable extensions
        /// </summary>
        public bool UpdateExtensions(string version, List<string> extensionsToEnable)
        {
            var phpIniPath = Path.Combine(_phpBasePath, version, "php.ini");

            if (!File.Exists(phpIniPath))
                return false;

            try
            {
                var lines = File.ReadAllLines(phpIniPath).ToList();
                var updatedLines = new List<string>();

                foreach (var line in lines)
                {
                    var trimmed = line.Trim();
                    
                    // Check if this is an extension line
                    if (trimmed.StartsWith("extension=") || trimmed.StartsWith(";extension="))
                    {
                        // Extract extension name
                        var extLine = trimmed.TrimStart(';');
                        if (extLine.StartsWith("extension="))
                        {
                            var extName = extLine.Substring(10).Trim();
                            
                            // Check if this extension should be enabled
                            if (extensionsToEnable.Contains(extName))
                            {
                                updatedLines.Add($"extension={extName}");
                            }
                            else
                            {
                                updatedLines.Add($";extension={extName}");
                            }
                            continue;
                        }
                    }
                    
                    updatedLines.Add(line);
                }

                File.WriteAllLines(phpIniPath, updatedLines);
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating php.ini: {ex.Message}");
                return false;
            }
        }

        private string GetExtensionDisplayName(string extName)
        {
            // Convert extension names to friendly display names
            var displayNames = new Dictionary<string, string>
            {
                { "mysqli", "MySQL Improved" },
                { "pdo_mysql", "PDO MySQL" },
                { "pdo_sqlite", "PDO SQLite" },
                { "pdo_pgsql", "PDO PostgreSQL" },
                { "curl", "cURL" },
                { "gd", "GD (Image Processing)" },
                { "mbstring", "Multibyte String" },
                { "openssl", "OpenSSL" },
                { "fileinfo", "File Information" },
                { "exif", "EXIF" },
                { "intl", "Internationalization" },
                { "soap", "SOAP" },
                { "xml", "XML" },
                { "xmlrpc", "XML-RPC" },
                { "zip", "ZIP Archive" },
                { "bz2", "BZ2 Compression" },
                { "ftp", "FTP" },
                { "sodium", "Sodium Cryptography" },
                { "opcache", "OPcache" },
                { "sqlite3", "SQLite3" }
            };

            return displayNames.ContainsKey(extName) ? displayNames[extName] : extName.ToUpper();
        }

        private string GetExtensionDescription(string extName)
        {
            // Extension descriptions
            var descriptions = new Dictionary<string, string>
            {
                { "mysqli", "MySQL database connectivity" },
                { "pdo_mysql", "PDO driver for MySQL databases" },
                { "pdo_sqlite", "PDO driver for SQLite databases" },
                { "pdo_pgsql", "PDO driver for PostgreSQL databases" },
                { "curl", "Client URL Library for HTTP requests" },
                { "gd", "Image creation and manipulation" },
                { "mbstring", "Multibyte string handling" },
                { "openssl", "OpenSSL cryptographic functions" },
                { "fileinfo", "File type detection" },
                { "exif", "Read metadata from images" },
                { "intl", "Internationalization functions" },
                { "soap", "Simple Object Access Protocol" },
                { "xml", "XML parsing and manipulation" },
                { "xmlrpc", "XML-RPC protocol support" },
                { "zip", "ZIP archive handling" },
                { "bz2", "BZ2 compression support" },
                { "ftp", "FTP client functionality" },
                { "sodium", "Modern cryptography library" },
                { "opcache", "Opcode cache for improved performance" },
                { "sqlite3", "SQLite3 database support" }
            };

            return descriptions.ContainsKey(extName) ? descriptions[extName] : "PHP extension";
        }
    }

    public class PhpVersion
    {
        public string Version { get; set; } = string.Empty;
        public string FullVersion { get; set; } = string.Empty;
        public string Path { get; set; } = string.Empty;
        public bool IsValid { get; set; }

        public override string ToString()
        {
            return string.IsNullOrEmpty(FullVersion) ? Version : $"PHP {FullVersion}";
        }
    }

    public class PhpExtension
    {
        public string Name { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string FilePath { get; set; } = string.Empty;
        public bool IsEnabled { get; set; }
    }
}
