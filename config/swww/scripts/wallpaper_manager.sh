#!/bin/bash

# SWWW Wallpaper Manager - Downloads and rotates wallpapers from Wallhaven
# Author: David
# Date: $(date +%Y-%m-%d)

set -e

# Configuración
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CURRENT_WALLPAPER="$WALLPAPER_DIR/current.jpg"
WALLHAVEN_API="https://wallhaven.cc/api/v1/search"
USER_AGENT="SWWW-Manager/1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Colored logging function
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

# Show help
show_help() {
    echo -e "${BLUE}🖼️  SWWW Wallpaper Manager${NC}"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  download     Download a new random wallpaper"
    echo "  new          Download and apply a new wallpaper immediately"
    echo "  random       Pick a random wallpaper from local collection"
    echo "  next         Switch to the next wallpaper"
    echo "  prev         Switch to the previous wallpaper"
    echo "  current      Show information about the current wallpaper"
    echo "  clean        Clean old wallpapers (keeps last 20)"
    echo "  restart      Restart swww daemon (fixes buffer issues)"
    echo "  config       Show current configuration from swww.conf"
    echo "  test         Test wallpaper change with current settings"
    echo "  -h, --help   Show this help"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 new       # Download and apply a new wallpaper immediately"
    echo "  $0 random    # Pick a random local wallpaper"
    echo "  $0 next      # Next local wallpaper"
    echo "  $0 prev      # Previous local wallpaper"
    echo "  $0 current   # Show current wallpaper info"
    echo ""
    echo -e "${CYAN}Wallpapers are stored in: $WALLPAPER_DIR${NC}"
}

# Verify dependencies
check_dependencies() {
    local deps=("curl" "jq" "swww")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "ERROR" "Missing dependency: $dep"
            case $dep in
                "curl") echo "Instalar con: sudo pacman -S curl" ;;
                "jq") echo "Install with: sudo pacman -S jq" ;;
                "swww") echo "Install with: yay -S swww" ;;
            esac
            exit 1
        fi
    done
}

# Check swww daemon status and clean up if needed
check_swww_status() {
    log "DEBUG" "Checking swww daemon status..."
    
    # Check if daemon is running but not responding
    if pgrep swww-daemon > /dev/null; then
        if ! swww query &>/dev/null; then
            log "WARN" "Swww daemon is running but not responding, restarting..."
            swww kill 2>/dev/null || true
            sleep 2
            swww-daemon &
            sleep 3
        fi
    fi
    
    # Verify daemon is working
    local retry_count=0
    while ! swww query &>/dev/null && [ $retry_count -lt 5 ]; do
        if [ $retry_count -eq 0 ]; then
            log "DEBUG" "Starting swww daemon..."
            swww-daemon &
        fi
        sleep 1
        ((retry_count++))
    done
    
    if [ $retry_count -eq 5 ]; then
        log "ERROR" "Failed to start or connect to swww daemon"
        return 1
    fi
    
    log "DEBUG" "Swww daemon is ready"
    return 0
}

# Create required directories
setup_directories() {
    mkdir -p "$WALLPAPER_DIR"
    log "DEBUG" "Wallpaper directory: $WALLPAPER_DIR"
}

# Download a random wallpaper from Wallhaven
download_wallpaper() {
    log "ACTION" "Searching for a wallpaper on Wallhaven..."
    
    # Parameters to filter by natural landscapes
    # categories: 100 = General, 010 = Anime, 001 = People
    # purity: 100 = SFW, 010 = Sketchy, 001 = NSFW
    # q: search terms (landscape, nature, mountains, forest, etc.)
    local search_terms=("landscape" "nature" "mountains" "forest" "ocean" "sunset" "sunrise" "scenic" "natural")
    local random_term=${search_terms[$RANDOM % ${#search_terms[@]}]}
    
    local api_url="${WALLHAVEN_API}?categories=100&purity=100&atleast=1920x1080&q=${random_term}&sorting=random"
    
    log "DEBUG" "Search term: $random_term"
    log "DEBUG" "API URL: $api_url"
    
    # Hacer petición a la API
    local response
    response=$(curl -s -A "$USER_AGENT" "$api_url")
    
    if [ $? -ne 0 ]; then
        log "ERROR" "Error connecting to Wallhaven API"
        return 1
    fi
    
    # Extraer URL de la imagen
    local wallpaper_url
    wallpaper_url=$(echo "$response" | jq -r '.data[0].path' 2>/dev/null)
    
    if [ "$wallpaper_url" = "null" ] || [ -z "$wallpaper_url" ]; then
        log "ERROR" "No wallpapers found for term: $random_term"
        return 1
    fi
    
    # Generar nombre único para el archivo
    local wallpaper_id
    wallpaper_id=$(echo "$response" | jq -r '.data[0].id')
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local filename="${timestamp}_${wallpaper_id}.jpg"
    local filepath="$WALLPAPER_DIR/$filename"
    
    log "ACTION" "Downloading wallpaper: $wallpaper_id"
    
    # Descargar imagen
    if curl -s -A "$USER_AGENT" -o "$filepath" "$wallpaper_url"; then
    # Update symlink to the current wallpaper
    ln -sf "$filepath" "$CURRENT_WALLPAPER"
    log "INFO" "Wallpaper downloaded: $filename"
        
        # Aplicar wallpaper (replicando el método manual que funcionó)
        apply_wallpaper "$filepath"
        
    # Clean up old wallpapers
    cleanup_old_wallpapers
        
        return 0
    else
        log "ERROR" "Error downloading wallpaper"
        rm -f "$filepath" 2>/dev/null
        return 1
    fi
}

# Rotate through local wallpapers (directional)
rotate_wallpaper() {
    local direction="${1:-next}"  # next o prev
    local wallpapers=()
    mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" | grep -v current.jpg | sort)
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        log "WARN" "No local wallpapers found. Downloading a new one..."
        download_wallpaper
        return $?
    fi
    
    # Find the current wallpaper
    local current_real_path
    if [ -L "$CURRENT_WALLPAPER" ]; then
        current_real_path=$(readlink "$CURRENT_WALLPAPER")
    else
        current_real_path=""
    fi
    
    local target_wallpaper=""
    local current_index=-1
    
    # Find the index of the current wallpaper
    for i in "${!wallpapers[@]}"; do
        if [ "${wallpapers[$i]}" = "$current_real_path" ]; then
            current_index=$i
            break
        fi
    done
    
    # Calcular índice siguiente o anterior
    if [ "$direction" = "next" ]; then
        if [ $current_index -eq -1 ] || [ $current_index -eq $((${#wallpapers[@]} - 1)) ]; then
            target_wallpaper="${wallpapers[0]}"  # Volver al primero
        else
            target_wallpaper="${wallpapers[$((current_index + 1))]}"
        fi
    else  # prev
        if [ $current_index -eq -1 ] || [ $current_index -eq 0 ]; then
            target_wallpaper="${wallpapers[$((${#wallpapers[@]} - 1))]}"  # Ir al último
        else
            target_wallpaper="${wallpapers[$((current_index - 1))]}"
        fi
    fi
    
    # Actualizar symlink
    ln -sf "$target_wallpaper" "$CURRENT_WALLPAPER"
    
    local filename=$(basename "$target_wallpaper")
    local dir_text=$([ "$direction" = "next" ] && echo "next" || echo "previous")
    log "INFO" "Switching to $dir_text wallpaper: $filename"
    
    # Aplicar wallpaper (replicando el método manual que funcionó)
    apply_wallpaper "$target_wallpaper"
}

# Read SWWW configuration from config file
read_swww_config() {
    local config_file="$HOME/.config/swww/swww.conf"
    if [ -f "$config_file" ]; then
        # Extract values from config file
        SWWW_TRANSITION_TYPE=$(grep "^transition-type" "$config_file" | cut -d'=' -f2 | tr -d ' ')
        SWWW_TRANSITION_DURATION=$(grep "^transition-duration" "$config_file" | cut -d'=' -f2 | tr -d ' ')
        SWWW_TRANSITION_FPS=$(grep "^transition-fps" "$config_file" | cut -d'=' -f2 | tr -d ' ')
        SWWW_TRANSITION_POS=$(grep "^transition-pos" "$config_file" | cut -d'=' -f2 | tr -d ' ')
        SWWW_RESIZE=$(grep "^resize" "$config_file" | cut -d'=' -f2 | tr -d ' ')
        
        # Set defaults if not found
        SWWW_TRANSITION_TYPE="${SWWW_TRANSITION_TYPE:-grow}"
        SWWW_TRANSITION_DURATION="${SWWW_TRANSITION_DURATION:-1.5}"
        SWWW_TRANSITION_FPS="${SWWW_TRANSITION_FPS:-60}"
        SWWW_TRANSITION_POS="${SWWW_TRANSITION_POS:-0.5,0.5}"
        SWWW_RESIZE="${SWWW_RESIZE:-crop}"
    else
        # Default values if config file doesn't exist
        SWWW_TRANSITION_TYPE="grow"
        SWWW_TRANSITION_DURATION="1.5"
        SWWW_TRANSITION_FPS="60"
        SWWW_TRANSITION_POS="0.5,0.5"
        SWWW_RESIZE="crop"
    fi
    
    log "DEBUG" "SWWW Config loaded - Type: $SWWW_TRANSITION_TYPE, Duration: $SWWW_TRANSITION_DURATION, FPS: $SWWW_TRANSITION_FPS"
}

# Configure transition effects for swww
configure_transition() {
    local effect_type="${1:-config}"
    
    case $effect_type in
        "config")
            # Use configuration from swww.conf
            echo "--transition-type $SWWW_TRANSITION_TYPE --transition-duration $SWWW_TRANSITION_DURATION --transition-fps $SWWW_TRANSITION_FPS --transition-pos $SWWW_TRANSITION_POS --resize $SWWW_RESIZE"
            ;;
        "circle"|"circular")
            echo "--transition-type grow --transition-pos 0.5,0.5 --transition-duration $SWWW_TRANSITION_DURATION --transition-fps $SWWW_TRANSITION_FPS --resize $SWWW_RESIZE"
            ;;
        "wave")
            echo "--transition-type wave --transition-angle 45 --transition-duration $SWWW_TRANSITION_DURATION --transition-fps $SWWW_TRANSITION_FPS --resize $SWWW_RESIZE"
            ;;
        "fade")
            echo "--transition-type fade --transition-duration $SWWW_TRANSITION_DURATION --transition-fps $SWWW_TRANSITION_FPS --resize $SWWW_RESIZE"
            ;;
        "wipe")
            local directions=("left" "right" "top" "bottom")
            local random_dir=${directions[$RANDOM % ${#directions[@]}]}
            echo "--transition-type $random_dir --transition-duration $SWWW_TRANSITION_DURATION --transition-fps $SWWW_TRANSITION_FPS --resize $SWWW_RESIZE"
            ;;
        "random"|*)
            local effects=("grow" "outer" "wipe" "wave" "fade" "left" "right")
            local random_effect=${effects[$RANDOM % ${#effects[@]}]}
            if [ "$random_effect" = "grow" ]; then
                echo "--transition-type grow --transition-pos 0.5,0.5 --transition-duration $SWWW_TRANSITION_DURATION --transition-fps $SWWW_TRANSITION_FPS --resize $SWWW_RESIZE"
            else
                echo "--transition-type $random_effect --transition-duration $SWWW_TRANSITION_DURATION --transition-fps $SWWW_TRANSITION_FPS --resize $SWWW_RESIZE"
            fi
            ;;
    esac
}

# Apply wallpaper using swww
apply_wallpaper() {
    local wallpaper_path="$1"
    
    if [ ! -f "$wallpaper_path" ]; then
        log "ERROR" "Wallpaper no encontrado: $wallpaper_path"
        return 1
    fi
    
    log "ACTION" "Applying wallpaper with transition effect..."
    
    # Check and ensure swww daemon is ready
    if ! check_swww_status; then
        return 1
    fi
    
    # Clear cache to prevent buffer issues
    swww clear-cache 2>/dev/null || true
    
    # Load configuration from swww.conf
    read_swww_config
    
    # Configurar transición - usar configuración del archivo o efecto suave por defecto
    local transition_options=$(configure_transition "config")
    
    # Apply wallpaper with settings from config file
    if swww img "$wallpaper_path" $transition_options 2>/dev/null; then
        
        log "INFO" "Wallpaper applied with transition effect"
        
        # Send notification
        if command -v notify-send &> /dev/null; then
            local filename=$(basename "$wallpaper_path")
            notify-send -i image-x-generic "Wallpaper Manager" "Wallpaper: $filename" 2>/dev/null || true
        fi
        
        return 0
    else
        log "ERROR" "Error applying wallpaper"
        return 1
    fi
}

# Show information about the current wallpaper
show_current_info() {
    if [ -L "$CURRENT_WALLPAPER" ]; then
        local real_path
        real_path=$(readlink "$CURRENT_WALLPAPER")
        local filename=$(basename "$real_path")
        local filesize
        filesize=$(du -h "$real_path" 2>/dev/null | cut -f1)

        echo -e "${BLUE}📷 Current Wallpaper:${NC}"
        echo -e "  File: ${CYAN}$filename${NC}"
        echo -e "  Size: ${CYAN}$filesize${NC}"
        echo -e "  Path: ${CYAN}$real_path${NC}"

        # Show dimensions if identify is available
        if command -v identify &> /dev/null; then
            local dimensions
            dimensions=$(identify -format "%wx%h" "$real_path" 2>/dev/null)
            echo -e "  Dimensions: ${CYAN}$dimensions${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  No current wallpaper is set${NC}"
    fi

    # Show total number of local wallpapers
    local total_wallpapers
    total_wallpapers=$(find "$WALLPAPER_DIR" -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" | grep -v current.jpg | wc -l)
    echo -e "  Total wallpapers: ${CYAN}$total_wallpapers${NC}"
}

# Clean up old wallpapers (keep last 20)
cleanup_old_wallpapers() {
    local keep_count=20
    local wallpapers=()
    
    mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" | grep -v current.jpg | sort -r)
    
    if [ ${#wallpapers[@]} -gt $keep_count ]; then
        log "ACTION" "Cleaning up old wallpapers..."
        
        local to_remove=()
        for (( i=$keep_count; i<${#wallpapers[@]}; i++ )); do
            to_remove+=("${wallpapers[$i]}")
        done
        
        for wallpaper in "${to_remove[@]}"; do
            rm -f "$wallpaper"
            log "DEBUG" "Removed: $(basename "$wallpaper")"
        done
        
        log "INFO" "Kept $keep_count most recent wallpapers"
    fi
}

# Download and apply a new wallpaper immediately
new_wallpaper() {
    log "ACTION" "Downloading and applying a new wallpaper..."
    
    # Descargar wallpaper
    if download_wallpaper; then
        log "INFO" "New wallpaper downloaded and applied successfully"
        return 0
    else
        log "ERROR" "Error downloading new wallpaper"
        return 1
    fi
}

# Select a random wallpaper from existing local files
random_wallpaper() {
    local wallpapers=()
    mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" | grep -v current.jpg)
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        log "WARN" "No local wallpapers found. Downloading a new one..."
        download_wallpaper
        return $?
    fi
    
    # Seleccionar wallpaper aleatorio
    local random_index=$((RANDOM % ${#wallpapers[@]}))
    local selected_wallpaper="${wallpapers[$random_index]}"
    
    # Actualizar symlink
    ln -sf "$selected_wallpaper" "$CURRENT_WALLPAPER"
    
    local filename=$(basename "$selected_wallpaper")
    log "INFO" "Random wallpaper selected: $filename"
    
    # Aplicar wallpaper
    apply_wallpaper "$selected_wallpaper"
}

# Show current SWWW configuration
show_config() {
    local config_file="$HOME/.config/swww/swww.conf"
    
    echo -e "${BLUE}🔧 SWWW Configuration${NC}"
    
    if [ -f "$config_file" ]; then
        echo -e "  Config file: ${CYAN}$config_file${NC}"
        echo ""
        
        read_swww_config
        
        echo -e "${YELLOW}Settings from config file:${NC}"
        echo -e "  Transition Type: ${CYAN}$SWWW_TRANSITION_TYPE${NC}"
        echo -e "  Transition Duration: ${CYAN}$SWWW_TRANSITION_DURATION${NC} seconds"
        echo -e "  Transition FPS: ${CYAN}$SWWW_TRANSITION_FPS${NC}"
        echo -e "  Transition Position: ${CYAN}$SWWW_TRANSITION_POS${NC}"
        echo -e "  Resize Mode: ${CYAN}$SWWW_RESIZE${NC}"
        
        echo ""
        echo -e "${YELLOW}Command that will be executed:${NC}"
        local transition_options=$(configure_transition "config")
        echo -e "  ${CYAN}swww img [wallpaper] $transition_options${NC}"
        
    else
        echo -e "  ${YELLOW}⚠️  Config file not found: $config_file${NC}"
        echo -e "  ${CYAN}Using default settings${NC}"
    fi
}

# Test current wallpaper with configuration settings
test_config() {
    log "ACTION" "Testing wallpaper application with current config..."
    
    if [ -L "$CURRENT_WALLPAPER" ]; then
        local real_path
        real_path=$(readlink "$CURRENT_WALLPAPER")
        
        if [ -f "$real_path" ]; then
            log "INFO" "Re-applying current wallpaper: $(basename "$real_path")"
            apply_wallpaper "$real_path"
        else
            log "ERROR" "Current wallpaper file not found: $real_path"
            return 1
        fi
    else
        log "WARN" "No current wallpaper set. Using random wallpaper for test..."
        random_wallpaper
    fi
}

# Manually trigger cleanup of old wallpapers
clean_wallpapers() {
    log "ACTION" "Cleaning old wallpapers..."
    cleanup_old_wallpapers
}

# Función principal
main() {
    case "${1:-}" in
        "download")
            check_dependencies
            setup_directories
            download_wallpaper
            ;;
        "new")
            check_dependencies
            setup_directories
            new_wallpaper
            ;;
        "random")
            check_dependencies
            setup_directories
            random_wallpaper
            ;;
        "next")
            check_dependencies
            setup_directories
            rotate_wallpaper "next"
            ;;
        "prev")
            check_dependencies
            setup_directories
            rotate_wallpaper "prev"
            ;;
        "current")
            setup_directories
            show_current_info
            ;;
        "clean")
            setup_directories
            clean_wallpapers
            ;;
        "config")
            show_config
            ;;
        "test")
            check_dependencies
            setup_directories
            test_config
            ;;
        "restart")
            log "ACTION" "Restarting swww daemon..."
            swww kill 2>/dev/null || true
            sleep 2
            swww-daemon &
            sleep 3
            if swww query &>/dev/null; then
                log "INFO" "Swww daemon restarted successfully"
            else
                log "ERROR" "Failed to restart swww daemon"
                exit 1
            fi
            ;;
        "-h"|"--help"|"help")
            show_help
            ;;
        "")
            show_help
            ;;
        *)
            log "ERROR" "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"
