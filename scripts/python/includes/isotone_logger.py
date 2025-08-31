#!/usr/bin/env python3
"""
isotone_logger.py
Centralized logging module for IsotoneStack scripts
One log file per script with age/size-based cleanup
"""

import sys
import os
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional, Dict, Any


class IsotoneLogger:
    """Custom logger for IsotoneStack scripts - one log per script"""
    
    COLORS = {
        'DEBUG': '\033[90m',       # Gray
        'INFO': '\033[97m',        # White
        'SUCCESS': '\033[92m',     # Green
        'WARNING': '\033[93m',     # Yellow
        'ERROR': '\033[91m',       # Red
        'CRITICAL': '\033[95m',    # Magenta
        'CYAN': '\033[96m',        # Cyan
        'RESET': '\033[0m'
    }
    
    MAX_SIZE = 6 * 1024 * 1024  # 6MB
    MAX_AGE_DAYS = 30  # 30 days
    
    def __init__(self, script_name: str, isotone_path: Path, verbose: bool = False):
        """
        Initialize logger with one log file per script
        
        Args:
            script_name: Name of the script (without extension)
            isotone_path: Path to IsotoneStack root
            verbose: Enable verbose output
        """
        self.script_name = script_name
        self.isotone_path = Path(isotone_path)
        self.verbose = verbose
        
        # Setup log path
        self.logs_path = self.isotone_path / "logs" / "isotone"
        self.logs_path.mkdir(parents=True, exist_ok=True)
        
        # One log file per script (no date suffix)
        self.log_file = self.logs_path / f"{script_name}.log"
        
        # Check if log needs cleanup
        self._cleanup_if_needed()
        
        # Setup logging
        self._setup_logging()
    
    def _cleanup_if_needed(self):
        """Remove and start fresh if log is too old or too large"""
        if self.log_file.exists():
            # Check age
            file_age = datetime.now() - datetime.fromtimestamp(self.log_file.stat().st_mtime)
            is_too_old = file_age.days > self.MAX_AGE_DAYS
            
            # Check size
            file_size = self.log_file.stat().st_size
            is_too_large = file_size > self.MAX_SIZE
            
            # Remove if too old or too large
            if is_too_old or is_too_large:
                reason = "too old" if is_too_old else "too large"
                self.log_file.unlink()
                # Will log about cleanup when new file is created
    
    def _setup_logging(self):
        """Configure the logging system for this script"""
        # Create a logger for this script
        self.logger = logging.getLogger(f"isotone.{self.script_name}")
        self.logger.setLevel(logging.DEBUG)
        self.logger.handlers.clear()
        
        # Create file handler (append mode)
        handler = logging.FileHandler(
            self.log_file,
            encoding='utf-8',
            mode='a'
        )
        handler.setLevel(logging.DEBUG)
        
        # Set formatter with timestamp
        formatter = logging.Formatter(
            '[%(asctime)s] [%(levelname)s] %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        handler.setFormatter(formatter)
        
        self.logger.addHandler(handler)
    
    def _should_show_in_console(self, level: str) -> bool:
        """Determine if message should be shown in console"""
        if self.verbose:
            return True
        
        # Only show warnings, errors, and success messages by default
        return level in ['ERROR', 'WARNING', 'SUCCESS']
    
    def log(self, level: str, message: str):
        """
        Log a message to debug.log
        
        Args:
            level: Log level (DEBUG, INFO, SUCCESS, WARNING, ERROR, CRITICAL)
            message: Message to log
        """
        # Map custom levels to logging levels
        log_level_map = {
            'DEBUG': logging.DEBUG,
            'INFO': logging.INFO,
            'SUCCESS': logging.INFO,
            'WARNING': logging.WARNING,
            'ERROR': logging.ERROR,
            'CRITICAL': logging.CRITICAL,
        }
        
        # Log to debug.log file
        log_level = log_level_map.get(level, logging.INFO)
        self.logger.log(log_level, message)
        
        # Log to console with color (only important messages)
        if self._should_show_in_console(level):
            color = self.COLORS.get(level, self.COLORS['RESET'])
            
            # Format prefix based on level
            if level == 'SUCCESS':
                prefix = '[OK] '
            elif level in ['ERROR', 'WARNING']:
                prefix = f'[{level}] '
            elif level == 'DEBUG' and self.verbose:
                prefix = '[DEBUG] '
            else:
                prefix = ''
            
            print(f"{color}{prefix}{message}{self.COLORS['RESET']}")
    
