#!/bin/bash
# save-firefox-session.sh
# This script saves Firefox profile data to a repository

# Set the repository location
REPO_DIR="firefox-backup"
FIREFOX_DIR="$HOME/.mozilla/firefox"
PROFILE_PATH="ymspgfvf.default-release"  # Your specific profile path

save_session() {
    # Create repository directory if it doesn't exist
    mkdir -p "$REPO_DIR"

    # Verify profile directory exists
    if [ ! -d "$FIREFOX_DIR/$PROFILE_PATH" ]; then
        echo "Error: Profile directory not found at $FIREFOX_DIR/$PROFILE_PATH"
        exit 1
    fi

    echo "Using profile directory: $FIREFOX_DIR/$PROFILE_PATH"

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

    # Copy files
    for file in "${SAVE_FILES[@]}"; do
        if [ -f "$FIREFOX_DIR/$PROFILE_PATH/$file" ]; then
            # Create parent directory if needed
            parent_dir=$(dirname "$BACKUP_DIR/$file")
            mkdir -p "$parent_dir"
            # Copy the file
            cp "$FIREFOX_DIR/$PROFILE_PATH/$file" "$BACKUP_DIR/$file"
            echo "Saved $file"
        else
            echo "Note: $file not found (this is normal if the file hasn't been created yet)"
        fi
    done

    # Create latest symlink
    rm -f "$REPO_DIR/latest"
    ln -s "$BACKUP_DIR" "$REPO_DIR/latest"

    echo "Session saved to $BACKUP_DIR"
}

# Run the save function
save_session
