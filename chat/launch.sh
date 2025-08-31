#!/bin/bash

# Set full PATH
export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$PATH"

# Environment variables required for Electron
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Installed application directory
APP_DIR="$HOME/.local/share/chat-popup"

# Logs directory (using XDG_DATA_HOME)
LOG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/chat-popup/logs"
LOG_FILE="$LOG_DIR/app.log"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Clear previous log

log "=== Starting Chat Popup ==="
log "USER: $USER"
log "HOME: $HOME" 
log "PATH: $PATH"
log "DISPLAY: $DISPLAY"
log "APP_DIR: $APP_DIR"

# Change to the installed application directory
cd "$APP_DIR" || {
    log "ERROR: Cannot change directory to $APP_DIR"
    exit 1
}

log "Current directory: $(pwd)"

# Check that electron is available
which npx >> "$LOG_FILE" 2>&1
log "npx location: $(which npx)"

# Run the application with nohup to detach from the parent process
log "Running application..."
nohup npx electron . >> "$LOG_FILE" 2>&1 &
ELECTRON_PID=$!

log "Application started with PID: $ELECTRON_PID"

# Detach from parent process
disown
disown
