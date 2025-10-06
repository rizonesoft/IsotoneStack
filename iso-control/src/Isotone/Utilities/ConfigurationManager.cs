using System;
using System.IO;
using Newtonsoft.Json;

namespace Isotone.Utilities
{
    public class ConfigurationManager
    {
        private readonly string _configPath;
        private Configuration _configuration;

        public Configuration Configuration => _configuration;

        public ConfigurationManager(string isotonePath)
        {
            // Store config next to the executable for portability
            var exeDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            _configPath = Path.Combine(exeDir ?? ".", "config.json");
            _configuration = LoadConfiguration(isotonePath);
        }

        private Configuration LoadConfiguration(string isotonePath)
        {
            if (File.Exists(_configPath))
            {
                try
                {
                    var json = File.ReadAllText(_configPath);
                    var config = JsonConvert.DeserializeObject<Configuration>(json);
                    if (config != null)
                        return config;
                }
                catch
                {
                    // Fall through to create default
                }
            }

            // Create default configuration
            var defaultConfig = new Configuration
            {
                IsotonePath = isotonePath,
                AutoStartServices = false,
                MinimizeToTray = true,
                AutoCheckUpdates = true,
                ApachePort = 80,
                ApacheSSLPort = 443,
                MariaDBPort = 3306,
                MailpitPort = 8025
            };

            Save(defaultConfig);
            return defaultConfig;
        }

        public void Save()
        {
            Save(_configuration);
        }

        private void Save(Configuration config)
        {
            try
            {
                var directory = Path.GetDirectoryName(_configPath);
                if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
                {
                    Directory.CreateDirectory(directory);
                }

                var json = JsonConvert.SerializeObject(config, Formatting.Indented);
                File.WriteAllText(_configPath, json);
            }
            catch (Exception ex)
            {
                // Log error or handle appropriately
                Console.WriteLine($"Failed to save configuration: {ex.Message}");
            }
        }
    }

    public class Configuration
    {
        public string IsotonePath { get; set; } = @"R:\isotone";
        public bool AutoStartServices { get; set; }
        public bool MinimizeToTray { get; set; }
        public bool AutoCheckUpdates { get; set; }
        public int ApachePort { get; set; }
        public int ApacheSSLPort { get; set; }
        public int MariaDBPort { get; set; }
        public int MailpitPort { get; set; }
    }
}