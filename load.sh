#!/bin/bash
# load-ssh.sh
# This script loads only the .ssh directory from backup

# Colors and formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
BACKUP_DIR="$SCRIPT_DIR/backup/config/.ssh"
SSH_DIR="$HOME/.ssh"

load_ssh() {
    log DEBUG "Starting SSH configuration restore..."

    # Check if backup exists
    if [ ! -d "$BACKUP_DIR" ]; then
        log ERROR "SSH backup not found at $BACKUP_DIR"
        exit 1
    fi

    # Create .ssh directory if it doesn't exist
    mkdir -p "$SSH_DIR"

    # Restore .ssh directory
    log INFO "Restoring SSH configuration..."
    rsync -av --delete \
        "$BACKUP_DIR/" "$SSH_DIR/"

    # Set correct permissions
    chmod 700 "$SSH_DIR"
    find "$SSH_DIR" -type f -name "id_*" -exec chmod 600 {} \;
    find "$SSH_DIR" -type f -name "*.pub" -exec chmod 644 {} \;

    log INFO "✔ SSH configuration restored successfully"
}

# Run the load function
load_ssh
