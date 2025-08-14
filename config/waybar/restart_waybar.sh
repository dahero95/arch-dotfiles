#!/usr/bin/env bash
# Script para reiniciar Waybar y aplicar la configuración y estilos actuales

# Verificar si estamos en Wayland
if [ -z "$WAYLAND_DISPLAY" ]; then
    echo "❌ Error: Waybar requiere Wayland. Actualmente estás en X11."
    exit 1
fi

# Detener Waybar si está corriendo
pkill waybar
sleep 1

# Verificar que los archivos de configuración existen
if [ ! -f ~/.config/waybar/config.jsonc ] || [ ! -f ~/.config/waybar/style.css ]; then
    echo "❌ Error: No se encuentra config.jsonc o style.css en ~/.config/waybar"
    exit 1
fi

# Lanzar Waybar usando hyprctl si está disponible
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "🎯 Usando hyprctl dispatch para lanzar Waybar..."
    hyprctl dispatch exec "waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css"
    sleep 2
    if pgrep waybar > /dev/null; then
        echo "✅ Waybar iniciado correctamente via hyprctl"
        exit 0
    else
        echo "❌ Error al iniciar Waybar via hyprctl"
    fi
else
    echo "⚠️  No estás en Hyprland, lanzando Waybar directamente..."
    waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &
    sleep 2
    if pgrep waybar > /dev/null; then
        echo "✅ Waybar iniciado correctamente"
        exit 0
    else
        echo "❌ No se pudo iniciar Waybar"
        exit 1
    fi
fi