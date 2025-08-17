#!/bin/bash

# Sync Dotfiles - Sistema de sincronización inteligente
# Autor: David
# Fecha: 2025-08-14

set -e

# Configuración global
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
FONTS_DIR="$HOME/.local/share/fonts"
THEMES_DIR="$HOME/.themes"
ICONS_DIR="$HOME/.local/share/icons"
SIGNATURES_DIR="$DOTFILES_DIR/.signatures"
PYTHON_HELPER="$DOTFILES_DIR/sync_helper.py"

# Variables de modo
MODE_SYNC=false
MODE_REPLACE=false
MODE_ALL=false
SPECIFIC_COMPONENT=""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}🚀 Sync Dotfiles - Sistema de Sincronización Inteligente${NC}"
    echo ""
    echo "Uso: $0 [opciones]"
    echo ""
    echo -e "${YELLOW}Modos:${NC}"
    echo "  -s <componente>      Sincroniza componente específico (solo cambios)"
    echo "  -a                   Sincroniza todo (solo cambios)"
    echo "  -r                   Reemplaza todo (fuerza sobreescritura)"
    echo ""
    echo -e "${YELLOW}Opciones:${NC}"
    echo "  -h                   Muestra esta ayuda"
    echo ""
    echo -e "${YELLOW}Componentes disponibles:${NC}"
    echo "  hyprland, hypridle, hyprcursor, swww, waybar, rofi, dunst, ghostty, themes, fonts, icons"
    echo ""
    echo -e "${YELLOW}Ejemplos:${NC}"
    echo "  $0 -s hyprland       # Sincroniza solo Hyprland si hay cambios"
    echo "  $0 -a                # Sincroniza todo lo que cambió"
    echo "  $0 -r                # Reemplaza toda la configuración"
    echo "  $0 -s themes -r      # Reemplaza completamente los temas"
}

# Función para log con colores
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

# Verificar dependencias
check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        log "ERROR" "Python3 es requerido para el sistema de firmas"
        exit 1
    fi
    
    # Verificar que el helper de Python existe
    if [ ! -f "$PYTHON_HELPER" ]; then
        log "ERROR" "sync_helper.py no encontrado. Asegúrate de que existe en el directorio."
        exit 1
    fi
    
    # Crear directorio de firmas
    mkdir -p "$SIGNATURES_DIR"
}

# Función para verificar cambios
has_changes() {
    local component="$1"
    local source_dir="$2"
    
    if [ "$MODE_REPLACE" = true ]; then
        echo "true"
        return
    fi
    
    # Para fonts y themes usamos fecha de modificación por performance
    if [[ "$component" == "fonts" || "$component" == "themes" || "$component" == "icons" ]]; then
        check_modification_time "$component" "$source_dir"
    else
        SIGNATURES_DIR="$SIGNATURES_DIR" python3 "$PYTHON_HELPER" check "$component" "$source_dir"
    fi
}

# Verificación por fecha de modificación (para fonts y themes)
check_modification_time() {
    local component="$1"
    local source_dir="$2"
    local timestamp_file="$SIGNATURES_DIR/${component}.timestamp"
    
    if [ ! -f "$timestamp_file" ]; then
        echo "true"
        return
    fi
    
    local last_sync=$(cat "$timestamp_file" 2>/dev/null || echo "0")
    local latest_file
    
    # Usar stat en lugar de find para mejor compatibilidad
    if command -v stat &> /dev/null; then
        latest_file=$(find "$source_dir" -type f -exec stat -c '%Y' {} \; 2>/dev/null | sort -n | tail -1)
    else
        latest_file=$(find "$source_dir" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
    fi
    
    if [ -z "$latest_file" ]; then
        echo "false"
        return
    fi
    
    # Comparación simple sin bc - convertir a enteros
    latest_int=$(echo "$latest_file" | cut -d. -f1)
    last_int=$(echo "$last_sync" | cut -d. -f1)
    
    if [ "$latest_int" -gt "$last_int" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# Guardar firmas
save_signatures() {
    local component="$1"
    local source_dir="$2"
    
    if [[ "$component" == "fonts" || "$component" == "themes" || "$component" == "icons" ]]; then
        # Guardar timestamp (epoch time)
        date +%s > "$SIGNATURES_DIR/${component}.timestamp"
    else
        SIGNATURES_DIR="$SIGNATURES_DIR" python3 "$PYTHON_HELPER" save "$component" "$source_dir"
    fi
}

# Función para sincronizar .face.icon
sync_face_icon() {
    local face_icon_source="$DOTFILES_DIR/.face.icon"
    local face_icon_target="$HOME/.face.icon"
    
    if [ ! -f "$face_icon_source" ]; then
        log "DEBUG" ".face.icon no encontrado en dotfiles"
        return 0
    fi
    
    # Verificar si necesita actualización
    if [ ! -f "$face_icon_target" ] || ! cmp -s "$face_icon_source" "$face_icon_target" 2>/dev/null; then
        log "ACTION" "Sincronizando .face.icon..."
        cp "$face_icon_source" "$face_icon_target"
        log "INFO" ".face.icon actualizado"
    else
        log "DEBUG" ".face.icon sin cambios"
    fi
}

# Función para copiar archivos
sync_component() {
    local component="$1"
    local source_dir="$2"
    local target_dir="$3"
    local display_name="$4"
    
    if [ ! -d "$source_dir" ]; then
        log "WARN" "$display_name: directorio fuente no encontrado"
        return 1
    fi
    
    local changes_detected=$(has_changes "$component" "$source_dir")
    
    if [ "$changes_detected" = "false" ]; then
        log "INFO" "$display_name: sin cambios"
        return 0
    fi
    
    log "ACTION" "Sincronizando $display_name..."
    
    # Mostrar archivos que cambiaron (solo para componentes con firmas)
    if [[ "$component" != "fonts" && "$component" != "themes" && "$component" != "icons" && "$MODE_REPLACE" = false ]]; then
        local changed_files
        changed_files=$(SIGNATURES_DIR="$SIGNATURES_DIR" python3 "$PYTHON_HELPER" changes "$component" "$source_dir")
        if [ -n "$changed_files" ]; then
            log "DEBUG" "Archivos modificados:"
            echo "$changed_files" | while read -r file; do
                echo "    $file"
            done
        fi
    fi
    
    # Crear directorio de destino
    mkdir -p "$target_dir"
    
    # Copiar archivos
    cp -r "$source_dir"/* "$target_dir/"
    
    # Guardar firmas
    save_signatures "$component" "$source_dir"
    
    log "INFO" "$display_name sincronizado"
    
    # Ejecutar acciones post-sync
    post_sync_actions "$component"
    
    return 0
}

# Acciones después de sincronizar
post_sync_actions() {
    local component="$1"
    
    case $component in
        hyprland)
            if command -v hyprctl &> /dev/null; then
                log "ACTION" "Recargando Hyprland..."
                hyprctl reload &>/dev/null || true
            fi
            ;;
        hypridle)
            if pgrep hypridle &> /dev/null; then
                log "ACTION" "Reiniciando Hypridle..."
                pkill hypridle
                sleep 1
            fi
            log "ACTION" "Iniciando Hypridle..."
            nohup hypridle -c ~/.config/hypridle/hypridle.conf > /dev/null 2>&1 &
            sleep 2
            if pgrep hypridle &> /dev/null; then
                log "INFO" "Hypridle iniciado correctamente"
            else
                log "WARN" "Hypridle no se pudo iniciar - verificar configuración"
            fi
            ;;
        hyprpaper)
            # Crear directorio de wallpapers si no existe
            mkdir -p ~/Pictures/Wallpapers
            
            # Reiniciar hyprpaper si está corriendo
            if pgrep hyprpaper &> /dev/null; then
                log "ACTION" "Reiniciando Hyprpaper..."
                pkill hyprpaper
                sleep 1
            fi
            
            # Iniciar hyprpaper con nueva configuración
            if command -v hyprpaper &> /dev/null; then
                log "ACTION" "Iniciando Hyprpaper..."
                nohup hyprpaper -c ~/.config/hyprpaper/hyprpaper.conf > /dev/null 2>&1 &
                sleep 2
                
                # Verificar si se inició correctamente
                if pgrep hyprpaper &> /dev/null; then
                    log "INFO" "Hyprpaper iniciado correctamente"
                    
                    # Si no hay wallpaper actual, descargar uno
                    if [ ! -f ~/Pictures/Wallpapers/current.jpg ]; then
                        log "ACTION" "Descargando wallpaper inicial..."
                        ~/.config/hyprpaper/scripts/wallpaper_manager.sh download &>/dev/null || true
                    fi
                else
                    log "WARN" "Hyprpaper no se pudo iniciar - verificar configuración"
                fi
            else
                log "WARN" "Hyprpaper no está instalado"
            fi
            ;;
        swww)
            # Crear directorio de wallpapers si no existe
            mkdir -p ~/Pictures/Wallpapers
            
            # Reiniciar swww daemon si está corriendo
            if pgrep swww-daemon &> /dev/null; then
                log "ACTION" "Reiniciando SWWW daemon..."
                swww kill
                sleep 1
            fi
            
            # Iniciar swww daemon
            if command -v swww &> /dev/null; then
                log "ACTION" "Iniciando SWWW daemon..."
                swww-daemon &>/dev/null &
                sleep 2
                
                # Verificar si se inició correctamente
                if pgrep swww-daemon &> /dev/null; then
                    log "INFO" "SWWW daemon iniciado correctamente"
                    
                    # Si no hay wallpaper actual, descargar uno
                    if [ ! -f ~/Pictures/Wallpapers/current.jpg ]; then
                        log "ACTION" "Descargando wallpaper inicial..."
                        ~/.config/swww/scripts/wallpaper_manager.sh new &>/dev/null || true
                    else
                        log "ACTION" "Aplicando wallpaper actual..."
                        ~/.config/swww/scripts/wallpaper_manager.sh random &>/dev/null || true
                    fi
                else
                    log "WARN" "SWWW daemon no se pudo iniciar - verificar instalación"
                fi
            else
                log "WARN" "SWWW no está instalado. Instalar con: yay -S swww"
            fi
            ;;
        hyprpaper)
            log "WARN" "hyprpaper está deprecated. Usar 'swww' en su lugar"
            log "INFO" "Para migrar: sync.sh -s swww"
            ;;
        waybar)
            if pgrep waybar &> /dev/null; then
                log "ACTION" "Reiniciando Waybar..."
                pkill waybar
                hyprctl dispatch exec "waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css" 1>/dev/null &
            fi
            ;;
        dunst)
            if pgrep dunst &> /dev/null; then
                log "ACTION" "Reiniciando Dunst..."
                pkill dunst
                dunst &>/dev/null &
                sleep 1
                notify-send -i dialog-information "Dotfiles Sync" "Dunst configuración actualizada" &>/dev/null || true
            fi
            ;;
        rofi)
            log "INFO" "Rofi configuración lista"
            rofi -show drun -show-icons &>/dev/null &
            ;;
        fonts)
            log "ACTION" "Actualizando cache de fuentes..."
            fc-cache -f &>/dev/null
            ;;
        icons)
            log "INFO" "Temas de cursores instalados"
            ;;
        themes)
            log "INFO" "Temas instalados (aplicar manualmente desde configuración)"
            ;;
        sddm)
            log "INFO" "SDDM configuración actualizada (reinicio requerido)"
            ;;
    esac
}

# Funciones de sincronización por componente
sync_hyprland() {
    sync_component "hyprland" "$DOTFILES_DIR/config/hypr" "$CONFIG_DIR/hypr" "Hyprland"
    sync_face_icon
}

sync_hypridle() {
    sync_component "hypridle" "$DOTFILES_DIR/config/hypridle" "$CONFIG_DIR/hypridle" "Hypridle"
}

sync_hyprcursor() {
    sync_component "hyprcursor" "$DOTFILES_DIR/config/hyprcursor" "$CONFIG_DIR/hyprcursor" "Hyprcursor"
}

sync_swww() {
    sync_component "swww" "$DOTFILES_DIR/config/swww" "$CONFIG_DIR/swww" "SWWW"
}

sync_hyprpaper() {
    log "WARN" "hyprpaper está deprecated - usando swww en su lugar"
    sync_swww
}

sync_waybar() {
    sync_component "waybar" "$DOTFILES_DIR/config/waybar" "$CONFIG_DIR/waybar" "Waybar"
}

sync_rofi() {
    sync_component "rofi" "$DOTFILES_DIR/config/rofi" "$CONFIG_DIR/rofi" "Rofi"
}

sync_dunst() {
    sync_component "dunst" "$DOTFILES_DIR/config/dunst" "$CONFIG_DIR/dunst" "Dunst"
}

sync_ghostty() {
    sync_component "ghostty" "$DOTFILES_DIR/config/ghostty" "$CONFIG_DIR/ghostty" "Ghostty"
}

sync_themes() {
    sync_component "themes" "$DOTFILES_DIR/themes/GTK" "$THEMES_DIR" "Temas GTK"
    sync_face_icon
}

sync_fonts() {
    sync_component "fonts" "$DOTFILES_DIR/fonts" "$FONTS_DIR" "Fuentes"
}

sync_icons() {
    sync_component "icons" "$DOTFILES_DIR/icons" "$ICONS_DIR" "Iconos de cursor"
}

sync_sddm() {
    local component="sddm"
    local source_dir="$DOTFILES_DIR/config/sddm"
    
    if [ ! -d "$source_dir" ]; then
        log "WARN" "SDDM: directorio fuente no encontrado"
        return 1
    fi
    
    local changes_detected=$(has_changes "$component" "$source_dir")
    
    if [ "$changes_detected" = "false" ]; then
        log "INFO" "SDDM: sin cambios"
        return 0
    fi
    
    log "ACTION" "Sincronizando SDDM..."
    
    # Configuración principal
    if [ -f "$source_dir/sddm.conf" ]; then
        # Verificar si los archivos son diferentes antes de copiar
        if ! cmp -s "$source_dir/sddm.conf" "/etc/sddm.conf" 2>/dev/null; then
            sudo cp "$source_dir/sddm.conf" "/etc/sddm.conf"
            log "INFO" "SDDM configuración principal actualizada"
        else
            log "INFO" "SDDM configuración ya actualizada"
        fi
    fi
    
    # Temas
    if [ -d "$DOTFILES_DIR/themes/sddm" ]; then
        sudo mkdir -p /usr/share/sddm/themes
        sudo cp -r "$DOTFILES_DIR/themes/sddm"/* /usr/share/sddm/themes/
        log "INFO" "Temas SDDM actualizados"
    fi
    
    save_signatures "$component" "$source_dir"
    post_sync_actions "$component"
    sync_face_icon
}

# Función principal de sincronización
sync_all() {
    log "INFO" "Iniciando sincronización completa..."
    
    sync_hyprland
    sync_hypridle
    sync_hyprcursor
    sync_swww
    sync_waybar
    sync_rofi
    sync_dunst
    sync_ghostty
    sync_themes
    sync_fonts
    sync_icons
    sync_sddm
    
    log "INFO" "Sincronización completa terminada"
}

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -s)
            MODE_SYNC=true
            SPECIFIC_COMPONENT="$2"
            shift 2
            ;;
        -a)
            MODE_ALL=true
            shift
            ;;
        -r)
            MODE_REPLACE=true
            shift
            ;;
        -h)
            show_help
            exit 0
            ;;
        *)
            log "ERROR" "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Verificar dependencias
check_dependencies

# Lógica principal
if [ "$MODE_SYNC" = true ] && [ -n "$SPECIFIC_COMPONENT" ]; then
    case $SPECIFIC_COMPONENT in
        hyprland) sync_hyprland ;;
        hypridle) sync_hypridle ;;
        hyprcursor) sync_hyprcursor ;;
        swww) sync_swww ;;
        hyprpaper) sync_hyprpaper ;;
        waybar) sync_waybar ;;
        rofi) sync_rofi ;;
        dunst) sync_dunst ;;
        ghostty) sync_ghostty ;;
        themes) sync_themes ;;
        fonts) sync_fonts ;;
        icons) sync_icons ;;
        sddm) sync_sddm ;;
        *)
            log "ERROR" "Componente desconocido: $SPECIFIC_COMPONENT"
            echo "Componentes disponibles: hyprland, hypridle, hyprcursor, swww, hyprpaper (deprecated), waybar, rofi, dunst, ghostty, themes, fonts, icons, sddm"
            exit 1
            ;;
    esac
elif [ "$MODE_ALL" = true ] || [ "$MODE_REPLACE" = true ]; then
    sync_all
else
    show_help
    exit 1
fi

echo ""
log "INFO" "Proceso completado"
