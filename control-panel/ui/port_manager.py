"""
Port Manager for checking and managing service ports
"""

import customtkinter as ctk
import psutil
import socket

class PortManager:
    def __init__(self, parent, config, logger):
        self.parent = parent
        self.config = config
        self.logger = logger
        
        # Create main frame
        self.frame = ctk.CTkScrollableFrame(parent, corner_radius=0)
        
        # Create UI
        self._create_header()
        self._create_port_list()
        
        # Hide initially
        self.hide()
    
    def _create_header(self):
        header = ctk.CTkFrame(self.frame, corner_radius=10)
        header.pack(fill="x", padx=20, pady=(20, 10))
        
        title = ctk.CTkLabel(
            header,
            text="Port Manager",
            font=ctk.CTkFont(size=24, weight="bold")
        )
        title.pack(side="left", padx=20, pady=15)
        
        # Scan button
        scan_btn = ctk.CTkButton(
            header,
            text="🔍 Scan Ports",
            command=self._scan_ports
        )
        scan_btn.pack(side="right", padx=20)
    
    def _create_port_list(self):
        # Default ports to check
        self.ports_to_check = [
            {"port": 80, "service": "HTTP (Apache)", "required": True},
            {"port": 443, "service": "HTTPS (Apache SSL)", "required": False},
            {"port": 3306, "service": "MySQL/MariaDB", "required": True},
            {"port": 8080, "service": "Alternative HTTP", "required": False},
            {"port": 9000, "service": "PHP-FPM", "required": False}
        ]
        
        self.port_widgets = {}
        
        for port_info in self.ports_to_check:
            widget = self._create_port_widget(port_info)
            widget.pack(fill="x", padx=20, pady=5)
            self.port_widgets[port_info["port"]] = widget
    
    def _create_port_widget(self, port_info):
        frame = ctk.CTkFrame(self.frame, corner_radius=10)
        
        # Port number
        port_label = ctk.CTkLabel(
            frame,
            text=f"Port {port_info['port']}",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        port_label.pack(side="left", padx=20, pady=15)
        
        # Service name
        service_label = ctk.CTkLabel(
            frame,
            text=port_info['service'],
            font=ctk.CTkFont(size=14)
        )
        service_label.pack(side="left", padx=20)
        
        # Status indicator
        status_label = ctk.CTkLabel(
            frame,
            text="Checking...",
            font=ctk.CTkFont(size=14)
        )
        status_label.pack(side="left", padx=20)
        
        # Process info
        process_label = ctk.CTkLabel(
            frame,
            text="",
            font=ctk.CTkFont(size=12),
            text_color=("gray60", "gray40")
        )
        process_label.pack(side="left", padx=20)
        
        # Action button
        action_btn = ctk.CTkButton(
            frame,
            text="Release Port",
            width=100,
            state="disabled"
        )
        action_btn.pack(side="right", padx=20)
        
        frame.status_label = status_label
        frame.process_label = process_label
        frame.action_btn = action_btn
        
        return frame
    
    def _scan_ports(self):
        """Scan all configured ports"""
        for port, widget in self.port_widgets.items():
            self._check_port(port, widget)
    
    def _check_port(self, port, widget):
        """Check if a port is in use"""
        try:
            # Check if port is in use
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            result = sock.connect_ex(('127.0.0.1', port))
            sock.close()
            
            if result == 0:
                # Port is in use
                widget.status_label.configure(
                    text="✅ In Use",
                    text_color="green"
                )
                
                # Find process using the port
                process_name = self._find_process_using_port(port)
                if process_name:
                    widget.process_label.configure(text=f"by {process_name}")
                
                widget.action_btn.configure(state="normal")
            else:
                # Port is free
                widget.status_label.configure(
                    text="⛔ Free",
                    text_color="gray"
                )
                widget.process_label.configure(text="")
                widget.action_btn.configure(state="disabled")
                
        except Exception as e:
            widget.status_label.configure(
                text="❌ Error",
                text_color="red"
            )
            self.logger.error(f"Error checking port {port}: {e}")
    
    def _find_process_using_port(self, port):
        """Find process name using a specific port"""
        try:
            for conn in psutil.net_connections():
                if conn.laddr.port == port and conn.status == 'LISTEN':
                    try:
                        process = psutil.Process(conn.pid)
                        return process.name()
                    except:
                        return f"PID {conn.pid}"
        except:
            pass
        return None
    
    def show(self):
        self.frame.grid(row=0, column=0, sticky="nsew", padx=0, pady=0)
        self._scan_ports()  # Auto-scan when shown
    
    def hide(self):
        self.frame.grid_forget()