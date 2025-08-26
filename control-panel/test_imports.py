#!/usr/bin/env python3
"""
Test all imports for IsotoneStack Control Panel
"""

import sys
import os

print("Testing IsotoneStack Control Panel imports...")
print("=" * 50)

# Test core dependencies
try:
    import customtkinter as ctk
    print("✓ customtkinter imported")
except ImportError as e:
    print(f"✗ customtkinter failed: {e}")
    sys.exit(1)

try:
    from PIL import Image
    print("✓ PIL (Pillow) imported")
except ImportError as e:
    print(f"✗ PIL failed: {e}")

try:
    import pystray
    print("✓ pystray imported")
except ImportError as e:
    print(f"✗ pystray failed: {e}")

try:
    import psutil
    print("✓ psutil imported")
except ImportError as e:
    print(f"✗ psutil failed: {e}")

try:
    import yaml
    print("✓ yaml (PyYAML) imported")
except ImportError as e:
    print(f"✗ yaml failed: {e}")

try:
    import colorlog
    print("✓ colorlog imported")
except ImportError as e:
    print(f"✗ colorlog failed: {e}")

try:
    import requests
    print("✓ requests imported")
except ImportError as e:
    print(f"✗ requests failed: {e}")

try:
    import pymysql
    print("✓ pymysql imported")
except ImportError as e:
    print(f"✗ pymysql failed: {e}")

print("\n" + "=" * 50)
print("Testing local module imports...")
print("=" * 50)

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from ui.sidebar import Sidebar
    print("✓ ui.sidebar imported")
except ImportError as e:
    print(f"✗ ui.sidebar failed: {e}")

try:
    from ui.main_window import MainWindow
    print("✓ ui.main_window imported")
except ImportError as e:
    print(f"✗ ui.main_window failed: {e}")

try:
    from utils.config import Config
    print("✓ utils.config imported")
except ImportError as e:
    print(f"✗ utils.config failed: {e}")

try:
    from utils.logger import setup_logger
    print("✓ utils.logger imported")
except ImportError as e:
    print(f"✗ utils.logger failed: {e}")

try:
    from services.service_monitor import ServiceMonitor
    print("✓ services.service_monitor imported")
except ImportError as e:
    print(f"✗ services.service_monitor failed: {e}")

print("\n" + "=" * 50)
print("All imports successful! Ready to run main.py")
print("=" * 50)