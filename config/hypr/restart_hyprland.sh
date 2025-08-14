#!/usr/bin/env bash
# Script para reiniciar/recargar Hyprland

echo "🔄 Reiniciando Hyprland..."

# Verificar si Hyprland está ejecutándose
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "❌ Error: No estás en una sesión de Hyprland"
    exit 1
fi

# Recargar la configuración de Hyprland
echo "📋 Recargando configuración..."
hyprctl reload

# Verificar si la recarga fue exitosa
if [ $? -eq 0 ]; then
    echo "✅ Configuración de Hyprland recargada correctamente"
    
    # Opcional: Reiniciar Waybar para aplicar cambios de tema
    if pgrep waybar > /dev/null; then
        echo "🔄 Reiniciando Waybar..."
        pkill waybar
        sleep 1
        hyprctl dispatch exec "waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css"
        echo "✅ Waybar reiniciado"
    fi
    
    # Mostrar información del sistema
    echo ""
    echo "📊 Estado actual:"
    echo "   Ventanas abiertas: $(hyprctl clients | grep -c "class:")"
    echo "   Espacios de trabajo: $(hyprctl workspaces | grep -c "workspace ID")"
    
else
    echo "❌ Error al recargar la configuración"
    echo "💡 Revisa la sintaxis en hyprland.conf"
    exit 1
fi
