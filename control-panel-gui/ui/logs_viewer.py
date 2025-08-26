"""
Logs viewer for service logs
"""

import customtkinter as ctk
from pathlib import Path
import threading

class LogsViewer:
    def __init__(self, parent, config, logger):
        self.parent = parent
        self.config = config
        self.logger = logger
        self.current_log = None
        self.auto_scroll = True
        
        # Create main frame
        self.frame = ctk.CTkFrame(parent, corner_radius=0)
        self.frame.grid_rowconfigure(1, weight=1)
        self.frame.grid_columnconfigure(0, weight=1)
        
        # Create UI
        self._create_header()
        self._create_log_viewer()
        
        # Hide initially
        self.hide()
    
    def _create_header(self):
        header = ctk.CTkFrame(self.frame, corner_radius=10)
        header.grid(row=0, column=0, sticky="ew", padx=20, pady=(20, 10))
        
        title = ctk.CTkLabel(
            header,
            text="Logs Viewer",
            font=ctk.CTkFont(size=24, weight="bold")
        )
        title.pack(side="left", padx=20, pady=15)
        
        # Log selector
        self.log_var = ctk.StringVar(value="Apache Error")
        log_menu = ctk.CTkOptionMenu(
            header,
            values=[
                "Apache Error",
                "Apache Access",
                "PHP Error",
                "MariaDB Error",
                "MariaDB Slow Query"
            ],
            variable=self.log_var,
            command=self._change_log
        )
        log_menu.pack(side="left", padx=20)
        
        # Controls
        controls = ctk.CTkFrame(header, fg_color="transparent")
        controls.pack(side="right", padx=20)
        
        # Auto-scroll toggle
        self.auto_scroll_var = ctk.BooleanVar(value=True)
        auto_scroll_check = ctk.CTkCheckBox(
            controls,
            text="Auto-scroll",
            variable=self.auto_scroll_var
        )
        auto_scroll_check.pack(side="left", padx=5)
        
        # Clear button
        clear_btn = ctk.CTkButton(
            controls,
            text="Clear",
            width=60,
            command=self._clear_log
        )
        clear_btn.pack(side="left", padx=5)
        
        # Refresh button
        refresh_btn = ctk.CTkButton(
            controls,
            text="🔄",
            width=40,
            command=self._load_current_log
        )
        refresh_btn.pack(side="left", padx=5)
    
    def _create_log_viewer(self):
        # Log text widget
        self.log_text = ctk.CTkTextbox(
            self.frame,
            font=ctk.CTkFont(family="Consolas", size=12),
            wrap="none"
        )
        self.log_text.grid(row=1, column=0, sticky="nsew", padx=20, pady=(0, 20))
    
    def _change_log(self, log_name: str):
        """Change the displayed log file"""
        log_paths = {
            "Apache Error": "logs/apache/error.log",
            "Apache Access": "logs/apache/access.log",
            "PHP Error": "logs/php/error.log",
            "MariaDB Error": "logs/mariadb/error.log",
            "MariaDB Slow Query": "logs/mariadb/slow-query.log"
        }
        
        relative_path = log_paths.get(log_name)
        if relative_path:
            self.current_log = self.config.get_isotone_path() / relative_path
            self._load_current_log()
    
    def _load_current_log(self):
        """Load and display the current log file"""
        if not self.current_log:
            self._change_log(self.log_var.get())
            return
        
        def load():
            try:
                if self.current_log.exists():
                    with open(self.current_log, 'r', encoding='utf-8', errors='ignore') as f:
                        # Read last 1000 lines
                        lines = f.readlines()[-1000:]
                        content = ''.join(lines)
                        
                        # Update text widget in main thread
                        self.log_text.delete("1.0", "end")
                        self.log_text.insert("1.0", content)
                        
                        if self.auto_scroll_var.get():
                            self.log_text.see("end")
                else:
                    self.log_text.delete("1.0", "end")
                    self.log_text.insert("1.0", f"Log file not found: {self.current_log}")
                    
            except Exception as e:
                self.logger.error(f"Error loading log: {e}")
                self.log_text.delete("1.0", "end")
                self.log_text.insert("1.0", f"Error loading log: {e}")
        
        # Load in thread to avoid blocking
        thread = threading.Thread(target=load, daemon=True)
        thread.start()
    
    def _clear_log(self):
        """Clear the log display"""
        self.log_text.delete("1.0", "end")
    
    def show(self):
        self.frame.grid(row=0, column=0, sticky="nsew", padx=0, pady=0)
        self._load_current_log()
    
    def hide(self):
        self.frame.grid_forget()
    
    def refresh(self):
        """Refresh the current log"""
        self._load_current_log()