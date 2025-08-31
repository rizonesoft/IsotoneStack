"""
Service monitoring and management
"""

import subprocess
import threading
import time
from typing import Callable, Optional, Dict, Any
import psutil

class ServiceMonitor:
    def __init__(self, config: Any, logger: Any):
        self.config = config
        self.logger = logger
        self.running = False
        self.monitor_thread = None
        self.on_status_change: Optional[Callable] = None
        self.service_status = {}
        
    def start(self):
        """Start monitoring services"""
        if self.running:
            return
        
        self.running = True
        self.monitor_thread = threading.Thread(target=self._monitor_loop, daemon=True)
        self.monitor_thread.start()
        self.logger.info("Service monitoring started")
    
    def stop(self):
        """Stop monitoring services"""
        self.running = False
        if self.monitor_thread:
            self.monitor_thread.join(timeout=5)
        self.logger.info("Service monitoring stopped")
    
    def _monitor_loop(self):
        """Main monitoring loop"""
        while self.running:
            try:
                # Check Apache
                apache_status = self._check_service("IsotoneApache")
                self._update_status("apache", apache_status)
                
                # Check MariaDB
                mariadb_status = self._check_service("IsotoneMariaDB")
                self._update_status("mariadb", mariadb_status)
                
                # Check Mailpit (optional service)
                mailpit_status = self._check_service("IsotoneMailpit")
                self._update_status("mailpit", mailpit_status)
                
                # Check port availability
                self._check_ports()
                
                time.sleep(5)  # Check every 5 seconds
                
            except Exception as e:
                self.logger.error(f"Monitoring error: {e}")
                time.sleep(10)
    
    def _check_service(self, service_name: str) -> str:
        """Check Windows service status"""
        try:
            result = subprocess.run(
                f"sc query {service_name}",
                shell=True,
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if "RUNNING" in result.stdout:
                return "running"
            elif "STOPPED" in result.stdout:
                return "stopped"
            else:
                return "unknown"
                
        except subprocess.TimeoutExpired:
            return "timeout"
        except Exception as e:
            self.logger.error(f"Error checking service {service_name}: {e}")
            return "error"
    
    
    def _check_ports(self):
        """Check if service ports are in use"""
        ports = {
            80: "http",
            443: "https",
            3306: "mysql",
            1025: "smtp (mailpit)",
            8025: "mailpit web"
        }
        
        for port, name in ports.items():
            try:
                connections = psutil.net_connections()
                in_use = any(conn.laddr.port == port for conn in connections 
                            if conn.status == 'LISTEN')
                
                if in_use:
                    self.logger.debug(f"Port {port} ({name}) is in use")
                    
            except Exception as e:
                self.logger.error(f"Error checking port {port}: {e}")
    
    def _update_status(self, service: str, status: str):
        """Update service status and notify if changed"""
        old_status = self.service_status.get(service)
        
        if old_status != status:
            self.service_status[service] = status
            self.logger.info(f"{service} status changed: {old_status} -> {status}")
            
            if self.on_status_change:
                self.on_status_change(service, status)
    
    def get_service_info(self, service: str) -> Dict[str, Any]:
        """Get detailed service information"""
        info = {
            "status": self.service_status.get(service, "unknown"),
            "memory": 0,
            "cpu": 0,
            "pid": None
        }
        
        # Get process info if running
        if info["status"] == "running":
            service_map = {
                "apache": "httpd.exe",
                "mariadb": "mysqld.exe",
                "mailpit": "mailpit.exe"
            }
            
            process_name = service_map.get(service)
            if process_name:
                for proc in psutil.process_iter(['pid', 'name', 'memory_percent', 'cpu_percent']):
                    try:
                        if process_name.lower() in proc.info['name'].lower():
                            info["pid"] = proc.info['pid']
                            info["memory"] = proc.info['memory_percent']
                            info["cpu"] = proc.info['cpu_percent']
                            break
                    except (psutil.NoSuchProcess, psutil.AccessDenied):
                        continue
        
        return info