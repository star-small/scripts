#!/bin/bash
# load-firefox-session.sh
# This script restores Firefox profile, .config and .vscode data from the repository

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
VSCODE_DIR="$HOME/.vscode"
PROFILE_PATH="ymspgfvf.default-release"
BACKUP_DIR="backup"

load_session() {
    log DEBUG "Starting system restore..."
    
    # Check if backup directories exist
    if [ ! -d "$BACKUP_DIR/firefox" ]; then
        log ERROR "Firefox backup directory not found at $BACKUP_DIR/firefox"
        exit 1
    fi

    if [ ! -d "$BACKUP_DIR/config" ]; then
        log ERROR "Config backup directory not found at $BACKUP_DIR/config"
        exit 1
    fi

    # Verify Firefox profile directory exists
    if [ ! -d "$FIREFOX_DIR/$PROFILE_PATH" ]; then
        log ERROR "Firefox profile directory not found at $FIREFOX_DIR/$PROFILE_PATH"
        exit 1
    fi

    # Make sure Firefox is not running
    if pgrep firefox > /dev/null; then
        log ERROR "Please close Firefox before restoring the session"
        exit 1
    fi

    # Restore Firefox files
    log INFO "Starting Firefox restore..."
    cd "$BACKUP_DIR/firefox" || exit 1
    
    file_count=$(find . -type f | wc -l)
    log INFO "Found $file_count Firefox files to restore"

    restored=0
    find . -type f | while read -r file; do
        target="$FIREFOX_DIR/$PROFILE_PATH/${file#./}"
        target_dir="$(dirname "$target")"
        mkdir -p "$target_dir"
        cp "$file" "$target"
        ((restored++))
        log DEBUG "Restored Firefox ($restored/$file_count): ${file#./}"
    done

    # Restore .config directory
    log INFO "Starting .config restore..."
    rsync -av --delete \
        "$BACKUP_DIR/config/" "$CONFIG_DIR/"
    log DEBUG "Restored .config directory"

    # Restore .vscode directory if it exists in backup
    if [ -d "$BACKUP_DIR/vscode" ]; then
        log INFO "Starting VSCode restore..."
        mkdir -p "$VSCODE_DIR"
        rsync -av --delete \
            "$BACKUP_DIR/vscode/" "$VSCODE_DIR/"
        log DEBUG "Restored .vscode directory"
    else
        log WARN "VSCode backup not found, skipping"
	ls $BACKUP_DIR/vscode
    fi

    log INFO "✔ System restore completed successfully"
    log INFO "Firefox files restored: $file_count"
    log INFO "Config directory restored"
    [ -d "$BACKUP_DIR/vscode" ] && log INFO "VSCode directory restored"
}

# Run the load function
load_session
