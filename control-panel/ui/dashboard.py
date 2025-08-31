"""
Dashboard page with service status, resource meters, and quick stats
"""

import customtkinter as ctk
import tkinter as tk
from typing import Dict, Any
import psutil
import threading
import time
import subprocess
import os
from datetime import datetime, timedelta

class Dashboard:
    def __init__(self, parent, config, logger):
        self.parent = parent
        self.config = config
        self.logger = logger
        self.service_status = {}
        self.resource_monitors = {}
        self.stats_labels = {}
        
        # Create main frame
        self.frame = ctk.CTkScrollableFrame(parent, corner_radius=0)
        
        # Create dashboard sections
        self._create_header()
        self._create_service_status_section()
        self._create_resource_usage_section()
        self._create_quick_stats_section()
        self._create_quick_actions_section()
        
        # Start resource monitoring
        self._start_monitoring()
        
        # Hide initially
        self.hide()
    
    def _create_header(self):
        """Create dashboard header"""
        header_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        header_frame.pack(fill="x", padx=20, pady=(20, 10))
        
        # Title
        title = ctk.CTkLabel(
            header_frame,
            text="Dashboard",
            font=ctk.CTkFont(size=24, weight="bold")
        )
        title.pack(side="left", padx=20, pady=15)
        
        # Refresh button
        refresh_btn = ctk.CTkButton(
            header_frame,
            text="🔄 Refresh",
            width=100,
            command=self.refresh
        )
        refresh_btn.pack(side="right", padx=20, pady=15)
        
        # Status text
        self.status_label = ctk.CTkLabel(
            header_frame,
            text="All systems operational",
            font=ctk.CTkFont(size=14),
            text_color="green"
        )
        self.status_label.pack(side="right", padx=20)
    
    def _create_service_status_section(self):
        """Create service status indicators section"""
        section_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        section_frame.pack(fill="x", padx=20, pady=10)
        
        # Section title
        title = ctk.CTkLabel(
            section_frame,
            text="Service Status",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.pack(anchor="w", padx=20, pady=(15, 10))
        
        # Services container
        services_frame = ctk.CTkFrame(section_frame, fg_color="transparent")
        services_frame.pack(fill="x", padx=20, pady=(0, 15))
        
        services = [
            ("Apache", "apache"),
            ("MariaDB", "mariadb"),
            ("Mailpit", "mailpit")
        ]
        
        for i, (name, service_id) in enumerate(services):
            service_widget = self._create_service_widget(services_frame, name, service_id)
            service_widget.pack(side="left", padx=10, expand=True, fill="x")
    
    def _create_service_widget(self, parent, name: str, service_id: str):
        """Create a service status widget"""
        frame = ctk.CTkFrame(parent, corner_radius=8)
        
        # Status indicator
        # Get the background color (handle CustomTkinter color format)
        fg_color = frame.cget("fg_color")
        
        # CustomTkinter can return colors in different formats
        if isinstance(fg_color, (list, tuple)) and len(fg_color) >= 2:
            # It's a tuple/list with light and dark colors
            bg_color = fg_color[1] if ctk.get_appearance_mode().lower() == "dark" else fg_color[0]
        elif isinstance(fg_color, str):
            # It might be a string like "gray86 gray17" or just "gray20"
            if " " in fg_color:
                # Split the string and pick the appropriate color
                colors = fg_color.split()
                bg_color = colors[1] if len(colors) > 1 and ctk.get_appearance_mode().lower() == "dark" else colors[0]
            else:
                bg_color = fg_color
        else:
            # Fallback to a safe color
            bg_color = "#2b2b2b" if ctk.get_appearance_mode().lower() == "dark" else "#dbdbdb"
        
        status_canvas = tk.Canvas(
            frame,
            width=20,
            height=20,
            highlightthickness=0,
            bg=bg_color
        )
        status_canvas.pack(side="left", padx=(15, 10), pady=15)
        
        # Draw status circle
        status_indicator = status_canvas.create_oval(2, 2, 18, 18, fill="gray", outline="")
        self.service_status[service_id] = {
            "canvas": status_canvas,
            "indicator": status_indicator
        }
        
        # Service info
        info_frame = ctk.CTkFrame(frame, fg_color="transparent")
        info_frame.pack(side="left", fill="x", expand=True, pady=10)
        
        name_label = ctk.CTkLabel(
            info_frame,
            text=name,
            font=ctk.CTkFont(size=14, weight="bold")
        )
        name_label.pack(anchor="w")
        
        status_label = ctk.CTkLabel(
            info_frame,
            text="Checking...",
            font=ctk.CTkFont(size=12),
            text_color=("gray60", "gray40")
        )
        status_label.pack(anchor="w")
        self.service_status[service_id]["label"] = status_label
        
        # Control buttons
        btn_frame = ctk.CTkFrame(frame, fg_color="transparent")
        btn_frame.pack(side="right", padx=15)
        
        start_btn = ctk.CTkButton(
            btn_frame,
            text="▶",
            width=30,
            height=30,
            command=lambda: self._control_service(service_id, "start")
        )
        start_btn.pack(side="left", padx=2)
        
        stop_btn = ctk.CTkButton(
            btn_frame,
            text="■",
            width=30,
            height=30,
            command=lambda: self._control_service(service_id, "stop")
        )
        stop_btn.pack(side="left", padx=2)
        
        return frame
    
    def _create_resource_usage_section(self):
        """Create resource usage meters section"""
        section_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        section_frame.pack(fill="x", padx=20, pady=10)
        
        # Section title
        title = ctk.CTkLabel(
            section_frame,
            text="Resource Usage",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.pack(anchor="w", padx=20, pady=(15, 10))
        
        # Resources container
        resources_frame = ctk.CTkFrame(section_frame, fg_color="transparent")
        resources_frame.pack(fill="x", padx=20, pady=(0, 15))
        
        # CPU usage
        cpu_frame = self._create_resource_meter(resources_frame, "CPU Usage", "cpu")
        cpu_frame.pack(side="left", padx=10, expand=True, fill="x")
        
        # Memory usage
        mem_frame = self._create_resource_meter(resources_frame, "Memory Usage", "memory")
        mem_frame.pack(side="left", padx=10, expand=True, fill="x")
        
        # Disk usage
        disk_frame = self._create_resource_meter(resources_frame, "Disk Usage", "disk")
        disk_frame.pack(side="left", padx=10, expand=True, fill="x")
    
    def _create_resource_meter(self, parent, title: str, resource_id: str):
        """Create a resource usage meter"""
        frame = ctk.CTkFrame(parent, corner_radius=8)
        
        # Title
        title_label = ctk.CTkLabel(
            frame,
            text=title,
            font=ctk.CTkFont(size=14, weight="bold")
        )
        title_label.pack(pady=(15, 5))
        
        # Progress bar
        progress = ctk.CTkProgressBar(frame, width=150, height=20)
        progress.pack(padx=20, pady=5)
        progress.set(0)
        
        # Value label
        value_label = ctk.CTkLabel(
            frame,
            text="0%",
            font=ctk.CTkFont(size=12)
        )
        value_label.pack(pady=(0, 15))
        
        self.resource_monitors[resource_id] = {
            "progress": progress,
            "label": value_label
        }
        
        return frame
    
    def _create_quick_stats_section(self):
        """Create quick statistics section"""
        section_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        section_frame.pack(fill="x", padx=20, pady=10)
        
        # Section title
        title = ctk.CTkLabel(
            section_frame,
            text="Quick Statistics",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.pack(anchor="w", padx=20, pady=(15, 10))
        
        # Stats grid
        stats_frame = ctk.CTkFrame(section_frame, fg_color="transparent")
        stats_frame.pack(fill="x", padx=20, pady=(0, 15))
        
        stats = [
            ("Uptime", "0h 0m", "uptime"),
            ("Total Requests", "0", "requests"),
            ("Active Connections", "0", "connections"),
            ("Database Size", "0 MB", "db_size"),
            ("PHP Version", "Checking...", "php_version"),
            ("PHP Memory Limit", "Checking...", "php_memory")
        ]
        
        for i, (label, value, stat_id) in enumerate(stats):
            stat_widget = self._create_stat_widget(stats_frame, label, value, stat_id)
            stat_widget.grid(row=i//3, column=i%3, padx=10, pady=5, sticky="ew")
            stats_frame.grid_columnconfigure(i%3, weight=1)
    
    def _create_stat_widget(self, parent, label: str, value: str, stat_id: str):
        """Create a statistics widget"""
        frame = ctk.CTkFrame(parent, corner_radius=8)
        
        label_text = ctk.CTkLabel(
            frame,
            text=label,
            font=ctk.CTkFont(size=12),
            text_color=("gray60", "gray40")
        )
        label_text.pack(pady=(10, 0))
        
        value_text = ctk.CTkLabel(
            frame,
            text=value,
            font=ctk.CTkFont(size=20, weight="bold")
        )
        value_text.pack(pady=(0, 10))
        
        self.stats_labels[stat_id] = value_text
        
        return frame
    
    def _create_quick_actions_section(self):
        """Create quick actions section"""
        section_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        section_frame.pack(fill="x", padx=20, pady=10)
        
        # Section title
        title = ctk.CTkLabel(
            section_frame,
            text="Quick Actions",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.pack(anchor="w", padx=20, pady=(15, 10))
        
        # Actions container
        actions_frame = ctk.CTkFrame(section_frame, fg_color="transparent")
        actions_frame.pack(fill="x", padx=20, pady=(0, 15))
        
        actions = [
            ("Start All Services", self._start_all),
            ("Stop All Services", self._stop_all),
            ("Restart All Services", self._restart_all),
            ("Open Localhost", self._open_localhost),
            ("Open phpMyAdmin", self._open_phpmyadmin),
            ("View Logs", self._view_logs)
        ]
        
        for i, (text, command) in enumerate(actions):
            btn = ctk.CTkButton(
                actions_frame,
                text=text,
                command=command
            )
            btn.grid(row=i//3, column=i%3, padx=5, pady=5, sticky="ew")
            actions_frame.grid_columnconfigure(i%3, weight=1)
    
    def _start_monitoring(self):
        """Start resource monitoring thread"""
        def monitor():
            while True:
                try:
                    # Update CPU usage
                    cpu_percent = psutil.cpu_percent(interval=1)
                    self._update_resource_meter("cpu", cpu_percent)
                    
                    # Update memory usage
                    mem = psutil.virtual_memory()
                    self._update_resource_meter("memory", mem.percent)
                    
                    # Update disk usage
                    disk = psutil.disk_usage("C:\\")
                    self._update_resource_meter("disk", disk.percent)
                    
                    time.sleep(2)
                except Exception as e:
                    self.logger.error(f"Resource monitoring error: {e}")
                    time.sleep(5)
        
        monitor_thread = threading.Thread(target=monitor, daemon=True)
        monitor_thread.start()
    
    def _update_resource_meter(self, resource_id: str, value: float):
        """Update a resource meter (thread-safe)"""
        # Schedule update in main thread
        self.parent.after(0, self._update_resource_meter_impl, resource_id, value)
    
    def _update_resource_meter_impl(self, resource_id: str, value: float):
        """Implementation of resource meter update (runs in main thread)"""
        if resource_id in self.resource_monitors:
            monitor = self.resource_monitors[resource_id]
            monitor["progress"].set(value / 100)
            monitor["label"].configure(text=f"{value:.1f}%")
            
            # Update color based on value
            if value > 80:
                monitor["label"].configure(text_color="red")
            elif value > 60:
                monitor["label"].configure(text_color="orange")
            else:
                monitor["label"].configure(text_color="green")
    
    def update_service_status(self, service_id: str, status: str):
        """Update service status indicator (thread-safe)"""
        # Schedule update in main thread
        self.parent.after(0, self._update_service_status_impl, service_id, status)
    
    def _update_service_status_impl(self, service_id: str, status: str):
        """Implementation of service status update (runs in main thread)"""
        if service_id in self.service_status:
            service = self.service_status[service_id]
            
            # Update color
            if status == "running":
                color = "#00ff00"  # Green
                text = "Running"
            elif status == "stopped":
                color = "#ff0000"  # Red
                text = "Stopped"
            else:
                color = "#ffff00"  # Yellow
                text = "Unknown"
            
            service["canvas"].itemconfig(service["indicator"], fill=color)
            service["label"].configure(text=text)
    
    def _control_service(self, service_id: str, action: str):
        """Control a service (start/stop)"""
        # Special case for 'stop' to avoid 'Stoping'
        if action == "stop":
            self.logger.info(f"Stopping {service_id}...")
        else:
            self.logger.info(f"{action.capitalize()}ing {service_id}...")
        
        # Delegate to the service panel which has the actual implementation
        if hasattr(self, 'service_panel'):
            self.service_panel._control_service(service_id, action)
    
    def _start_all(self):
        """Start all services"""
        self.logger.info("Starting all services...")
    
    def _stop_all(self):
        """Stop all services"""
        self.logger.info("Stopping all services...")
    
    def _restart_all(self):
        """Restart all services"""
        self.logger.info("Restarting all services...")
    
    def _open_localhost(self):
        """Open localhost in browser"""
        import webbrowser
        webbrowser.open("http://localhost")
    
    def _open_phpmyadmin(self):
        """Open phpMyAdmin in browser"""
        import webbrowser
        webbrowser.open("http://localhost/phpmyadmin")
    
    def _view_logs(self):
        """Switch to logs view"""
        # This will be handled by the main window
        pass
    
    def show(self):
        """Show the dashboard"""
        self.frame.grid(row=0, column=0, sticky="nsew", padx=0, pady=0)
        self._update_php_info()
    
    def _update_php_info(self):
        """Update PHP information in stats"""
        def get_php_info():
            try:
                # Get PHP version
                php_exe = "C:\\isotone\\php\\php.exe"
                if os.path.exists(php_exe):
                    result = subprocess.run(
                        [php_exe, "-v"],
                        capture_output=True,
                        text=True,
                        timeout=5
                    )
                    if result.returncode == 0:
                        # Extract version from first line
                        first_line = result.stdout.split('\n')[0]
                        if 'PHP' in first_line:
                            version = first_line.split()[1]
                            # Update in main thread
                            self.parent.after(0, lambda: self._update_stat_value("php_version", version))
                        
                    # Get memory limit
                    result = subprocess.run(
                        [php_exe, "-r", "echo ini_get('memory_limit');"],
                        capture_output=True,
                        text=True,
                        timeout=5
                    )
                    if result.returncode == 0:
                        memory_limit = result.stdout.strip()
                        # Update in main thread
                        self.parent.after(0, lambda: self._update_stat_value("php_memory", memory_limit))
                else:
                    self.parent.after(0, lambda: self._update_stat_value("php_version", "Not found"))
                    self.parent.after(0, lambda: self._update_stat_value("php_memory", "N/A"))
            except Exception as e:
                self.logger.error(f"Error getting PHP info: {e}")
                self.parent.after(0, lambda: self._update_stat_value("php_version", "Error"))
                self.parent.after(0, lambda: self._update_stat_value("php_memory", "Error"))
        
        # Run in background thread
        thread = threading.Thread(target=get_php_info, daemon=True)
        thread.start()
    
    def _update_stat_value(self, stat_id: str, value: str):
        """Update a stat value in the UI"""
        if stat_id in self.stats_labels:
            self.stats_labels[stat_id].configure(text=value)
    
    def hide(self):
        """Hide the dashboard"""
        self.frame.grid_forget()
    
    def refresh(self):
        """Refresh dashboard data"""
        self.logger.info("Refreshing dashboard...")
        self._update_php_info()