"""
Database Manager for MariaDB
"""

import customtkinter as ctk
from typing import List, Dict, Any
import pymysql

class DatabaseManager:
    def __init__(self, parent, config, logger):
        self.parent = parent
        self.config = config
        self.logger = logger
        self.connection = None
        
        # Create main frame
        self.frame = ctk.CTkFrame(parent, corner_radius=0)
        
        # Create UI
        self._create_header()
        self._create_connection_panel()
        self._create_database_list()
        self._create_query_panel()
        
        # Hide initially
        self.hide()
    
    def _create_header(self):
        header = ctk.CTkFrame(self.frame, corner_radius=10)
        header.pack(fill="x", padx=20, pady=(20, 10))
        
        title = ctk.CTkLabel(
            header,
            text="Database Manager",
            font=ctk.CTkFont(size=24, weight="bold")
        )
        title.pack(side="left", padx=20, pady=15)
        
        # phpMyAdmin button
        pma_btn = ctk.CTkButton(
            header,
            text="Open phpMyAdmin",
            command=self._open_phpmyadmin
        )
        pma_btn.pack(side="right", padx=20)
    
    def _create_connection_panel(self):
        panel = ctk.CTkFrame(self.frame, corner_radius=10)
        panel.pack(fill="x", padx=20, pady=10)
        
        # Connection status
        self.status_label = ctk.CTkLabel(
            panel,
            text="⛔ Not Connected",
            font=ctk.CTkFont(size=14)
        )
        self.status_label.pack(pady=10)
        
        # Connect button
        self.connect_btn = ctk.CTkButton(
            panel,
            text="Connect to Database",
            command=self._toggle_connection
        )
        self.connect_btn.pack(pady=(0, 10))
    
    def _create_database_list(self):
        list_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        list_frame.pack(fill="both", expand=True, padx=20, pady=10)
        
        title = ctk.CTkLabel(
            list_frame,
            text="Databases",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.pack(pady=10)
        
        # Database listbox
        self.db_listbox = tk.Listbox(
            list_frame,
            bg="gray20",
            fg="white",
            selectmode="single"
        )
        self.db_listbox.pack(fill="both", expand=True, padx=20, pady=(0, 20))
        
        # Database actions
        actions = ctk.CTkFrame(list_frame, fg_color="transparent")
        actions.pack(pady=(0, 10))
        
        ctk.CTkButton(actions, text="Create Database", width=120).pack(side="left", padx=2)
        ctk.CTkButton(actions, text="Drop Database", width=120, fg_color="red").pack(side="left", padx=2)
        ctk.CTkButton(actions, text="Backup", width=120).pack(side="left", padx=2)
        ctk.CTkButton(actions, text="Restore", width=120).pack(side="left", padx=2)
    
    def _create_query_panel(self):
        panel = ctk.CTkFrame(self.frame, corner_radius=10)
        panel.pack(fill="x", padx=20, pady=10)
        
        title = ctk.CTkLabel(
            panel,
            text="Quick Query",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.pack(pady=10)
        
        # Query input
        self.query_text = ctk.CTkTextbox(
            panel,
            height=100,
            font=ctk.CTkFont(family="Consolas", size=12)
        )
        self.query_text.pack(fill="x", padx=20, pady=(0, 10))
        
        # Execute button
        ctk.CTkButton(
            panel,
            text="Execute Query",
            command=self._execute_query
        ).pack(pady=(0, 20))
    
    def _toggle_connection(self):
        if self.connection:
            self._disconnect()
        else:
            self._connect()
    
    def _connect(self):
        try:
            db_config = self.config.get("database")
            self.connection = pymysql.connect(
                host=db_config["host"],
                port=db_config["port"],
                user=db_config["user"],
                password=db_config["password"]
            )
            self.status_label.configure(text="✅ Connected", text_color="green")
            self.connect_btn.configure(text="Disconnect")
            self._load_databases()
        except Exception as e:
            self.logger.error(f"Database connection failed: {e}")
            self.status_label.configure(text="❌ Connection Failed", text_color="red")
    
    def _disconnect(self):
        if self.connection:
            self.connection.close()
            self.connection = None
        self.status_label.configure(text="⛔ Not Connected", text_color="gray")
        self.connect_btn.configure(text="Connect to Database")
        self.db_listbox.delete(0, tk.END)
    
    def _load_databases(self):
        if not self.connection:
            return
        
        try:
            with self.connection.cursor() as cursor:
                cursor.execute("SHOW DATABASES")
                databases = cursor.fetchall()
                
                self.db_listbox.delete(0, tk.END)
                for db in databases:
                    self.db_listbox.insert(tk.END, db[0])
        except Exception as e:
            self.logger.error(f"Failed to load databases: {e}")
    
    def _execute_query(self):
        # Implementation for query execution
        pass
    
    def _open_phpmyadmin(self):
        import webbrowser
        webbrowser.open("http://localhost/phpmyadmin")
    
    def show(self):
        self.frame.grid(row=0, column=0, sticky="nsew", padx=0, pady=0)
    
    def hide(self):
        self.frame.grid_forget()

import tkinter as tk  # Add this import