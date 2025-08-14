#!/bin/bash

# Script para controlar volumen con notificaciones elegantes

case $1 in
    up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac

# Obtener volumen actual
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
volume_percent=$(echo $volume | awk '{print int($2*100)}')
is_muted=$(echo $volume | grep -q "MUTED" && echo true || echo false)

# Determinar icono y mensaje
if [ "$is_muted" = true ]; then
    icon=" "
    message="Muted"
    bar=""
else
    if [ $volume_percent -eq 0 ]; then
        icon=" "
    elif [ $volume_percent -lt 20 ]; then
        icon=" "
    elif [ $volume_percent -lt 60 ]; then
        icon=" " 
    else
        icon=" "
    fi
    
    # Crear barra visual
    bar_length=$((volume_percent / 5))
    bar=$(printf "█%.0s" $(seq 1 $bar_length))
    bar=$(printf "%-20s" "$bar")
    
    message="${volume_percent}%"
fi

# Enviar notificación
notify-send -h string:x-canonical-private-synchronous:volume \
            -h int:value:$volume_percent \
            "$icon Volume"
            # "%message\n%bar"
