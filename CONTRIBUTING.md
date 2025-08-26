# Contributing to IsotoneStack

First off, thank you for considering contributing to IsotoneStack! It's people like you that make IsotoneStack such a great tool.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:
- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **System information** (Windows version, IsotoneStack version)
- **Relevant logs** from `/logs/` directory
- **Screenshots** if applicable

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Rationale** - Why would this be useful?
- **Possible implementation** - If you have ideas
- **Alternatives considered**

### Pull Requests

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/AmazingFeature`)
3. **Make** your changes
4. **Test** thoroughly
5. **Commit** with clear messages (`git commit -m 'Add some AmazingFeature'`)
6. **Push** to the branch (`git push origin feature/AmazingFeature`)
7. **Open** a Pull Request

## Development Setup

### Prerequisites

- Windows 10/11 (64-bit)
- Git
- Python 3.11+
- PowerShell 5.1+
- Administrator privileges

### Setting Up Your Development Environment

```powershell
# Clone your fork
git clone https://github.com/yourusername/IsotoneStack.git
cd IsotoneStack

# Create Python virtual environment for GUI development
cd control-panel-gui
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
pip install -r requirements-dev.txt  # Development dependencies

# Run tests
pytest
```

## Coding Standards

### PowerShell

- Use approved verbs (Get-, Set-, Start-, Stop-, etc.)
- Include comment-based help for functions
- Handle errors with try/catch
- Use `$ErrorActionPreference = "Stop"`

```powershell
function Start-IsotoneService {
    <#
    .SYNOPSIS
    Starts an IsotoneStack service
    
    .PARAMETER ServiceName
    The name of the service to start
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )
    
    try {
        Start-Service -Name $ServiceName -ErrorAction Stop
        Write-Host "Service $ServiceName started successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to start service: $_"
    }
}
```

### Python

- Follow PEP 8
- Use type hints
- Write docstrings for all functions/classes
- Keep it DRY (Don't Repeat Yourself)

```python
def create_service_widget(
    parent: ctk.CTkFrame,
    service_name: str,
    service_id: str
) -> ctk.CTkFrame:
    """
    Create a service control widget.
    
    Args:
        parent: Parent frame
        service_name: Display name of the service
        service_id: Internal service identifier
        
    Returns:
        The created widget frame
    """
    # Implementation
    pass
```

### Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests

Examples:
- `Add virtual host drag-drop functionality`
- `Fix Apache service startup timeout issue`
- `Update PHP to version 8.3.15`
- `Refactor service monitor for better performance`

## Testing

### Manual Testing Checklist

- [ ] Installation completes without errors
- [ ] All services start/stop correctly
- [ ] GUI launches and all pages work
- [ ] Virtual hosts can be created
- [ ] Database connection works
- [ ] Logs are being written
- [ ] Uninstallation removes services

### Automated Tests

```powershell
# Run PowerShell tests
.\tests\Test-Installation.ps1

# Run Python tests
cd control-panel-gui
pytest tests/
```

## Documentation

- Update README.md if you change functionality
- Update CLAUDE.md if you change project structure
- Add inline comments for complex logic
- Update configuration templates if needed

## Release Process

1. Update version numbers in:
   - `Install-IsotoneStack.ps1`
   - `control-panel-gui/main.py`
   - `README.md`

2. Update CHANGELOG.md

3. Create release notes

4. Tag the release: `git tag -a v1.0.1 -m "Release version 1.0.1"`

## Questions?

Feel free to open an issue with the "question" label or reach out on our Discord server.

Thank you for contributing! 🎉