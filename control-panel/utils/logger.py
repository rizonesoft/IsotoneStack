"""
Logging configuration for IsotoneStack Control Panel
"""

import logging
import colorlog
from pathlib import Path
from datetime import datetime

def setup_logger(name: str = "IsotoneStack", log_level: str = "INFO") -> logging.Logger:
    """Set up colored console and file logging"""
    
    # Create logs directory
    log_dir = Path("logs")
    log_dir.mkdir(exist_ok=True)
    
    # Create logger
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, log_level.upper()))
    
    # Remove existing handlers
    logger.handlers.clear()
    
    # Console handler with color
    console_handler = colorlog.StreamHandler()
    console_handler.setLevel(logging.DEBUG)
    
    console_format = colorlog.ColoredFormatter(
        '%(log_color)s%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%H:%M:%S',
        log_colors={
            'DEBUG': 'cyan',
            'INFO': 'green',
            'WARNING': 'yellow',
            'ERROR': 'red',
            'CRITICAL': 'red,bg_white',
        }
    )
    console_handler.setFormatter(console_format)
    logger.addHandler(console_handler)
    
    # File handler
    log_file = log_dir / f"isotone_{datetime.now().strftime('%Y%m%d')}.log"
    file_handler = logging.FileHandler(log_file, encoding='utf-8')
    file_handler.setLevel(logging.DEBUG)
    
    file_format = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(file_format)
    logger.addHandler(file_handler)
    
    return logger

class ServiceLogger:
    """Logger for individual services"""
    
    def __init__(self, service_name: str, base_logger: logging.Logger):
        self.service_name = service_name
        self.logger = base_logger.getChild(service_name)
    
    def log_start(self):
        """Log service start"""
        self.logger.info(f"{self.service_name} service started")
    
    def log_stop(self):
        """Log service stop"""
        self.logger.info(f"{self.service_name} service stopped")
    
    def log_error(self, error: str):
        """Log service error"""
        self.logger.error(f"{self.service_name} error: {error}")
    
    def log_status(self, status: str):
        """Log service status change"""
        self.logger.info(f"{self.service_name} status: {status}")