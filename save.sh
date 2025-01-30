#!/bin/bash
# save-firefox-session.sh
# This script saves Firefox profile data and .config directory to a repository

# Colors and formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Logging function
log() {
    local level=$1
    shift
    local color
    case $level in
        INFO) color=$GREEN;;
        WARN) color=$YELLOW;;
        ERROR) color=$RED;;
        DEBUG) color=$BLUE;;
        *) color=$NC;;
    esac
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${color}[$timestamp] $level: $*${NC}"
}

# Set the repository location
REPO_DIR=""
FIREFOX_DIR="$HOME/.mozilla/firefox"
CONFIG_DIR="$HOME/.config"
PROFILE_PATH="ymspgfvf.default-release"
BACKUP_DIR="backup"

save_session() {
    # Create repository and backup directories if they don't exist
    mkdir -p "$BACKUP_DIR/firefox"
    mkdir -p "$BACKUP_DIR/config"

    # Initialize git repository if it doesn't exist
    if [ ! -d "$REPO_DIR/.git" ]; then
        log INFO "Initializing git repository..."
        cd "$REPO_DIR"
        git init
        git config user.name "Firefox Backup"
        git config user.email "firefox.backup@local"
        echo "*.sqlite-wal" > .gitignore  # Ignore WAL files
        echo "*.sqlite-shm" >> .gitignore
        echo "*/Cache/*" >> .gitignore    # Ignore cache directories
        echo "*/cache/*" >> .gitignore
        git add .gitignore
        git commit -m "Initial commit: Setup repository"
        cd - > /dev/null
    fi

    # Verify directories exist
    if [ ! -d "$FIREFOX_DIR/$PROFILE_PATH" ]; then
        log ERROR "Firefox profile directory not found at $FIREFOX_DIR/$PROFILE_PATH"
        exit 1
    fi

    if [ ! -d "$CONFIG_DIR" ]; then
        log ERROR "Config directory not found at $CONFIG_DIR"
        exit 1
    fi

    log INFO "Using Firefox profile: $FIREFOX_DIR/$PROFILE_PATH"
    log INFO "Using config directory: $CONFIG_DIR"

    # Get current timestamp for commit message
    DATE_HUMAN=$(date '+%Y-%m-%d %H:%M:%S')

    # Firefox files to save
    FIREFOX_FILES=(
        "places.sqlite"    # Bookmarks and history
        "places.sqlite-wal"
        "sessionstore-backups/recovery.jsonlz4"    # Current session
        "sessionstore-backups/previous.jsonlz4"    # Previous session
        "prefs.js"        # Preferences
        "logins.json"     # Saved passwords
        "key4.db"         # Password database
        "cookies.sqlite"  # Cookies
        "cookies.sqlite-wal"
        "favicons.sqlite" # Site icons
        "permissions.sqlite" # Site permissions
        "formhistory.sqlite" # Saved form data
    )

    # Save Firefox files
    log INFO "Starting Firefox backup..."
    for file in "${FIREFOX_FILES[@]}"; do
        if [ -f "$FIREFOX_DIR/$PROFILE_PATH/$file" ]; then
            parent_dir=$(dirname "$BACKUP_DIR/firefox/$file")
            mkdir -p "$parent_dir"
            cp "$FIREFOX_DIR/$PROFILE_PATH/$file" "$BACKUP_DIR/firefox/$file"
            log DEBUG "Saved Firefox: $file"
        else
            log WARN "Firefox file not found (normal if not created yet): $file"
        fi
    done

    # Save .config directory
    log INFO "Starting .config backup..."
    rsync -av --delete \
        --exclude 'Cache*' \
        --exclude 'cache*' \
        --exclude '*.log' \
        --exclude 'chromium' \
        --exclude 'google-chrome' \
        --exclude 'Microsoft*' \
        --exclude 'pulse' \
        "$CONFIG_DIR/" "$BACKUP_DIR/config/"
    log DEBUG "Saved .config directory"

    # Git operations
    cd "$REPO_DIR"
    log INFO "Committing changes to git repository..."
    
    # Create/update backup summary
    echo "System Backup - Last updated: $DATE_HUMAN" > "$BACKUP_DIR/backup_info.txt"
    echo "Firefox Profile: $PROFILE_PATH" >> "$BACKUP_DIR/backup_info.txt"
    echo "Config Directory: $CONFIG_DIR" >> "$BACKUP_DIR/backup_info.txt"

    # Add all files to git
    git remote set-url --push origin git@github.com:star-small/scripts.git
    git add .
    
    # Create commit
    COMMIT_MSG="System Backup Update $DATE_HUMAN

- Firefox Profile: $PROFILE_PATH
- Config Directory: $CONFIG_DIR
- Updated: $DATE_HUMAN"

    git commit -m "$COMMIT_MSG"
    
    # Get commit info
    COMMIT_HASH=$(git rev-parse --short HEAD)
    yes | git push
    log INFO "Created git commit: $COMMIT_HASH"

    cd - > /dev/null

    log INFO "✔ Backup completed successfully:"
    log INFO "  Location: $BACKUP_DIR"
    log INFO "  Git commit: $COMMIT_HASH"
    log INFO "  Time: $DATE_HUMAN"
}

# Run the save function
save_session
