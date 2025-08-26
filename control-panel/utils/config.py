"""
Configuration management for IsotoneStack Control Panel
"""

import json
import os
from pathlib import Path
from typing import Dict, Any, Optional

class Config:
    def __init__(self, config_file: str = "config/settings.json"):
        self.config_file = Path(config_file)
        self.config = self._load_config()
        self.isotone_root = Path("C:/isotone")
        
    def _load_config(self) -> Dict[str, Any]:
        """Load configuration from file"""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r') as f:
                    return json.load(f)
            except Exception as e:
                print(f"Error loading config: {e}")
        
        # Return default configuration
        return self._get_default_config()
    
    def _get_default_config(self) -> Dict[str, Any]:
        """Get default configuration"""
        return {
            "theme": "dark",
            "minimize_to_tray": True,
            "auto_start_services": False,
            "auto_start_with_windows": False,
            "check_for_updates": True,
            "log_level": "INFO",
            "isotone_path": "C:\\isotone",
            
            "services": {
                "apache": {
                    "name": "IsotoneApache",
                    "path": "C:\\isotone\\apache24",
                    "config": "C:\\isotone\\apache24\\conf\\httpd.conf",
                    "log": "C:\\isotone\\logs\\apache\\error.log"
                },
                "mariadb": {
                    "name": "IsotoneMariaDB",
                    "path": "C:\\isotone\\mariadb",
                    "config": "C:\\isotone\\mariadb\\my.ini",
                    "log": "C:\\isotone\\logs\\mariadb\\error.log"
                },
                "php": {
                    "path": "C:\\isotone\\php",
                    "config": "C:\\isotone\\php\\php.ini",
                    "log": "C:\\isotone\\logs\\php\\error.log"
                }
            },
            
            "ports": {
                "http": 80,
                "https": 443,
                "mysql": 3306,
                "phpmyadmin": 8080
            },
            
            "database": {
                "host": "localhost",
                "port": 3306,
                "user": "root",
                "password": "isotone_admin"
            },
            
            "ui": {
                "window_width": 1200,
                "window_height": 700,
                "sidebar_width": 200,
                "animation_speed": 0.3
            }
        }
    
    def save(self):
        """Save configuration to file"""
        try:
            self.config_file.parent.mkdir(parents=True, exist_ok=True)
            with open(self.config_file, 'w') as f:
                json.dump(self.config, f, indent=4)
            return True
        except Exception as e:
            print(f"Error saving config: {e}")
            return False
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get configuration value"""
        keys = key.split('.')
        value = self.config
        
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return default
        
        return value
    
    def set(self, key: str, value: Any) -> bool:
        """Set configuration value"""
        keys = key.split('.')
        config = self.config
        
        for k in keys[:-1]:
            if k not in config:
                config[k] = {}
            config = config[k]
        
        config[keys[-1]] = value
        return self.save()
    
    def get_service_config(self, service: str) -> Dict[str, Any]:
        """Get service configuration"""
        return self.get(f"services.{service}", {})
    
    def get_isotone_path(self) -> Path:
        """Get IsotoneStack installation path"""
        return Path(self.get("isotone_path", "C:\\isotone"))
    
    def get_log_path(self, service: str) -> Optional[Path]:
        """Get log file path for a service"""
        log = self.get(f"services.{service}.log")
        return Path(log) if log else None