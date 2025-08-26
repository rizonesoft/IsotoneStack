"""
Main window UI component with sidebar navigation
"""

import customtkinter as ctk
from typing import Dict, Any
import tkinter as tk

from .sidebar import Sidebar
from .dashboard import Dashboard
from .service_panel import ServicePanel
from .vhosts_manager import VHostsManager
from .database_manager import DatabaseManager
from .port_manager import PortManager
from .settings_page import SettingsPage
from .logs_viewer import LogsViewer

class MainWindow:
    def __init__(self, root: ctk.CTk, config: Any, logger: Any):
        self.root = root
        self.config = config
        self.logger = logger
        self.current_page = "dashboard"
        self.pages = {}
        
        # Configure grid
        self.root.grid_rowconfigure(0, weight=1)
        self.root.grid_columnconfigure(1, weight=1)
        
        # Create UI components
        self._create_sidebar()
        self._create_content_area()
        self._create_pages()
        
        # Show default page
        self.show_page("dashboard")
    
    def _create_sidebar(self):
        """Create the sidebar navigation"""
        self.sidebar = Sidebar(
            self.root,
            on_page_select=self.show_page,
            config=self.config
        )
        self.sidebar.frame.grid(row=0, column=0, sticky="nsew")
    
    def _create_content_area(self):
        """Create the main content area"""
        self.content_frame = ctk.CTkFrame(self.root, corner_radius=0)
        self.content_frame.grid(row=0, column=1, sticky="nsew", padx=0, pady=0)
        self.content_frame.grid_rowconfigure(0, weight=1)
        self.content_frame.grid_columnconfigure(0, weight=1)
    
    def _create_pages(self):
        """Create all page frames"""
        # Dashboard
        self.pages["dashboard"] = Dashboard(
            self.content_frame,
            self.config,
            self.logger
        )
        
        # Service Control
        self.pages["services"] = ServicePanel(
            self.content_frame,
            self.config,
            self.logger
        )
        self.service_panel = self.pages["services"]  # Quick reference
        
        # Virtual Hosts Manager
        self.pages["vhosts"] = VHostsManager(
            self.content_frame,
            self.config,
            self.logger
        )
        
        # Database Manager
        self.pages["database"] = DatabaseManager(
            self.content_frame,
            self.config,
            self.logger
        )
        
        # Port Manager
        self.pages["ports"] = PortManager(
            self.content_frame,
            self.config,
            self.logger
        )
        
        # Logs Viewer
        self.pages["logs"] = LogsViewer(
            self.content_frame,
            self.config,
            self.logger
        )
        
        # Settings
        self.pages["settings"] = SettingsPage(
            self.content_frame,
            self.config,
            self.logger,
            on_theme_change=self.change_theme
        )
    
    def show_page(self, page_name: str):
        """Show a specific page"""
        # Hide all pages
        for name, page in self.pages.items():
            page.hide()
        
        # Show selected page
        if page_name in self.pages:
            self.pages[page_name].show()
            self.current_page = page_name
            
            # Update sidebar selection
            self.sidebar.set_active(page_name)
            
            # Refresh page if it has a refresh method
            if hasattr(self.pages[page_name], 'refresh'):
                self.pages[page_name].refresh()
    
    def update_service_status(self, service_name: str, status: str):
        """Update service status in relevant pages"""
        # Update dashboard
        if "dashboard" in self.pages:
            self.pages["dashboard"].update_service_status(service_name, status)
        
        # Update service panel
        if "services" in self.pages:
            self.pages["services"].update_service_status(service_name, status)
    
    def change_theme(self, theme: str):
        """Change the application theme"""
        ctk.set_appearance_mode(theme)
        
        # Update all pages
        for page in self.pages.values():
            if hasattr(page, 'update_theme'):
                page.update_theme(theme)