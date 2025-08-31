#!/bin/bash

# Chat Popup - Installation script
# This script installs the chat application as a standalone package

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function for colored logging
log() {
    local level="$1"
    shift
    case $level in
        "INFO")  echo -e "${GREEN}✅ $*${NC}" ;;
        "WARN")  echo -e "${YELLOW}⚠️  $*${NC}" ;;
        "ERROR") echo -e "${RED}❌ $*${NC}" ;;
        "DEBUG") echo -e "${CYAN}🔍 $*${NC}" ;;
        "ACTION") echo -e "${PURPLE}🔄 $*${NC}" ;;
    esac
}

# Function to show help
show_help() {
    echo -e "${BLUE}💬 Chat Popup - Installer${NC}"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -h, --help       Show this help message"
    echo "  -f, --force      Force reinstallation"
    echo "  -u, --uninstall  Uninstall the application"
    echo ""
    echo -e "${YELLOW}Description:${NC}"
    echo "  This script installs the Chat Popup application to:"
    echo "  • Executable: ~/.local/bin/chat-popup"
    echo "  • Application: ~/.local/share/chat-popup/"
    echo ""
}

# Check dependencies
check_dependencies() {
    if ! command -v npm &> /dev/null; then
        log "ERROR" "npm is not installed. Install Node.js: sudo pacman -S nodejs npm"
        exit 1
    fi
    
    if ! command -v node &> /dev/null; then
        log "ERROR" "Node.js is not installed. Install: sudo pacman -S nodejs npm"
        exit 1
    fi
    
    log "DEBUG" "Node.js $(node --version) and npm $(npm --version) available"
}

# Function to uninstall
uninstall_chat() {
    log "ACTION" "Uninstalling Chat Popup..."
    
    # Remove executable
    if [ -f "$HOME/.local/bin/chat-popup" ]; then
        rm -f "$HOME/.local/bin/chat-popup"
        log "INFO" "Executable removed"
    fi
    
    # Remove application
    if [ -d "$HOME/.local/share/chat-popup" ]; then
        rm -rf "$HOME/.local/share/chat-popup"
        log "INFO" "Application removed"
    fi
    
    # Remove logs and data (optional)
    if [ -d "$HOME/.local/share/chat-popup" ]; then
        rm -rf "$HOME/.local/share/chat-popup"
        log "INFO" "Data and logs removed"
    fi
    
    log "INFO" "Chat Popup fully uninstalled"
}

# Main installation function
install_chat() {
    local force_install="$1"
    
    log "ACTION" "Installing Chat Popup..."
    
    # Check if already installed
    if [ -f "$HOME/.local/bin/chat-popup" ] && [ "$force_install" != "true" ]; then
        log "INFO" "Chat Popup is already installed. Use --force to reinstall"
        return 0
    fi
    
    # Get script directory
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ ! -f "$script_dir/package.json" ]; then
        log "ERROR" "package.json no encontrado en $script_dir"
        exit 1
    fi
    
    # Create temporary directory for installation
    local temp_dir="/tmp/chat-popup-install-$$"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    
    log "DEBUG" "Temporary directory: $temp_dir"
    
    # Copy source files to temporary directory
    log "ACTION" "Preparing files..."
    cp -r "$script_dir"/* "$temp_dir/"
    
    # Remove install.sh from temp (not needed in installation)
    rm -f "$temp_dir/install.sh"
    
    # Change to temporary directory
    cd "$temp_dir" || {
        log "ERROR" "No se puede acceder al directorio temporal"
        exit 1
    }
    
    # Install ONLY production dependencies
    log "ACTION" "Installing production dependencies..."
    if npm install --production --silent; then
        log "INFO" "Dependencies installed successfully"
    else
        log "ERROR" "Error installing dependencies"
        exit 1
    fi
    
    # Create destination directories
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share"
    
    # Create directory for the installed application
    local app_install_dir="$HOME/.local/share/chat-popup"
    rm -rf "$app_install_dir"
    mkdir -p "$app_install_dir"
    
    # Copy the whole application with dependencies
    log "ACTION" "Installing application..."
    cp -r "$temp_dir"/* "$app_install_dir/"
    
    # Create a wrapper executable in PATH that points to the real application
    log "ACTION" "Creating executable in PATH..."
    cat > "$HOME/.local/bin/chat-popup" << 'EOF'
#!/bin/bash
# Chat Popup - Executable wrapper
# This script runs the real application installed in ~/.local/share/chat-popup/

exec "$HOME/.local/share/chat-popup/launch.sh" "$@"
EOF
    
    chmod +x "$HOME/.local/bin/chat-popup"
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    
    log "INFO" "Chat Popup installed successfully"
    log "INFO" "Run with: chat-popup"
    log "DEBUG" "Executable: ~/.local/bin/chat-popup"
    log "DEBUG" "Application: ~/.local/share/chat-popup/"
}

# Process arguments
FORCE_INSTALL=false
UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE_INSTALL=true
            shift
            ;;
        -u|--uninstall)
            UNINSTALL=true
            shift
            ;;
        *)
            log "ERROR" "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check dependencies
check_dependencies

# Execute requested action
if [ "$UNINSTALL" = true ]; then
    uninstall_chat
else
    install_chat "$FORCE_INSTALL"
fi

log "INFO" "Process completed"
