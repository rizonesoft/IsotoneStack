#!/usr/bin/env python3
"""
_Template.py
Template for IsotoneStack Python scripts
Copy this file and rename for new scripts
"""

import sys
import os
import argparse
from pathlib import Path

# Get script locations using portable paths (no hardcoded paths)
SCRIPT_PATH = Path(__file__).resolve()
SCRIPT_DIR = SCRIPT_PATH.parent
PYTHON_SCRIPTS_DIR = SCRIPT_DIR  # We're now in scripts/python
SCRIPTS_DIR = SCRIPT_DIR.parent  # scripts directory
ISOTONE_PATH = SCRIPTS_DIR.parent  # isotone root

# Add includes directory to path for imports
sys.path.insert(0, str(SCRIPT_DIR / "includes"))

# Import IsotoneLogger
from isotone_logger import IsotoneLogger

# Define common paths
PATHS = {
    'root': ISOTONE_PATH,
    'scripts': SCRIPTS_DIR,
    'python_scripts': PYTHON_SCRIPTS_DIR,
    'python': ISOTONE_PATH / "python",
    'apache': ISOTONE_PATH / "apache24",
    'php': ISOTONE_PATH / "php",
    'mariadb': ISOTONE_PATH / "mariadb",
    'www': ISOTONE_PATH / "www",
    'config': ISOTONE_PATH / "config",
    'bin': ISOTONE_PATH / "bin",
    'backups': ISOTONE_PATH / "backups",
    'logs': ISOTONE_PATH / "logs",
    'logs_isotone': ISOTONE_PATH / "logs" / "isotone"
}


def check_admin() -> bool:
    """Check if script is running with admin privileges"""
    try:
        if os.name == 'nt':
            import ctypes
            return ctypes.windll.shell32.IsUserAnAdmin() != 0
        else:
            return os.getuid() == 0
    except:
        return False


def main():
    """Main script logic"""
    # Parse arguments
    parser = argparse.ArgumentParser(description='Script description here')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose output')
    parser.add_argument('-f', '--force', action='store_true', help='Force operation')
    # Add more arguments as needed
    args = parser.parse_args()
    
    # Initialize logger
    script_name = Path(__file__).stem
    logger = IsotoneLogger(script_name, ISOTONE_PATH, verbose=args.verbose)
    
    try:
        # Log start
        logger.log("INFO", f"{script_name} Started (IsotoneStack: {ISOTONE_PATH})")
        if args.verbose:
            logger.log("DEBUG", f"Parameters: verbose={args.verbose}, force={args.force}")
        
        print()
        print("=== Script Name Here ===")
        if args.verbose:
            logger.log("DEBUG", f"IsotoneStack Path: {ISOTONE_PATH}")
        print()
        
        # Check admin if needed
        # if not check_admin():
        #     logger.log("ERROR", "This script requires Administrator privileges")
        #     logger.log("ERROR", "Please run this script as Administrator")
        #     return 1
        
        # Your script logic here
        # Only log important milestones, errors, and warnings
        # Use DEBUG level for detailed information (only shown with -v/--verbose)
        
        # Example of proper logging:
        # logger.log("INFO", "Starting configuration process")  # Important milestone
        # logger.log("DEBUG", "Checking prerequisites...")  # Only logged in verbose mode
        # logger.log("ERROR", "Configuration file missing")  # Always shown and logged
        # logger.log("WARNING", "Using default settings")  # Always shown and logged
        # logger.log("SUCCESS", "Configuration complete")  # Always shown and logged
        
        # Summary
        print()
        logger.log("SUCCESS", "Script completed successfully")
        if args.verbose:
            logger.log("DEBUG", f"Log file: {logger.log_file}")
        
        return 0
        
    except Exception as e:
        logger.log("ERROR", f"FATAL ERROR: {e}")
        import traceback
        logger.log("ERROR", f"Stack Trace: {traceback.format_exc()}")
        logger.log("ERROR", "Script failed with fatal error")
        print()
        print(f"See log file for details: {logger.log_file}")
        return 1


if __name__ == "__main__":
    sys.exit(main())