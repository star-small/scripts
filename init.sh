#!/bin/bash
# init.sh
# This script loads your system configuration and launches Firefox with pinned tabs

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

# URLs to open
URLS=(
    "https://www.youtube.com/watch?v=p4b4jvwgU4s&list=PLw4siYvr8axuJDzM804NMT_cVfzf-RT4o&index=47"
   "https://claude.ai/"
    "https://platform.alem.school/intra"
    "https://progress.alem.school/"
    "https://moodle.astanait.edu.kz/"
    "https://www.youtube.com/"
    "https://pomofocus.io/"
)

init_system() {
    log INFO "Starting system initialization..."
    log INFO "Configuring git"
    bash conf.sh

    # Run conf script
    log INFO "Loading system configuration..."
    if [ -f "$SCRIPT_DIR/conf.sh" ]; then
        bash "$SCRIPT_DIR/conf.sh"
    else
        log ERROR "conf.sh not found in $SCRIPT_DIR"
        exit 1
    fi
    # Run load script
    log INFO "Loading system configuration..."
    if [ -f "$SCRIPT_DIR/load.sh" ]; then
        bash "$SCRIPT_DIR/load.sh"
    else
        log ERROR "load.sh not found in $SCRIPT_DIR"
        exit 1
    fi

    # Wait a moment for the configuration to be loaded
    sleep 2

    # Launch Firefox with tabs in background
    log INFO "Launching Firefox with pinned tabs (in background)..."
    
    # Build the Firefox command with nohup and background execution
    cmd="nohup firefox"
    for url in "${URLS[@]}"; do
        cmd="$cmd --new-tab '$url'"
    done
    cmd="$cmd > /dev/null 2>&1 &"

    # Execute the command
    log DEBUG "Executing Firefox in background..."
    eval $cmd

    log INFO "✔ System initialization completed"
    log INFO "Firefox is starting in the background"
}

# Run the init function
init_system
