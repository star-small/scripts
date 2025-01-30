#!/bin/bash
# load-firefox-session.sh
# This script loads Firefox profile data from the repository

# Get the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/firefox-backup"
FIREFOX_DIR="$HOME/.mozilla/firefox"
PROFILE_PATH="ymspgfvf.default-release"

load_session() {
    echo "Debug info:"
    echo "Looking for backup in: $REPO_DIR"
    echo "Current directory: $(pwd)"
    ls -la "$REPO_DIR"

    # Check if backup exists
    if [ ! -d "$REPO_DIR" ]; then
        echo "Error: Backup directory not found at $REPO_DIR"
        exit 1
    fi

    if [ ! -d "$REPO_DIR/latest" ]; then
        echo "Error: 'latest' directory not found in $REPO_DIR"
        echo "Available backups:"
        ls -la "$REPO_DIR"
        exit 1
    fi

    # Verify profile directory exists
    if [ ! -d "$FIREFOX_DIR/$PROFILE_PATH" ]; then
        echo "Error: Profile directory not found at $FIREFOX_DIR/$PROFILE_PATH"
        exit 1
    fi

    echo "Using profile directory: $FIREFOX_DIR/$PROFILE_PATH"

    # Make sure Firefox is not running
    if pgrep firefox > /dev/null; then
        echo "Please close Firefox before restoring the session"
        exit 1
    fi

    # Copy each file from the backup
    echo "Starting restore process..."
    cd "$REPO_DIR/latest" || exit 1
    
    # First, list what we're going to copy
    echo "Files to be restored:"
    find . -type f -ls

    # Then do the actual copy
    find . -type f | while read -r file; do
        target="$FIREFOX_DIR/$PROFILE_PATH/${file#./}"
        target_dir="$(dirname "$target")"
        
        # Create target directory if it doesn't exist
        mkdir -p "$target_dir"
        
        # Copy the file
        cp "$file" "$target"
        echo "Restored: ${file#./}"
    done

    echo "Session restored successfully"
}

# Run the load function
load_session
