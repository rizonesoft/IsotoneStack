#!/usr/bin/env python3
"""
IsotoneStack Control Panel
Modern GUI for managing Apache, PHP, and MariaDB services on Windows
"""

import sys
import os
import asyncio
import threading
from pathlib import Path

# Add the current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import customtkinter as ctk
from PIL import Image
import pystray
from pystray import MenuItem as item

from ui.main_window import MainWindow
from utils.config import Config
from utils.logger import setup_logger
from services.service_monitor import ServiceMonitor

# Configure CustomTkinter
ctk.set_appearance_mode("dark")  # Default to dark mode
ctk.set_default_color_theme("blue")

class IsotoneStackApp:
    def __init__(self):
        self.logger = setup_logger()
        self.config = Config()
        self.root = None
        self.main_window = None
        self.tray_icon = None
        self.service_monitor = None
        self.running = True
        
        # Create necessary directories
        self._create_directories()
        
        # Initialize the main window
        self._init_main_window()
        
        # Initialize system tray
        self._init_system_tray()
        
        # Start service monitoring
        self._start_service_monitor()
        
    def _create_directories(self):
        """Create necessary directories if they don't exist"""
        dirs = [
            Path("assets/icons"),
            Path("logs"),
            Path("config"),
            Path("temp")
        ]
        for dir_path in dirs:
            dir_path.mkdir(parents=True, exist_ok=True)
    
    def _init_main_window(self):
        """Initialize the main application window"""
        self.root = ctk.CTk()
        self.root.title("IsotoneStack Control Panel")
        self.root.geometry("1200x700")
        self.root.minsize(1000, 600)
        
        # Set window icon
        try:
            icon_path = Path("assets/icons/isotone.ico")
            if icon_path.exists():
                self.root.iconbitmap(str(icon_path))
        except Exception as e:
            self.logger.warning(f"Could not set window icon: {e}")
        
        # Handle window close event
        self.root.protocol("WM_DELETE_WINDOW", self.on_window_close)
        
        # Create main window
        self.main_window = MainWindow(self.root, self.config, self.logger)
        
        # Center window on screen
        self._center_window()
        
    def _center_window(self):
        """Center the window on the screen"""
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f"{width}x{height}+{x}+{y}")
    
    def _init_system_tray(self):
        """Initialize system tray icon"""
        try:
            # Create or use default icon
            icon_path = Path("assets/icons/isotone_tray.png")
            if not icon_path.exists():
                # Create a simple default icon if none exists
                self._create_default_icon(icon_path)
            
            image = Image.open(icon_path)
            
            # Create menu
            menu = pystray.Menu(
                item('Show', self.show_window),
                item('Hide', self.hide_window),
                pystray.Menu.SEPARATOR,
                item('Start All Services', self.start_all_services),
                item('Stop All Services', self.stop_all_services),
                item('Restart All Services', self.restart_all_services),
                pystray.Menu.SEPARATOR,
                item('Open Localhost', self.open_localhost),
                item('Open phpMyAdmin', self.open_phpmyadmin),
                pystray.Menu.SEPARATOR,
                item('Exit', self.quit_app)
            )
            
            self.tray_icon = pystray.Icon(
                "IsotoneStack",
                image,
                "IsotoneStack Control Panel",
                menu
            )
            
            # Run tray icon in separate thread
            tray_thread = threading.Thread(target=self.tray_icon.run, daemon=True)
            tray_thread.start()
            
        except Exception as e:
            self.logger.error(f"Failed to create system tray icon: {e}")
    
    def _create_default_icon(self, path):
        """Create a default icon if none exists"""
        from PIL import Image, ImageDraw
        
        # Create a simple icon
        size = 64
        image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(image)
        
        # Draw a simple server icon
        draw.rectangle([10, 10, 54, 30], fill=(100, 150, 200), outline=(50, 100, 150))
        draw.rectangle([10, 34, 54, 54], fill=(150, 100, 200), outline=(100, 50, 150))
        
        path.parent.mkdir(parents=True, exist_ok=True)
        image.save(path)
    
    def _start_service_monitor(self):
        """Start the service monitoring thread"""
        self.service_monitor = ServiceMonitor(self.config, self.logger)
        self.service_monitor.start()
        
        # Connect to main window for updates
        if self.main_window:
            self.service_monitor.on_status_change = self.main_window.update_service_status
    
    def show_window(self, icon=None, item=None):
        """Show the main window"""
        self.root.deiconify()
        self.root.lift()
        self.root.focus_force()
    
    def hide_window(self, icon=None, item=None):
        """Hide the main window to system tray"""
        self.root.withdraw()
    
    def on_window_close(self):
        """Handle window close event"""
        if self.config.get("minimize_to_tray", True):
            self.hide_window()
        else:
            self.quit_app()
    
    def start_all_services(self, icon=None, item=None):
        """Start all services"""
        if self.main_window:
            self.main_window.service_panel.start_all_services()
    
    def stop_all_services(self, icon=None, item=None):
        """Stop all services"""
        if self.main_window:
            self.main_window.service_panel.stop_all_services()
    
    def restart_all_services(self, icon=None, item=None):
        """Restart all services"""
        if self.main_window:
            self.main_window.service_panel.restart_all_services()
    
    def open_localhost(self, icon=None, item=None):
        """Open localhost in browser"""
        import webbrowser
        webbrowser.open("http://localhost")
    
    def open_phpmyadmin(self, icon=None, item=None):
        """Open phpMyAdmin in browser"""
        import webbrowser
        webbrowser.open("http://localhost/phpmyadmin")
    
    def quit_app(self, icon=None, item=None):
        """Quit the application"""
        self.running = False
        
        # Stop service monitor
        if self.service_monitor:
            self.service_monitor.stop()
        
        # Stop tray icon
        if self.tray_icon:
            self.tray_icon.stop()
        
        # Destroy main window
        if self.root:
            self.root.quit()
            self.root.destroy()
        
        sys.exit(0)
    
    def run(self):
        """Run the application"""
        try:
            self.logger.info("IsotoneStack Control Panel started")
            self.root.mainloop()
        except KeyboardInterrupt:
            self.quit_app()
        except Exception as e:
            self.logger.error(f"Application error: {e}")
            self.quit_app()

def main():
    """Main entry point"""
    # Check if running on Windows
    if sys.platform != "win32":
        print("This application is designed for Windows only.")
        sys.exit(1)
    
    # Check for administrator privileges
    try:
        import ctypes
        is_admin = ctypes.windll.shell32.IsUserAnAdmin()
        if not is_admin:
            print("Warning: Running without administrator privileges.")
            print("Some features may not work properly.")
    except:
        pass
    
    # Create and run the application
    app = IsotoneStackApp()
    app.run()

if __name__ == "__main__":
    main()