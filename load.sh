#!/bin/bash
# load-firefox-session.sh
# This script loads Firefox profile data from the repository

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
PROFILE_PATH="ymspgfvf.default-release"
BACKUP_DIR="backup"

load_session() {
    log DEBUG "Starting Firefox session restore..."
    
    # Check if backup directory exists
    if [ ! -d "$BACKUP_DIR" ]; then
        log ERROR "Backup directory not found at $BACKUP_DIR"
        exit 1
    fi

    log INFO "Using backup directory: $BACKUP_DIR"

    # Verify profile directory exists
    if [ ! -d "$FIREFOX_DIR/$PROFILE_PATH" ]; then
        log ERROR "Profile directory not found at $FIREFOX_DIR/$PROFILE_PATH"
        exit 1
    fi

    log INFO "Profile directory: $FIREFOX_DIR/$PROFILE_PATH"

    # Make sure Firefox is not running
    if pgrep firefox > /dev/null; then
        log ERROR "Please close Firefox before restoring the session"
        exit 1
    fi

    # Copy each file from the backup
    log INFO "Starting restore process..."
    cd "$BACKUP_DIR" || exit 1
    
    # First, list what we're going to copy
    log DEBUG "Scanning files to restore..."
    file_count=$(find . -type f ! -name "backup_info.txt" | wc -l)
    log INFO "Found $file_count files to restore"

    # Then do the actual copy
    restored=0
    find . -type f ! -name "backup_info.txt" | while read -r file; do
        target="$FIREFOX_DIR/$PROFILE_PATH/${file#./}"
        target_dir="$(dirname "$target")"
        
        # Create target directory if it doesn't exist
        mkdir -p "$target_dir"
        
        # Copy the file
        cp "$file" "$target"
        ((restored++))
        log DEBUG "Restored ($restored/$file_count): ${file#./}"
    done

    log INFO "✔ Session restore completed successfully"
    log INFO "Total files restored: $file_count"
}

# Run the load function
load_session
