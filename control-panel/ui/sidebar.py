"""
Sidebar navigation component with animated buttons
"""

import customtkinter as ctk
from typing import Callable, Optional
import tkinter as tk

class Sidebar:
    def __init__(self, parent: ctk.CTk, on_page_select: Callable, config: Any):
        self.parent = parent
        self.on_page_select = on_page_select
        self.config = config
        self.buttons = {}
        self.active_button = None
        
        # Create sidebar frame
        self.frame = ctk.CTkFrame(
            parent,
            width=200,
            corner_radius=0,
            fg_color=("gray20", "gray10")
        )
        self.frame.grid_propagate(False)
        
        # Create UI elements
        self._create_header()
        self._create_navigation_buttons()
        self._create_footer()
    
    def _create_header(self):
        """Create sidebar header with logo and title"""
        header_frame = ctk.CTkFrame(self.frame, corner_radius=0, fg_color="transparent")
        header_frame.pack(fill="x", padx=10, pady=(20, 30))
        
        # Logo placeholder (you can add an actual logo image here)
        logo_label = ctk.CTkLabel(
            header_frame,
            text="🚀",
            font=ctk.CTkFont(size=40)
        )
        logo_label.pack()
        
        # Title
        title_label = ctk.CTkLabel(
            header_frame,
            text="IsotoneStack",
            font=ctk.CTkFont(size=20, weight="bold")
        )
        title_label.pack(pady=(10, 0))
        
        # Version
        version_label = ctk.CTkLabel(
            header_frame,
            text="v1.0.0",
            font=ctk.CTkFont(size=12),
            text_color=("gray60", "gray40")
        )
        version_label.pack()
    
    def _create_navigation_buttons(self):
        """Create navigation buttons"""
        nav_items = [
            ("dashboard", "📊", "Dashboard"),
            ("services", "⚙️", "Services"),
            ("vhosts", "🌐", "Virtual Hosts"),
            ("database", "🗄️", "Database"),
            ("ports", "🔌", "Ports"),
            ("logs", "📝", "Logs"),
            ("settings", "⚡", "Settings")
        ]
        
        nav_frame = ctk.CTkFrame(self.frame, corner_radius=0, fg_color="transparent")
        nav_frame.pack(fill="both", expand=True, padx=10)
        
        for page_id, icon, label in nav_items:
            btn = self._create_nav_button(nav_frame, page_id, icon, label)
            btn.pack(fill="x", pady=2)
            self.buttons[page_id] = btn
    
    def _create_nav_button(self, parent, page_id: str, icon: str, label: str) -> ctk.CTkButton:
        """Create a navigation button with hover effects"""
        btn = ctk.CTkButton(
            parent,
            text=f"{icon}  {label}",
            height=40,
            corner_radius=8,
            anchor="w",
            font=ctk.CTkFont(size=14),
            fg_color="transparent",
            text_color=("gray10", "gray90"),
            hover_color=("gray70", "gray30"),
            command=lambda: self._on_button_click(page_id)
        )
        
        # Add hover effects
        btn.bind("<Enter>", lambda e: self._on_hover_enter(btn))
        btn.bind("<Leave>", lambda e: self._on_hover_leave(btn))
        
        return btn
    
    def _create_footer(self):
        """Create sidebar footer with quick actions"""
        footer_frame = ctk.CTkFrame(self.frame, corner_radius=0, fg_color="transparent")
        footer_frame.pack(fill="x", padx=10, pady=(0, 20))
        
        # Quick actions
        quick_actions_label = ctk.CTkLabel(
            footer_frame,
            text="Quick Actions",
            font=ctk.CTkFont(size=12, weight="bold"),
            text_color=("gray60", "gray40")
        )
        quick_actions_label.pack(pady=(0, 10))
        
        # Action buttons
        actions = [
            ("🌐", "Open Localhost", self._open_localhost),
            ("💾", "Open phpMyAdmin", self._open_phpmyadmin)
        ]
        
        for icon, tooltip, command in actions:
            btn = ctk.CTkButton(
                footer_frame,
                text=icon,
                width=40,
                height=40,
                corner_radius=8,
                font=ctk.CTkFont(size=18),
                command=command
            )
            btn.pack(side="left", padx=2)
    
    def _on_button_click(self, page_id: str):
        """Handle navigation button click"""
        self.on_page_select(page_id)
    
    def _on_hover_enter(self, button: ctk.CTkButton):
        """Handle mouse enter on button"""
        if button != self.active_button:
            button.configure(fg_color=("gray75", "gray25"))
    
    def _on_hover_leave(self, button: ctk.CTkButton):
        """Handle mouse leave on button"""
        if button != self.active_button:
            button.configure(fg_color="transparent")
    
    def set_active(self, page_id: str):
        """Set the active navigation button"""
        # Reset previous active button
        if self.active_button:
            self.active_button.configure(
                fg_color="transparent",
                text_color=("gray10", "gray90")
            )
        
        # Set new active button
        if page_id in self.buttons:
            self.active_button = self.buttons[page_id]
            self.active_button.configure(
                fg_color=("gray75", "gray25"),
                text_color=("gray10", "gray90")
            )
    
    def _open_localhost(self):
        """Open localhost in browser"""
        import webbrowser
        webbrowser.open("http://localhost")
    
    def _open_phpmyadmin(self):
        """Open phpMyAdmin in browser"""
        import webbrowser
        webbrowser.open("http://localhost/phpmyadmin")