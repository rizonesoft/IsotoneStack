"""
Settings page with theme switcher and preferences
"""

import customtkinter as ctk
from typing import Callable

class SettingsPage:
    def __init__(self, parent, config, logger, on_theme_change: Callable):
        self.parent = parent
        self.config = config
        self.logger = logger
        self.on_theme_change = on_theme_change
        
        # Create main frame
        self.frame = ctk.CTkScrollableFrame(parent, corner_radius=0)
        
        # Create settings sections
        self._create_header()
        self._create_appearance_settings()
        self._create_behavior_settings()
        self._create_advanced_settings()
        
        # Hide initially
        self.hide()
    
    def _create_header(self):
        header = ctk.CTkFrame(self.frame, corner_radius=10)
        header.pack(fill="x", padx=20, pady=(20, 10))
        
        title = ctk.CTkLabel(
            header,
            text="Settings",
            font=ctk.CTkFont(size=24, weight="bold")
        )
        title.pack(side="left", padx=20, pady=15)
        
        # Save button
        save_btn = ctk.CTkButton(
            header,
            text="💾 Save Settings",
            command=self._save_settings
        )
        save_btn.pack(side="right", padx=20)
    
    def _create_appearance_settings(self):
        section = ctk.CTkFrame(self.frame, corner_radius=10)
        section.pack(fill="x", padx=20, pady=10)
        
        title = ctk.CTkLabel(
            section,
            text="Appearance",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.pack(anchor="w", padx=20, pady=(15, 10))
        
        # Theme selector
        theme_frame = ctk.CTkFrame(section, fg_color="transparent")
        theme_frame.pack(fill="x", padx=20, pady=5)
        
        ctk.CTkLabel(theme_frame, text="Theme:").pack(side="left", padx=(0, 20))
        
        self.theme_var = ctk.StringVar(value=self.config.get("theme", "dark"))
        theme_menu = ctk.CTkOptionMenu(
            theme_frame,
            values=["dark", "light", "system"],
            variable=self.theme_var,
            command=self._change_theme
        )
        theme_menu.pack(side="left")
        
        # Color theme
        color_frame = ctk.CTkFrame(section, fg_color="transparent")
        color_frame.pack(fill="x", padx=20, pady=(5, 15))
        
        ctk.CTkLabel(color_frame, text="Color:").pack(side="left", padx=(0, 20))
        
        self.color_var = ctk.StringVar(value="blue")
        color_menu = ctk.CTkOptionMenu(
            color_frame,
            values=["blue", "green", "dark-blue"],
            variable=self.color_var
        )
        color_menu.pack(side="left")
    
    def _create_behavior_settings(self):
        section = ctk.CTkFrame(self.frame, corner_radius=10)
        section.pack(fill="x", padx=20, pady=10)
        
        title = ctk.CTkLabel(
            section,
            text="Behavior",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.pack(anchor="w", padx=20, pady=(15, 10))
        
        # Settings checkboxes
        settings = [
            ("minimize_to_tray", "Minimize to system tray"),
            ("auto_start_services", "Auto-start services on launch"),
            ("auto_start_with_windows", "Start with Windows"),
            ("check_for_updates", "Check for updates automatically")
        ]
        
        self.checkboxes = {}
        for key, label in settings:
            var = ctk.BooleanVar(value=self.config.get(key, False))
            checkbox = ctk.CTkCheckBox(
                section,
                text=label,
                variable=var
            )
            checkbox.pack(anchor="w", padx=40, pady=5)
            self.checkboxes[key] = var
        
        # Add padding at bottom
        ctk.CTkLabel(section, text="").pack(pady=5)
    
    def _create_advanced_settings(self):
        section = ctk.CTkFrame(self.frame, corner_radius=10)
        section.pack(fill="x", padx=20, pady=10)
        
        title = ctk.CTkLabel(
            section,
            text="Advanced",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.pack(anchor="w", padx=20, pady=(15, 10))
        
        # Log level
        log_frame = ctk.CTkFrame(section, fg_color="transparent")
        log_frame.pack(fill="x", padx=20, pady=5)
        
        ctk.CTkLabel(log_frame, text="Log Level:").pack(side="left", padx=(20, 20))
        
        self.log_level_var = ctk.StringVar(value=self.config.get("log_level", "INFO"))
        log_menu = ctk.CTkOptionMenu(
            log_frame,
            values=["DEBUG", "INFO", "WARNING", "ERROR"],
            variable=self.log_level_var
        )
        log_menu.pack(side="left")
        
        # Paths
        paths_frame = ctk.CTkFrame(section, fg_color="transparent")
        paths_frame.pack(fill="x", padx=20, pady=(10, 15))
        
        ctk.CTkLabel(
            paths_frame,
            text="IsotoneStack Path:",
            font=ctk.CTkFont(size=12)
        ).pack(anchor="w", padx=20)
        
        path_entry = ctk.CTkEntry(
            paths_frame,
            width=400,
            placeholder_text=self.config.get("isotone_path", "C:\\isotone")
        )
        path_entry.pack(padx=40, pady=5)
        
        # Reset button
        reset_btn = ctk.CTkButton(
            section,
            text="Reset to Defaults",
            fg_color="red",
            command=self._reset_settings
        )
        reset_btn.pack(pady=(10, 20))
    
    def _change_theme(self, theme: str):
        """Change application theme"""
        ctk.set_appearance_mode(theme)
        self.on_theme_change(theme)
        self.logger.info(f"Theme changed to: {theme}")
    
    def _save_settings(self):
        """Save all settings"""
        # Save theme
        self.config.set("theme", self.theme_var.get())
        
        # Save checkboxes
        for key, var in self.checkboxes.items():
            self.config.set(key, var.get())
        
        # Save log level
        self.config.set("log_level", self.log_level_var.get())
        
        # Apply auto-start if enabled
        if self.checkboxes["auto_start_with_windows"].get():
            self._enable_auto_start()
        else:
            self._disable_auto_start()
        
        self.logger.info("Settings saved")
    
    def _enable_auto_start(self):
        """Enable auto-start with Windows"""
        try:
            import winreg
            key = winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                r"Software\Microsoft\Windows\CurrentVersion\Run",
                0,
                winreg.KEY_SET_VALUE
            )
            winreg.SetValueEx(
                key,
                "IsotoneStack",
                0,
                winreg.REG_SZ,
                f"{self.config.get_isotone_path()}\\control-panel-gui\\main.py"
            )
            winreg.CloseKey(key)
        except Exception as e:
            self.logger.error(f"Failed to enable auto-start: {e}")
    
    def _disable_auto_start(self):
        """Disable auto-start with Windows"""
        try:
            import winreg
            key = winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                r"Software\Microsoft\Windows\CurrentVersion\Run",
                0,
                winreg.KEY_SET_VALUE
            )
            winreg.DeleteValue(key, "IsotoneStack")
            winreg.CloseKey(key)
        except:
            pass
    
    def _reset_settings(self):
        """Reset all settings to defaults"""
        # Reset to defaults
        self.theme_var.set("dark")
        self.log_level_var.set("INFO")
        
        for key, var in self.checkboxes.items():
            var.set(False)
        
        self._change_theme("dark")
        self._save_settings()
        
        self.logger.info("Settings reset to defaults")
    
    def show(self):
        self.frame.grid(row=0, column=0, sticky="nsew", padx=0, pady=0)
    
    def hide(self):
        self.frame.grid_forget()