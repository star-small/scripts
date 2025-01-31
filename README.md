# 🚀 System Configuration Backup Scripts

A collection of powerful bash scripts to manage your system configuration, browser sessions, and development environment.

## 🌟 Features

- 🦊 **Firefox Profile Management**
  - Bookmarks and history
  - Saved passwords and login information
  - Browser preferences and session data
  - Cookies and site permissions

- 🔧 **System Configuration**
  - `.config` directory backup
  - VSCode settings and extensions
  - SSH configuration (with proper permissions)

- 💾 **Git Integration**
  - Automatic version control
  - Timestamped commits
  - Remote repository sync

- 🖥️ **Workspace Initialization**
  - One-command system restore
  - Automated Firefox launch with pinned tabs
  - Background process management

## 📦 Installation

1. Clone the repository:
```bash
git clone https://github.com/star-small/scripts.git
cd scripts
```

2. Make scripts executable:
```bash
chmod +x save.sh load.sh init.sh
```

3. Configure repository path:
Edit `REPO_DIR` in scripts to point to your desired backup location.

## 🚀 Usage

### Backup Your System
```bash
./save.sh
```
- Creates timestamped backups
- Commits changes to git
- Pushes to remote repository

### Restore Your System
```bash
./load.sh
```
- Restores Firefox profile
- Restores system configurations
- Sets up SSH with proper permissions

### Initialize Workspace
```bash
./init.sh
```
- Loads your system configuration
- Launches Firefox in background with pinned tabs:
  - Alem School Platform
  - Progress Tracker
  - Moodle
  - YouTube
  - Pomodoro Timer

## 📋 File Structure

```
backup/
├── firefox/           # Firefox profile data
├── config/           # System configuration
│   └── .ssh/        # SSH keys and config
└── vscode/          # VSCode settings
```

## 🔒 Security

- Proper SSH key permissions (600 for private keys)
- Secure directory permissions
- Git-ignored sensitive files
- WAL file handling

## ⚙️ Customization

### Adding New Pinned Tabs
Edit `init.sh` and add URLs to the `URLS` array:
```bash
URLS=(
    "https://your-url.com"
    # Add more URLs here
)
```

### Modifying Backup Locations
Edit the directory variables in each script:
```bash
REPO_DIR="your/backup/location"
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---
Made with ❤️ by [star-small](https://github.com/star-small)
