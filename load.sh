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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
FIREFOX_DIR="$HOME/.mozilla/firefox"
CONFIG_DIR="$HOME/.config"
VSCODE_DIR="$HOME/.vscode"
PROFILE_PATH="ymspgfvf.default-release"
BACKUP_DIR="$REPO_DIR/backup"

load_session() {
    log DEBUG "Starting system restore..."
    log DEBUG "Working directory: $(pwd)"
    log DEBUG "Backup directory: $BACKUP_DIR"
    
    # Check if backup directory exists
    if [ ! -d "$BACKUP_DIR" ]; then
        log ERROR "Backup directory not found at $BACKUP_DIR"
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
    if [ -d "$BACKUP_DIR/firefox" ]; then
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
        cd "$SCRIPT_DIR" || exit 1
    else
        log WARN "Firefox backup directory not found"
    fi

    # Restore .config directory
    if [ -d "$BACKUP_DIR/config" ]; then
        log INFO "Starting .config restore..."
        rsync -av --delete \
            "$BACKUP_DIR/config/" "$CONFIG_DIR/"
        log DEBUG "Restored .config directory"
    else
        log WARN "Config backup directory not found"
    fi

    # Restore .vscode directory
    if [ -d "$BACKUP_DIR/vscode" ]; then
        log INFO "Starting VSCode restore..."
        mkdir -p "$VSCODE_DIR"
        rsync -av --delete \
            "$BACKUP_DIR/vscode/" "$VSCODE_DIR/"
        log DEBUG "Restored .vscode directory"
    else
        log WARN "VSCode backup directory not found at $BACKUP_DIR/vscode"
        # Debug info
        log DEBUG "Contents of backup directory:"
        ls -la "$BACKUP_DIR"
    fi

    log INFO "✔ System restore completed successfully"
    [ -d "$BACKUP_DIR/firefox" ] && log INFO "Firefox files restored: $file_count"
    [ -d "$BACKUP_DIR/config" ] && log INFO "Config directory restored"
    [ -d "$BACKUP_DIR/vscode" ] && log INFO "VSCode directory restored"
}

# Run the load function
load_session
