# IsotoneStack Control Panel GUI

A modern, beautiful control panel for managing IsotoneStack services with CustomTkinter.

## Features

✨ **Modern Dark/Light Theme UI**
- Beautiful CustomTkinter interface
- Smooth animations and transitions
- System tray integration
- Responsive design

📊 **Dashboard View**
- Real-time service status monitoring
- Resource usage meters (CPU, RAM, Disk)
- Quick statistics and metrics
- One-click service controls

⚙️ **Service Management**
- Start/Stop/Restart Apache, MariaDB, PHP
- Animated status indicators
- Batch operations
- Service configuration editing

🌐 **Virtual Hosts Manager**
- Easy virtual host creation
- Drag-drop site deployment
- Automatic hosts file management
- SSL certificate support

🗄️ **Database Manager**
- Connect to MariaDB
- Browse databases
- Execute quick queries
- Backup/Restore functionality

🔌 **Port Manager**
- Automatic port conflict detection
- View processes using ports
- Release blocked ports
- Port availability monitoring

📝 **Logs Viewer**
- Real-time log streaming
- Multiple log file support
- Search and filter
- Auto-scroll option

## Installation

### Requirements

- Windows 10/11
- Python 3.11 or later
- Administrator privileges (for service control)

### Quick Start

1. **Install Python** (if not already installed)
   - Download from https://python.org
   - Make sure to add Python to PATH

2. **Launch the Control Panel**
   ```batch
   cd C:\isotone\control-panel-gui
   launch.bat
   ```

   The launcher will:
   - Create a virtual environment
   - Install all dependencies
   - Start the control panel

### Manual Installation

```batch
# Create virtual environment
python -m venv venv

# Activate it
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the application
python main.py
```

## Usage

### First Launch

1. The control panel will start with the dashboard view
2. Services will be automatically detected and monitored
3. System tray icon will appear for quick access

### Navigation

- **Sidebar**: Click menu items to switch between sections
- **Dashboard**: Overview of all services and system status
- **Services**: Detailed service control and management
- **Virtual Hosts**: Create and manage Apache virtual hosts
- **Database**: MariaDB database management
- **Ports**: Monitor and manage port usage
- **Logs**: View service log files
- **Settings**: Configure appearance and behavior

### Keyboard Shortcuts

- `Ctrl+Q` - Quit application
- `Ctrl+H` - Hide to system tray
- `Ctrl+R` - Refresh current view
- `F5` - Refresh services
- `F11` - Toggle fullscreen

### System Tray

Right-click the system tray icon for quick actions:
- Show/Hide window
- Start/Stop all services
- Open localhost
- Open phpMyAdmin
- Exit application

## Configuration

Settings are stored in `config/settings.json`

### Theme Options

- **Dark Mode** (default)
- **Light Mode**
- **System** (follows Windows theme)

### Behavior Options

- Minimize to system tray
- Auto-start services on launch
- Start with Windows
- Check for updates

## Troubleshooting

### Application Won't Start

1. Check Python version: `python --version` (needs 3.11+)
2. Run as Administrator for full functionality
3. Check `logs/` folder for error messages

### Services Not Detected

1. Ensure IsotoneStack is installed at `C:\isotone`
2. Services must be registered as Windows services
3. Try running the app as Administrator

### Port Conflicts

1. Use the Port Manager to identify conflicting processes
2. Stop conflicting services or change ports in configuration

### Database Connection Failed

1. Ensure MariaDB service is running
2. Check credentials in Settings
3. Default: root / isotone_admin

## Development

### Project Structure

```
control-panel-gui/
├── main.py              # Main application entry
├── requirements.txt     # Python dependencies
├── launch.bat          # Windows launcher
├── ui/                 # UI components
│   ├── main_window.py  # Main window controller
│   ├── sidebar.py      # Navigation sidebar
│   ├── dashboard.py    # Dashboard view
│   ├── service_panel.py # Service management
│   ├── vhosts_manager.py # Virtual hosts
│   ├── database_manager.py # Database tools
│   ├── port_manager.py # Port monitoring
│   ├── logs_viewer.py  # Log viewer
│   └── settings_page.py # Settings
├── services/           # Service management
│   └── service_monitor.py # Service monitoring
├── utils/              # Utilities
│   ├── config.py       # Configuration manager
│   └── logger.py       # Logging setup
├── assets/             # Icons and images
├── config/             # Configuration files
└── logs/              # Application logs
```

### Adding New Features

1. Create new UI component in `ui/`
2. Add to navigation in `sidebar.py`
3. Register in `main_window.py`
4. Update configuration if needed

### Custom Themes

Edit color schemes in Settings or modify:
```python
ctk.set_default_color_theme("blue")  # or "green", "dark-blue"
```

## License

Part of IsotoneStack - Free for personal and commercial use.

## Support

- Report issues in the IsotoneStack repository
- Check logs in `control-panel-gui/logs/`
- Ensure all IsotoneStack services are properly installed