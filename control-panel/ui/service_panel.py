"""
Service control panel with animated buttons and status indicators
"""

import customtkinter as ctk
import tkinter as tk
from typing import Dict, Any
import subprocess
import threading
import time

class ServicePanel:
    def __init__(self, parent, config, logger):
        self.parent = parent
        self.config = config
        self.logger = logger
        self.services = {}
        self.animating = {}
        
        # Create main frame
        self.frame = ctk.CTkScrollableFrame(parent, corner_radius=0)
        
        # Create UI
        self._create_header()
        self._create_service_controls()
        self._create_batch_controls()
        
        # Hide initially
        self.hide()
    
    def _create_header(self):
        """Create service panel header"""
        header_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        header_frame.pack(fill="x", padx=20, pady=(20, 10))
        
        # Title
        title = ctk.CTkLabel(
            header_frame,
            text="Service Management",
            font=ctk.CTkFont(size=24, weight="bold")
        )
        title.pack(side="left", padx=20, pady=15)
        
        # Status summary
        self.summary_label = ctk.CTkLabel(
            header_frame,
            text="Loading services...",
            font=ctk.CTkFont(size=14)
        )
        self.summary_label.pack(side="right", padx=20)
    
    def _create_service_controls(self):
        """Create individual service control panels"""
        services_info = [
            {
                "id": "apache",
                "name": "Apache HTTP Server",
                "service": "IsotoneApache",
                "description": "Web server handling HTTP requests",
                "port": "80, 443",
                "config": "C:\\isotone\\apache24\\conf\\httpd.conf"
            },
            {
                "id": "mariadb",
                "name": "MariaDB Database",
                "service": "IsotoneMariaDB",
                "description": "MySQL-compatible database server",
                "port": "3306",
                "config": "C:\\isotone\\mariadb\\my.ini"
            },
            {
                "id": "mailpit",
                "name": "Mailpit Email Testing",
                "service": "IsotoneMailpit",
                "description": "Email testing server for development",
                "port": "1025 (SMTP), 8025 (Web)",
                "config": "C:\\isotone\\mailpit\\data\\mailpit.db"
            }
        ]
        
        for service_info in services_info:
            service_frame = self._create_service_card(service_info)
            service_frame.pack(fill="x", padx=20, pady=10)
    
    def _create_service_card(self, service_info: Dict):
        """Create a service control card"""
        # Main card frame
        card = ctk.CTkFrame(self.frame, corner_radius=10)
        
        # Status indicator
        status_frame = ctk.CTkFrame(card, width=10, corner_radius=0)
        status_frame.pack(side="left", fill="y")
        status_frame.configure(fg_color="gray")
        
        # Content frame
        content_frame = ctk.CTkFrame(card, fg_color="transparent")
        content_frame.pack(side="left", fill="both", expand=True, padx=20, pady=15)
        
        # Service name and status
        header_frame = ctk.CTkFrame(content_frame, fg_color="transparent")
        header_frame.pack(fill="x")
        
        name_label = ctk.CTkLabel(
            header_frame,
            text=service_info["name"],
            font=ctk.CTkFont(size=18, weight="bold")
        )
        name_label.pack(side="left")
        
        status_label = ctk.CTkLabel(
            header_frame,
            text="● Stopped",
            font=ctk.CTkFont(size=14),
            text_color="red"
        )
        status_label.pack(side="left", padx=(20, 0))
        
        # Description
        desc_label = ctk.CTkLabel(
            content_frame,
            text=service_info["description"],
            font=ctk.CTkFont(size=12),
            text_color=("gray60", "gray40"),
            anchor="w"
        )
        desc_label.pack(fill="x", pady=(5, 0))
        
        # Info frame
        info_frame = ctk.CTkFrame(content_frame, fg_color="transparent")
        info_frame.pack(fill="x", pady=(10, 0))
        
        # Port info
        port_label = ctk.CTkLabel(
            info_frame,
            text=f"Port: {service_info['port']}",
            font=ctk.CTkFont(size=12),
            text_color=("gray60", "gray40")
        )
        port_label.pack(side="left", padx=(0, 20))
        
        # Config link
        config_btn = ctk.CTkButton(
            info_frame,
            text="📝 Edit Config",
            width=100,
            height=25,
            font=ctk.CTkFont(size=12),
            command=lambda: self._open_config(service_info["config"])
        )
        config_btn.pack(side="left")
        
        # Control buttons frame
        controls_frame = ctk.CTkFrame(card, fg_color="transparent")
        controls_frame.pack(side="right", padx=20)
        
        # Control buttons with animations
        start_btn = ctk.CTkButton(
            controls_frame,
            text="▶ Start",
            width=80,
            height=35,
            fg_color="green",
            hover_color="dark green",
            command=lambda: self._control_service(service_info["id"], "start")
        )
        start_btn.pack(pady=2)
        
        stop_btn = ctk.CTkButton(
            controls_frame,
            text="■ Stop",
            width=80,
            height=35,
            fg_color="red",
            hover_color="dark red",
            command=lambda: self._control_service(service_info["id"], "stop")
        )
        stop_btn.pack(pady=2)
        
        restart_btn = ctk.CTkButton(
            controls_frame,
            text="↻ Restart",
            width=80,
            height=35,
            fg_color="orange",
            hover_color="dark orange",
            command=lambda: self._control_service(service_info["id"], "restart")
        )
        restart_btn.pack(pady=2)
        
        # Store references
        self.services[service_info["id"]] = {
            "info": service_info,
            "status_frame": status_frame,
            "status_label": status_label,
            "start_btn": start_btn,
            "stop_btn": stop_btn,
            "restart_btn": restart_btn
        }
        
        return card
    
    def _create_batch_controls(self):
        """Create batch control buttons"""
        batch_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        batch_frame.pack(fill="x", padx=20, pady=(10, 20))
        
        # Title
        title = ctk.CTkLabel(
            batch_frame,
            text="Batch Operations",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        title.pack(pady=(15, 10))
        
        # Buttons container
        buttons_frame = ctk.CTkFrame(batch_frame, fg_color="transparent")
        buttons_frame.pack(pady=(0, 15))
        
        # Batch control buttons
        start_all_btn = ctk.CTkButton(
            buttons_frame,
            text="▶ Start All Services",
            width=150,
            height=40,
            fg_color="green",
            hover_color="dark green",
            command=self.start_all_services
        )
        start_all_btn.pack(side="left", padx=5)
        
        stop_all_btn = ctk.CTkButton(
            buttons_frame,
            text="■ Stop All Services",
            width=150,
            height=40,
            fg_color="red",
            hover_color="dark red",
            command=self.stop_all_services
        )
        stop_all_btn.pack(side="left", padx=5)
        
        restart_all_btn = ctk.CTkButton(
            buttons_frame,
            text="↻ Restart All Services",
            width=150,
            height=40,
            fg_color="orange",
            hover_color="dark orange",
            command=self.restart_all_services
        )
        restart_all_btn.pack(side="left", padx=5)
    
    def _control_service(self, service_id: str, action: str):
        """Control a service with animation"""
        if service_id in self.animating and self.animating[service_id]:
            return  # Already animating
        
        self.animating[service_id] = True
        service = self.services[service_id]
        
        # Disable buttons during operation
        service["start_btn"].configure(state="disabled")
        service["stop_btn"].configure(state="disabled")
        service["restart_btn"].configure(state="disabled")
        
        # Start animation
        self._animate_button(service[f"{action}_btn"])
        
        # Run service control in thread
        thread = threading.Thread(
            target=self._execute_service_control,
            args=(service_id, action)
        )
        thread.start()
    
    def _execute_service_control(self, service_id: str, action: str):
        """Execute service control command"""
        service = self.services[service_id]
        service_name = service["info"]["service"]
        
        try:
            # Update status to show operation in progress
            self.parent.after(0, self._update_service_status_impl, service_id, "pending")
            
            if action == "start":
                # First check if service is already running
                check_result = subprocess.run(f"sc query {service_name}", shell=True, capture_output=True, text=True)
                if "RUNNING" in check_result.stdout:
                    self.logger.info(f"{service_name} is already running")
                    self.update_service_status(service_id, "running")
                else:
                    result = subprocess.run(f"net start {service_name}", shell=True, capture_output=True, text=True)
                    if result.returncode == 0 or "already been started" in result.stdout:
                        self.update_service_status(service_id, "running")
                        self.logger.info(f"Started {service_name} successfully")
                    else:
                        self.logger.error(f"Failed to start {service_name}: {result.stderr or result.stdout}")
                        self.update_service_status(service_id, "stopped")
                        
            elif action == "stop":
                # First check if service is already stopped
                check_result = subprocess.run(f"sc query {service_name}", shell=True, capture_output=True, text=True)
                if "STOPPED" in check_result.stdout:
                    self.logger.info(f"{service_name} is already stopped")
                    self.update_service_status(service_id, "stopped")
                else:
                    result = subprocess.run(f"net stop {service_name}", shell=True, capture_output=True, text=True)
                    if result.returncode == 0 or "is not started" in result.stdout:
                        self.update_service_status(service_id, "stopped")
                        self.logger.info(f"Stopped {service_name} successfully")
                    else:
                        self.logger.error(f"Failed to stop {service_name}: {result.stderr or result.stdout}")
                        # Check actual status after failed stop
                        time.sleep(1)
                        check_result = subprocess.run(f"sc query {service_name}", shell=True, capture_output=True, text=True)
                        if "STOPPED" in check_result.stdout:
                            self.update_service_status(service_id, "stopped")
                        else:
                            self.update_service_status(service_id, "running")
                            
            elif action == "restart":
                # Windows doesn't have restart, so stop then start
                # First stop the service
                stop_result = subprocess.run(f"net stop {service_name}", shell=True, capture_output=True, text=True)
                time.sleep(2)
                # Then start it
                start_result = subprocess.run(f"net start {service_name}", shell=True, capture_output=True, text=True)
                if start_result.returncode == 0 or "already been started" in start_result.stdout:
                    self.update_service_status(service_id, "running")
                    self.logger.info(f"Restarted {service_name} successfully")
                else:
                    self.logger.error(f"Failed to restart {service_name}: {start_result.stderr or start_result.stdout}")
                    self.update_service_status(service_id, "stopped")
                
        except Exception as e:
            self.logger.error(f"Error controlling service {service_name}: {e}")
            # Check actual status on error
            try:
                result = subprocess.run(f"sc query {service_name}", shell=True, capture_output=True, text=True)
                if "RUNNING" in result.stdout:
                    self.update_service_status(service_id, "running")
                else:
                    self.update_service_status(service_id, "stopped")
            except:
                self.update_service_status(service_id, "unknown")
        
        finally:
            # Re-enable buttons in main thread
            def re_enable_buttons():
                service["start_btn"].configure(state="normal")
                service["stop_btn"].configure(state="normal")
                service["restart_btn"].configure(state="normal")
                self.animating[service_id] = False
            
            self.parent.after(0, re_enable_buttons)
    
    def _animate_button(self, button: ctk.CTkButton):
        """Animate a button during operation (thread-safe)"""
        original_text = button.cget("text")
        
        # Find which service this button belongs to
        service_id = None
        for sid, service in self.services.items():
            if button in [service["start_btn"], service["stop_btn"], service["restart_btn"]]:
                service_id = sid
                break
        
        if not service_id:
            return
        
        def animate():
            dots = 0
            while self.animating.get(service_id, False):
                dots = (dots + 1) % 4
                # Use after() to update button text in main thread
                self.parent.after(0, lambda t=original_text + "." * dots: button.configure(text=t))
                time.sleep(0.5)
            # Reset text in main thread
            self.parent.after(0, lambda: button.configure(text=original_text))
        
        thread = threading.Thread(target=animate, daemon=True)
        thread.start()
    
    def update_service_status(self, service_id: str, status: str):
        """Update service status display (thread-safe)"""
        # Use after() to ensure UI updates happen in the main thread
        self.parent.after(0, self._update_service_status_impl, service_id, status)
    
    def _update_service_status_impl(self, service_id: str, status: str):
        """Implementation of service status update (runs in main thread)"""
        if service_id not in self.services:
            return
        
        service = self.services[service_id]
        
        if status == "running":
            service["status_frame"].configure(fg_color="green")
            service["status_label"].configure(text="● Running", text_color="green")
        elif status == "stopped":
            service["status_frame"].configure(fg_color="red")
            service["status_label"].configure(text="● Stopped", text_color="red")
        elif status == "pending":
            service["status_frame"].configure(fg_color="yellow")
            service["status_label"].configure(text="● Processing...", text_color="yellow")
        else:
            service["status_frame"].configure(fg_color="orange")
            service["status_label"].configure(text="● Unknown", text_color="orange")
        
        # Update summary
        self._update_summary()
    
    def _update_summary(self):
        """Update services summary"""
        running = sum(1 for s in self.services.values() 
                     if "Running" in s["status_label"].cget("text"))
        total = len(self.services)
        
        self.summary_label.configure(
            text=f"{running}/{total} services running",
            text_color="green" if running == total else "orange" if running > 0 else "red"
        )
    
    def start_all_services(self):
        """Start all services"""
        for service_id in self.services:
            self._control_service(service_id, "start")
            time.sleep(1)  # Stagger starts
    
    def stop_all_services(self):
        """Stop all services"""
        for service_id in self.services:
            self._control_service(service_id, "stop")
    
    def restart_all_services(self):
        """Restart all services"""
        for service_id in self.services:
            self._control_service(service_id, "restart")
            time.sleep(2)  # Stagger restarts
    
    def _open_config(self, config_path: str):
        """Open configuration file in editor"""
        try:
            import os
            os.startfile(config_path)
        except Exception as e:
            self.logger.error(f"Failed to open config: {e}")
    
    def show(self):
        """Show the service panel"""
        self.frame.grid(row=0, column=0, sticky="nsew", padx=0, pady=0)
    
    def hide(self):
        """Hide the service panel"""
        self.frame.grid_forget()
    
    def refresh(self):
        """Refresh service status"""
        # Check actual service status
        for service_id, service in self.services.items():
            service_name = service["info"]["service"]
            try:
                result = subprocess.run(
                    f"sc query {service_name}",
                    shell=True,
                    capture_output=True,
                    text=True
                )
                if "RUNNING" in result.stdout:
                    self.update_service_status(service_id, "running")
                else:
                    self.update_service_status(service_id, "stopped")
            except:
                self.update_service_status(service_id, "unknown")