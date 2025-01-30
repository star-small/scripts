#!/bin/bash
# save-firefox-session.sh
# This script saves Firefox profile data to a repository

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
REPO_DIR="firefox-backup"
FIREFOX_DIR="$HOME/.mozilla/firefox"
PROFILE_PATH="ymspgfvf.default-release"

save_session() {
    # Create repository directory if it doesn't exist
    mkdir -p "$REPO_DIR"

    # Verify profile directory exists
    if [ ! -d "$FIREFOX_DIR/$PROFILE_PATH" ]; then
        log ERROR "Profile directory not found at $FIREFOX_DIR/$PROFILE_PATH"
        exit 1
    fi

    log INFO "Using profile directory: $FIREFOX_DIR/$PROFILE_PATH"

    # Create timestamp for backup
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    # Files to save
    SAVE_FILES=(
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

    # Create backup directory with timestamp
    BACKUP_DIR="$REPO_DIR/backup_$TIMESTAMP"
    mkdir -p "$BACKUP_DIR"
    log INFO "Created backup directory: $BACKUP_DIR"

    # Copy files
    log INFO "Starting backup process..."
    for file in "${SAVE_FILES[@]}"; do
        if [ -f "$FIREFOX_DIR/$PROFILE_PATH/$file" ]; then
            # Create parent directory if needed
            parent_dir=$(dirname "$BACKUP_DIR/$file")
            mkdir -p "$parent_dir"
            # Copy the file
            cp "$FIREFOX_DIR/$PROFILE_PATH/$file" "$BACKUP_DIR/$file"
            log DEBUG "Saved: $file"
        else
            log WARN "File not found (normal if not created yet): $file"
        fi
    done

    # Create latest symlink
    cd "$REPO_DIR"
    rm -f latest
    ln -s "$(basename "$BACKUP_DIR")" latest
    cd - > /dev/null

    log INFO "✔ Backup completed successfully to: $BACKUP_DIR"
}

# Run the save function
save_session
