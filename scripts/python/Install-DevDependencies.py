#!/usr/bin/env python3
"""
Install-DevDependencies.py
Install development dependencies for IsotoneStack (system-wide for embedded Python)
Includes build tools, linting, testing, and documentation tools
"""

import sys
import os
import subprocess
from pathlib import Path

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
    'requirements_dev': SCRIPT_DIR / "requirements-dev.txt",  # Now in scripts/python
}

# Categories of dev dependencies
DEV_CATEGORIES = {
    'build': ['pyinstaller', 'py2exe', 'auto-py-to-exe'],
    'quality': ['pylint', 'flake8', 'black', 'mypy', 'isort'],
    'testing': ['pytest', 'pytest-cov', 'pytest-mock', 'pytest-asyncio'],
    'docs': ['sphinx', 'sphinx-rtd-theme', 'autodoc'],
    'utils': ['ipython', 'jupyter', 'notebook'],
    'debug': ['pydevd', 'debugpy'],
    'profiling': ['memory-profiler', 'line-profiler', 'py-spy'],
    'types': ['types-requests', 'types-PyYAML'],
    'security': ['bandit', 'safety'],
    'package': ['pip-tools', 'pipdeptree', 'pip-autoremove'],
    'vcs': ['pre-commit', 'commitizen']
}


class DevDependencyInstaller:
    """Manages development dependency installation"""
    
    def __init__(self, verbose=False, category=None):
        self.verbose = verbose
        self.category = category
        self.embedded_python = None
        self.system_python = None
        self.using_embedded = False
        
        # Initialize logger
        self.logger = IsotoneLogger("Install-DevDependencies", ISOTONE_PATH, verbose=verbose)
        
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
            self._log("Falling back to system Python", "WARNING")
        else:
            self._log("No Python installation found!", "ERROR")
            sys.exit(1)
    
    def _run_pip(self, args, check=True, timeout=60):
        """Run pip command with timeout"""
        cmd = [self.python_exe, "-m", "pip"] + args
        self._log(f"Running: {' '.join(cmd)}", "DEBUG")
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, 
                                  check=check, timeout=timeout)
            if self.verbose and result.stdout:
                self._log(result.stdout, "DEBUG")
            return result
        except subprocess.TimeoutExpired:
            self._log(f"Command timed out after {timeout} seconds", "ERROR")
            # Create a fake result object
            class TimeoutResult:
                returncode = 1
                stdout = ""
                stderr = "Installation timed out"
            return TimeoutResult()
        except subprocess.CalledProcessError as e:
            self._log(f"Command failed: {e}", "ERROR")
            if e.stderr:
                self._log(e.stderr, "ERROR")
            if check:
                raise
            return e
    
    def ensure_base_dependencies(self):
        """Ensure base dependencies are installed first"""
        self._log("Checking base dependencies...", "INFO")
        
        # Check if requirements.txt dependencies are installed
        if PATHS['requirements'].exists():
            self._log("Installing base dependencies from requirements.txt...", "INFO")
            result = self._run_pip(["install", "-r", str(PATHS['requirements'])], check=False)
            if result.returncode != 0:
                self._log("Some base dependencies failed to install", "WARNING")
                self._log("Run Install-Dependencies.bat first", "WARNING")
                return False
        return True
    
    def install_from_requirements_dev(self):
        """Install all dev dependencies from requirements-dev.txt"""
        if not PATHS['requirements_dev'].exists():
            self._log("requirements-dev.txt not found", "ERROR")
            return False
        
        self._log("Installing development dependencies...", "INFO")
        
        # Read and parse requirements-dev.txt
        packages = []
        with open(PATHS['requirements_dev'], 'r') as f:
            for line in f:
                line = line.strip()
                # Skip comments and empty lines
                if line and not line.startswith('#'):
                    packages.append(line)
        
        self._log(f"Found {len(packages)} packages to install", "INFO")
        
        # Install packages one by one
        failed = []
        succeeded = []
        skipped = []
        
        for i, package in enumerate(packages, 1):
            self._log(f"[{i}/{len(packages)}] Installing {package}...", "INFO")
            
            # Skip optional/problematic packages
            if package in ['py2exe', 'auto-py-to-exe', 'autodoc', 'notebook']:
                self._log(f"Skipping optional package: {package}", "WARNING")
                skipped.append(package)
                continue
            
            result = self._run_pip(["install", package], check=False)
            
            if result.returncode == 0:
                self._log(f"Installed {package}", "SUCCESS")
                succeeded.append(package)
            else:
                self._log(f"Failed to install {package}", "ERROR")
                failed.append(package)
        
        # Summary
        self._log(f"\nInstallation Summary:", "INFO")
        self._log(f"  Succeeded: {len(succeeded)}", "SUCCESS" if succeeded else "INFO")
        self._log(f"  Failed: {len(failed)}", "ERROR" if failed else "INFO")
        self._log(f"  Skipped: {len(skipped)}", "WARNING" if skipped else "INFO")
        
        if failed:
            self._log(f"Failed packages: {', '.join(failed)}", "ERROR")
            
        return len(failed) == 0
    
    def install_category(self, category):
        """Install a specific category of dev dependencies"""
        if category not in DEV_CATEGORIES:
            self._log(f"Unknown category: {category}", "ERROR")
            self._log(f"Available categories: {', '.join(DEV_CATEGORIES.keys())}", "INFO")
            return False
        
        packages = DEV_CATEGORIES[category]
        self._log(f"Installing {category} tools: {', '.join(packages)}", "INFO")
        
        failed = []
        for package in packages:
            self._log(f"Installing {package}...", "DEBUG")
            result = self._run_pip(["install", package], check=False)
            if result.returncode != 0:
                failed.append(package)
                self._log(f"Failed to install {package}", "ERROR")
            else:
                self._log(f"Installed {package}", "SUCCESS")
        
        if failed:
            self._log(f"Failed packages: {', '.join(failed)}", "ERROR")
            return False
        
        self._log(f"All {category} tools installed successfully", "SUCCESS")
        return True
    
    def list_categories(self):
        """List available categories and their packages"""
        print("\n" + "="*50)
        print("    Available Development Categories")
        print("="*50 + "\n")
        
        for category, packages in DEV_CATEGORIES.items():
            print(f"\n[{category.upper()}]")
            for package in packages:
                print(f"  - {package}")
        
        print("\nUse --category <name> to install a specific category")
        print("Example: Install-DevDependencies.bat --category build")
    
    def run(self):
        """Main installation process"""
        print("\n" + "="*50)
        print("    IsotoneStack Python Development")
        print("    Development Dependencies Installation")
        print("="*50 + "\n")
        
        self._log(f"Install-DevDependencies Started (IsotoneStack: {ISOTONE_PATH})", "INFO")
        self._log(f"Log file: {self.logger.log_file}", "DEBUG")
        
        # Ensure base dependencies first
        if not self.ensure_base_dependencies():
            self._log("Base dependencies missing - install them first", "ERROR")
            return 1
        
        # Install based on category or all
        if self.category:
            if self.category == 'list':
                self.list_categories()
                return 0
            else:
                success = self.install_category(self.category)
        else:
            success = self.install_from_requirements_dev()
        
        if success:
            print("\n" + "="*50)
            print("    Installation Complete!")
            print("="*50)
            
            # Show useful commands
            print("\nUseful commands:")
            print("  - pyinstaller: Build executable from Python script")
            print("  - pytest: Run tests")
            print("  - black: Format code")
            print("  - pylint: Check code quality")
            print("  - jupyter notebook: Start Jupyter notebook")
            
            return 0
        else:
            self._log("Some dependencies failed to install", "ERROR")
            self._log("Check the log file for details", "ERROR")
            print(f"\nLog file: {self.logger.log_file}")
            return 1


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Install development dependencies')
    parser.add_argument('-v', '--verbose', action='store_true', 
                       help='Show detailed output')
    parser.add_argument('-c', '--category', type=str,
                       help='Install specific category (build, quality, testing, etc.)')
    parser.add_argument('--list', action='store_true',
                       help='List available categories')
    args = parser.parse_args()
    
    if args.list:
        installer = DevDependencyInstaller()
        installer.list_categories()
        return 0
    
    installer = DevDependencyInstaller(verbose=args.verbose, category=args.category)
    return installer.run()


if __name__ == "__main__":
    sys.exit(main())