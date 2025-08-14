#!/bin/bash
# Script para probar notificaciones con Dunst de forma segura

notify-send "Test" "Dunst esta funcionando"
notify-send -u low "Baja prioridad" "Esto es una notificacion de baja prioridad"
notify-send -u normal "Prioridad normal" "Esto es una notificacion normal"
notify-send -u critical "Prioridad critica" "Esto es una notificacion critica"

notify-send -i dialog-information "Info" "Mensaje informativo"
notify-send -i dialog-warning "Warning" "Mensaje de advertencia"
notify-send -i dialog-error "Error" "Mensaje de error"

notify-send -a Discord "Discord" "Mensaje de Discord"
notify-send -a Spotify "Now Playing" "Cancion - Artista"
notify-send "Volume" "50%"

echo "Pruebas de notificaciones enviadas. Verifica que todas se muestren correctamente."
