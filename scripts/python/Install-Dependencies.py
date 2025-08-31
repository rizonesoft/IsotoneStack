#!/usr/bin/env python3
"""
Install-Dependencies.py
Install Python dependencies for IsotoneStack (system-wide for embedded Python)
Installs all packages needed by Control Panel and other Python components
"""

import sys
import os
import subprocess
import json
from pathlib import Path
from datetime import datetime, timedelta

# Get script locations using portable paths (no hardcoded paths)
SCRIPT_PATH = Path(__file__).resolve()
SCRIPT_DIR = SCRIPT_PATH.parent  # scripts/python
SCRIPTS_DIR = SCRIPT_DIR.parent  # scripts
ISOTONE_PATH = SCRIPTS_DIR.parent  # isotone root

# Add includes directory to path for imports
sys.path.insert(0, str(SCRIPT_DIR / "includes"))

# Import IsotoneLogger
from isotone_logger import IsotoneLogger

# Define paths
PATHS = {
    'root': ISOTONE_PATH,
    'scripts_python': SCRIPT_DIR,
    'embedded_python': ISOTONE_PATH / "python",
    'requirements': SCRIPT_DIR / "requirements.txt",  # Now in scripts/python
    'logs': ISOTONE_PATH / "logs" / "isotone"
}

# Minimal dependencies if requirements.txt not found
MINIMAL_DEPS = [
    'customtkinter',
    'psutil',
    'PyMySQL',
    'Pillow',
    'pystray',
    'pywin32',
    'PyYAML',
    'python-dotenv',
    'colorlog',
    'requests'
]

# Critical dependencies that must be installed
CRITICAL_DEPS = [
    'customtkinter',
    'psutil',
    'PyMySQL'
]


class DependencyInstaller:
    """Manages dependency installation for Control Panel"""
    
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.embedded_python = None
        self.system_python = None
        self.using_embedded = False
        
        # Initialize logger
        self.logger = IsotoneLogger("Install-Dependencies", ISOTONE_PATH, verbose=verbose)
        
        # Find Python installations
        self._find_python()
    
    def _log(self, message, level="INFO"):
        """Log to file and console using IsotoneLogger"""
        self.logger.log(level, message)
    
    def _find_python(self):
        """Find embedded Python first, then fall back to system Python"""
        # Check for embedded Python
        embedded_exe = PATHS['embedded_python'] / "python.exe"
        if embedded_exe.exists():
            self.embedded_python = embedded_exe
            self.using_embedded = True
            self._log(f"Found embedded Python: {embedded_exe}", "SUCCESS")
        else:
            self._log(f"Embedded Python not found at: {PATHS['embedded_python']}", "WARNING")
        
        # Check for system Python
        try:
            result = subprocess.run([sys.executable, "--version"], 
                                  capture_output=True, text=True, check=True)
            self.system_python = sys.executable
            self._log(f"Found system Python: {sys.executable}", "INFO")
        except:
            self._log("System Python not found", "WARNING")
        
        # Determine which to use
        if self.embedded_python:
            self.python_exe = str(self.embedded_python)
            self.using_embedded = True
            self._log("Using embedded Python for installation", "SUCCESS")
        elif self.system_python:
            self.python_exe = self.system_python
            self.using_embedded = False
            self._log("Falling back to system Python (not recommended)", "WARNING")
        else:
            self._log("No Python installation found!", "ERROR")
            self._log("Please either:", "ERROR")
            self._log(f"  1. Download Python embeddable package to: {PATHS['embedded_python']}", "ERROR")
            self._log("  2. Install Python 3.8+ system-wide", "ERROR")
            sys.exit(1)
    
    def _run_pip(self, args, check=True):
        """Run pip command"""
        cmd = [self.python_exe, "-m", "pip"] + args
        self._log(f"Running: {' '.join(cmd)}", "DEBUG")
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=check)
            if self.verbose and result.stdout:
                self._log(result.stdout, "DEBUG")
            return result
        except subprocess.CalledProcessError as e:
            self._log(f"Command failed: {e}", "ERROR")
            if e.stderr:
                self._log(e.stderr, "ERROR")
            if check:
                raise
            return e
    
    def upgrade_pip(self):
        """Upgrade pip to latest version"""
        self._log("Upgrading pip...", "INFO")
        result = self._run_pip(["install", "--upgrade", "pip"], check=False)
        if result.returncode == 0:
            self._log("pip upgraded successfully", "SUCCESS")
        else:
            self._log("pip upgrade failed (may not be critical)", "WARNING")
    
    def install_pyinstaller(self):
        """Install PyInstaller for building executables"""
        self._log("Installing PyInstaller...", "INFO")
        result = self._run_pip(["install", "pyinstaller"], check=False)
        if result.returncode == 0:
            self._log("PyInstaller installed successfully", "SUCCESS")
        else:
            self._log("PyInstaller installation failed", "WARNING")
    
    def install_from_requirements(self):
        """Install from requirements.txt"""
        if PATHS['requirements'].exists():
            self._log(f"Installing from requirements.txt...", "INFO")
            result = self._run_pip(["install", "-r", str(PATHS['requirements'])], check=False)
            if result.returncode == 0:
                self._log("All requirements installed successfully", "SUCCESS")
                return True
            else:
                self._log("Some requirements failed to install", "WARNING")
                return False
        else:
            self._log("requirements.txt not found", "WARNING")
            return False
    
    def install_minimal_deps(self):
        """Install minimal required dependencies"""
        self._log("Installing minimal dependencies...", "INFO")
        failed = []
        
        for dep in MINIMAL_DEPS:
            self._log(f"Installing {dep}...", "DEBUG")
            result = self._run_pip(["install", dep], check=False)
            if result.returncode != 0:
                failed.append(dep)
                self._log(f"Failed to install {dep}", "ERROR")
            else:
                self._log(f"Installed {dep}", "SUCCESS")
        
        if failed:
            self._log(f"Failed to install: {', '.join(failed)}", "ERROR")
            return False
        return True
    
    def check_tkinter(self):
        """Check if tkinter is available (required for customtkinter)"""
        self._log("Checking for tkinter support...", "INFO")
        cmd = [self.python_exe, "-c", "import tkinter; print('[OK] tkinter available')"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            self._log("tkinter is available", "SUCCESS")
            return True
        else:
            self._log("tkinter is NOT available", "ERROR")
            self._log("The embedded Python package doesn't include tkinter/Tcl/Tk", "WARNING")
            self._log("This is required for the GUI Control Panel", "WARNING")
            return False
    
    def verify_critical_deps(self):
        """Verify critical dependencies are installed"""
        self._log("Verifying critical dependencies...", "INFO")
        all_good = True
        
        # Check tkinter first (needed for customtkinter)
        has_tkinter = self.check_tkinter()
        
        for dep in CRITICAL_DEPS:
            # Skip customtkinter if no tkinter
            if dep == 'customtkinter' and not has_tkinter:
                self._log(f"{dep} cannot work without tkinter", "ERROR")
                self._log("Run Fix-Dependencies.bat to diagnose and fix this issue", "WARNING")
                all_good = False
                continue
            
            # Try to import the module
            module_name = dep.lower().replace('-', '_')
            if module_name == 'pymysql':
                module_name = 'pymysql'
            elif module_name == 'pillow':
                module_name = 'PIL'
            
            cmd = [self.python_exe, "-c", f"import {module_name}; print(f'[OK] {dep} imported successfully')"]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                self._log(f"{dep} verified", "SUCCESS")
            else:
                self._log(f"{dep} not working correctly", "ERROR")
                # Try to reinstall
                self._log(f"Attempting to reinstall {dep}...", "INFO")
                reinstall = self._run_pip(["install", "--force-reinstall", dep], check=False)
                if reinstall.returncode != 0:
                    all_good = False
        
        return all_good
    
    def run(self):
        """Main installation process"""
        print("\n" + "="*50)
        print("    IsotoneStack Python Dependencies")
        print("    System-Wide Installation")
        print("="*50 + "\n")
        
        self._log(f"Install-Dependencies Started (IsotoneStack: {ISOTONE_PATH})", "INFO")
        self._log(f"Log file: {self.logger.log_file}", "DEBUG")
        
        # Step 1: Upgrade pip
        self.upgrade_pip()
        
        # Step 2: Install PyInstaller
        self.install_pyinstaller()
        
        # Step 3: Install dependencies
        if not self.install_from_requirements():
            self._log("Falling back to minimal dependencies", "WARNING")
            self.install_minimal_deps()
        
        # Step 4: Verify critical dependencies
        if self.verify_critical_deps():
            self._log("All critical dependencies verified", "SUCCESS")
            print("\n" + "="*50)
            print("    Installation Complete!")
            print("="*50)
            return 0
        else:
            self._log("Some critical dependencies are missing", "ERROR")
            self._log("Please check the log file for details", "ERROR")
            print(f"\nLog file: {self.logger.log_file}")
            
            # Check if tkinter is the issue
            if not self.check_tkinter():
                print("\n" + "="*50)
                print("    IMPORTANT: tkinter Missing!")
                print("="*50)
                print("\nThe embedded Python doesn't include tkinter.")
                print("To fix this issue, please run:")
                print("\n    Fix-Dependencies.bat")
                print("\nThis will diagnose and provide solutions.")
            
            return 1


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Install Control Panel dependencies')
    parser.add_argument('-v', '--verbose', action='store_true', 
                       help='Show detailed output')
    parser.add_argument('--embedded-only', action='store_true',
                       help='Only use embedded Python, fail if not found')
    args = parser.parse_args()
    
    installer = DependencyInstaller(verbose=args.verbose)
    
    if args.embedded_only and not installer.using_embedded:
        print("[ERROR] --embedded-only specified but embedded Python not found")
        return 1
    
    return installer.run()


if __name__ == "__main__":
    sys.exit(main())