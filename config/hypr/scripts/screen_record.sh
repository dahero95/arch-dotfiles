#!/bin/bash

# Script de grabación de pantalla para Hyprland
# Soporta grabación completa, selección de área y ventana específica

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# Directorio para guardar grabaciones
SAVE_DIR="$HOME/Videos/Recordings"
mkdir -p "$SAVE_DIR"

# Archivo temporal para el PID del proceso de grabación
PID_FILE="/tmp/screen_record.pid"

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}🎥 Script de Grabación de Pantalla${NC}"
    echo -e "${GREEN}Uso: $0 [OPCIÓN]${NC}"
    echo
    echo -e "${YELLOW}Opciones:${NC}"
    echo "  full      - Grabar pantalla completa"
    echo "  area      - Grabar área seleccionada"
    echo "  window    - Grabar ventana específica"
    echo "  stop      - Detener grabación actual"
    echo "  status    - Ver estado de grabación"
    echo "  help      - Mostrar esta ayuda"
    echo
    echo -e "${YELLOW}Ejemplos:${NC}"
    echo "  $0 full"
    echo "  $0 area"
    echo "  $0 stop"
}

# Función para detener grabación
stop_recording() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p $pid > /dev/null; then
            kill -TERM $pid
            echo -e "${GREEN}✅ Grabación detenida${NC}"
            rm -f "$PID_FILE"
            
            # Notificación
            notify-send "🎥 Grabación" "Grabación detenida y guardada" -t 3000
        else
            echo -e "${RED}❌ No se encontró proceso de grabación activo${NC}"
            rm -f "$PID_FILE"
        fi
    else
        echo -e "${RED}❌ No hay grabación activa${NC}"
    fi
}

# Función para verificar estado
check_status() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p $pid > /dev/null; then
            echo -e "${GREEN}🔴 Grabación en progreso (PID: $pid)${NC}"
        else
            echo -e "${YELLOW}⚠️  Archivo PID existe pero proceso no encontrado${NC}"
            rm -f "$PID_FILE"
        fi
    else
        echo -e "${BLUE}⚫ No hay grabación activa${NC}"
    fi
}

# Función para grabar pantalla completa
record_full() {
    if [ -f "$PID_FILE" ]; then
        echo -e "${RED}❌ Ya hay una grabación en progreso${NC}"
        return 1
    fi
    
    local filename="screen_$(date +%Y%m%d_%H%M%S).mp4"
    local filepath="$SAVE_DIR/$filename"
    
    echo -e "${GREEN}🎬 Iniciando grabación de pantalla completa...${NC}"
    echo -e "${BLUE}Archivo: $filepath${NC}"
    echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
    
    # Notificación de inicio
    notify-send "🎥 Grabación" "Grabación de pantalla completa iniciada" -t 2000
    
    # Iniciar grabación con wf-recorder
    wf-recorder -f "$filepath" &
    local pid=$!
    echo $pid > "$PID_FILE"
    
    # Esperar a que termine el proceso
    wait $pid
    rm -f "$PID_FILE"
    
    echo -e "${GREEN}✅ Grabación guardada: $filepath${NC}"
    notify-send "🎥 Grabación" "Grabación guardada en $filename" -t 3000
}

# Función para grabar área seleccionada
record_area() {
    if [ -f "$PID_FILE" ]; then
        echo -e "${RED}❌ Ya hay una grabación en progreso${NC}"
        return 1
    fi
    
    echo -e "${GREEN}🎯 Selecciona el área a grabar...${NC}"
    
    # Usar slurp para seleccionar área
    local geometry=$(slurp)
    
    if [ -z "$geometry" ]; then
        echo -e "${RED}❌ Selección cancelada${NC}"
        return 1
    fi
    
    local filename="area_$(date +%Y%m%d_%H%M%S).mp4"
    local filepath="$SAVE_DIR/$filename"
    
    echo -e "${GREEN}🎬 Grabando área seleccionada: $geometry${NC}"
    echo -e "${BLUE}Archivo: $filepath${NC}"
    
    # Notificación de inicio
    notify-send "🎥 Grabación" "Grabación de área iniciada" -t 2000
    
    # Iniciar grabación del área seleccionada
    wf-recorder -g "$geometry" -f "$filepath" &
    local pid=$!
    echo $pid > "$PID_FILE"
    
    # Esperar a que termine el proceso
    wait $pid
    rm -f "$PID_FILE"
    
    echo -e "${GREEN}✅ Grabación guardada: $filepath${NC}"
    notify-send "🎥 Grabación" "Grabación guardada en $filename" -t 3000
}

# Función para grabar ventana específica
record_window() {
    if [ -f "$PID_FILE" ]; then
        echo -e "${RED}❌ Ya hay una grabación en progreso${NC}"
        return 1
    fi
    
    echo -e "${GREEN}🪟 Selecciona la ventana a grabar...${NC}"
    
    # Obtener información de la ventana con hyprctl
    local window_info=$(hyprctl clients -j | jq -r '.[] | select(.focusHistoryID == 0) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    
    if [ -z "$window_info" ]; then
        echo -e "${RED}❌ No se pudo obtener información de la ventana${NC}"
        return 1
    fi
    
    local filename="window_$(date +%Y%m%d_%H%M%S).mp4"
    local filepath="$SAVE_DIR/$filename"
    
    echo -e "${GREEN}🎬 Grabando ventana activa${NC}"
    echo -e "${BLUE}Archivo: $filepath${NC}"
    
    # Notificación de inicio
    notify-send "🎥 Grabación" "Grabación de ventana iniciada" -t 2000
    
    # Usar slurp para seleccionar ventana
    local geometry=$(slurp)
    
    if [ -z "$geometry" ]; then
        echo -e "${RED}❌ Selección cancelada${NC}"
        return 1
    fi
    
    # Iniciar grabación de la ventana
    wf-recorder -g "$geometry" -f "$filepath" &
    local pid=$!
    echo $pid > "$PID_FILE"
    
    # Esperar a que termine el proceso
    wait $pid
    rm -f "$PID_FILE"
    
    echo -e "${GREEN}✅ Grabación guardada: $filepath${NC}"
    notify-send "🎥 Grabación" "Grabación guardada en $filename" -t 3000
}

# Función principal
main() {
    case "$1" in
        "full")
            record_full
            ;;
        "area")
            record_area
            ;;
        "window")
            record_window
            ;;
        "stop")
            stop_recording
            ;;
        "status")
            check_status
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        "")
            echo -e "${YELLOW}⚠️  No se especificó ninguna opción${NC}"
            show_help
            ;;
        *)
            echo -e "${RED}❌ Opción desconocida: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"
