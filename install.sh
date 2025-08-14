#!/bin/bash

# Obtener el directorio donde se encuentra este script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define las rutas de destino
CONFIG_DIR="$HOME/.config"
FONTS_DIR="$HOME/.local/share/fonts"
# Crear directorios necesarios si no existen
mkdir -p "$CONFIG_DIR"
mkdir -p "$FONTS_DIR"

echo "🚀 Configurando dotfiles..."
echo "📂 Directorio de dotfiles: $DOTFILES_DIR"


# Función para crear enlaces simbólicos de forma segura
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    # Si existe algo en el destino, crear backup solo si NO es un enlace simbólico
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ ! -L "$target" ]; then
            # Es un archivo/directorio real, crear backup
            local backup_dir="$HOME/.config/dotfiles-backup"
            local timestamp=$(date +"%Y%m%d_%H%M%S")
            local backup_name="$(basename "$target")_$timestamp"
            
            # Crear directorio de backup si no existe
            mkdir -p "$backup_dir"
            
            # Mover el archivo/directorio existente al backup
            mv "$target" "$backup_dir/$backup_name"
            echo "  📦 Backup creado: $backup_dir/$backup_name"l
        else
            # Es un enlace simbólico, solo eliminarlo
            rm "$target"
        fi
    fi
    
    # Crear el enlace simbólico
    ln -sfn "$source" "$target"
    echo "   ✓ $name -> configurado"
}


# -----------------------------------------------------------------------------------------
echo "🔤 Instalando fuentes..."

# Copiar fuentes (no crear enlaces simbólicos para mejor compatibilidad)
cp -r "$DOTFILES_DIR/fonts/"* "$FONTS_DIR/"
echo "   ✓ Fuentes copiadas"

# Actualizar caché de fuentes
fc-cache -fv > /dev/null 2>&1
echo "   ✓ Caché de fuentes actualizado"
# -----------------------------------------------------------------------------------------


# -----------------------------------------------------------------------------------------
echo "📁 Creando enlaces simbólicos para configuraciones..."
create_symlink "$DOTFILES_DIR/config/ghostty" "$CONFIG_DIR/ghostty" "Terminal -> Ghostty"
create_symlink "$DOTFILES_DIR/config/dunst" "$CONFIG_DIR/dunst" "Notificaciones -> Dunst"
create_symlink "$DOTFILES_DIR/config/rofi" "$CONFIG_DIR/rofi" "Lanzador de apps -> Rofi"
create_symlink "$DOTFILES_DIR/config/waybar" "$CONFIG_DIR/waybar" "Barra de tareas -> Waybar"
create_symlink "$DOTFILES_DIR/config/hypr" "$CONFIG_DIR/hypr" "Compositor de ventanas -> Hyprland"
# -----------------------------------------------------------------------------------------


# -----------------------------------------------------------------------------------------
echo "🎨 Configurando temas..."
# Crear enlace para la carpeta de temas GTK
create_symlink "$DOTFILES_DIR/themes/GTK" "$HOME/.themes" "Temas GTK"
# -----------------------------------------------------------------------------------------


# -----------------------------------------------------------------------------------------
echo "🔧 Haciendo scripts ejecutables..."

# Hacer ejecutables los scripts de Hyprland
if [ -d "$DOTFILES_DIR/config/hypr/scripts" ]; then
    find "$DOTFILES_DIR/config/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} \;
    echo "   ✓ Scripts de Hyprland"
fi

# Hacer ejecutables los scripts de Rofi
if [ -d "$DOTFILES_DIR/config/rofi/scripts" ]; then
    find "$DOTFILES_DIR/config/rofi/scripts" -type f -exec chmod +x {} \;
    echo "   ✓ Scripts de Rofi"
fi

# Hacer ejecutable el script de Dunst si existe
if [ -f "$DOTFILES_DIR/config/dunst/test_notify.sh" ]; then
    chmod +x "$DOTFILES_DIR/config/dunst/test_notify.sh"
    echo "   ✓ Script de test de Dunst"
fi


# Hacer ejecutables los scripts de Waybar si existen
if [ -f "$DOTFILES_DIR/config/waybar/restart_waybar.sh" ]; then
    chmod +x "$DOTFILES_DIR/config/waybar/restart_waybar.sh"
    echo "   ✓ Script de Waybar"
fi

# Hacer ejecutable el script de Hyprland principal si existe
if [ -f "$DOTFILES_DIR/config/hypr/restart_hyprland.sh" ]; then
    chmod +x "$DOTFILES_DIR/config/hypr/restart_hyprland.sh"
    echo "   ✓ Script de Hyprland principal"
fi

# Hacer ejecutable el script de test de temas SDDM si existe
if [ -f "$DOTFILES_DIR/config/sddm/test_theme.sh" ]; then
    chmod +x "$DOTFILES_DIR/config/sddm/test_theme.sh"
    echo "   ✓ Script de test de temas SDDM"
fi
# -----------------------------------------------------------------------------------------


# -----------------------------------------------------------------------------------------
# Copiar .face.icon al home si no existe
if [ -f "$DOTFILES_DIR/.face.icon" ] && [ ! -f "$HOME/.face.icon" ]; then
    cp "$DOTFILES_DIR/.face.icon" "$HOME/.face.icon"
    echo "   ✓ .face.icon copiado a ~"
fi
# -----------------------------------------------------------------------------------------


# -----------------------------------------------------------------------------------------
echo "🖥️ Configurando SDDM (requiere permisos de sudo)..."

# Configurar SDDM principal
if [ -f "$DOTFILES_DIR/config/sddm/sddm.conf" ]; then
    echo "   • Configurando archivo principal de SDDM..."
    
    # Verificar si existe archivo en destino y crear backup si no es enlace simbólico
    if [ -e "/etc/sddm.conf" ] || [ -L "/etc/sddm.conf" ]; then
        if [ ! -L "/etc/sddm.conf" ]; then
            # Es un archivo real, crear backup
            local backup_dir="$HOME/.config/dotfiles-backup"
            local timestamp=$(date +"%Y%m%d_%H%M%S")
            local backup_name="sddm.conf_$timestamp"
            
            # Crear directorio de backup si no existe
            mkdir -p "$backup_dir"
            
            # Hacer backup del archivo existente
            sudo cp "/etc/sddm.conf" "$backup_dir/$backup_name"
            echo "  📦 Backup SDDM creado: $backup_dir/$backup_name"
        fi
        # Eliminar el archivo/enlace existente
        sudo rm "/etc/sddm.conf"
    fi
    
    sudo ln -sfn "$DOTFILES_DIR/config/sddm/sddm.conf" "/etc/sddm.conf"
    echo "   ✓ sddm.conf -> configurado"
fi

# Instalar temas de SDDM
if [ -d "$DOTFILES_DIR/themes/sddm" ]; then
    echo "   • Instalando temas de SDDM..."
    # Crear directorio si no existe
    sudo mkdir -p /usr/share/sddm/themes
    
    # Copiar todos los temas (no enlaces simbólicos porque SDDM corre como root)
    for theme_dir in "$DOTFILES_DIR/themes/sddm"/*; do
        if [ -d "$theme_dir" ]; then
            theme_name=$(basename "$theme_dir")
            sudo cp -r "$theme_dir" "/usr/share/sddm/themes/"
            echo "   ✓ Tema $theme_name -> instalado"
        fi
    done
fi
# -----------------------------------------------------------------------------------------


echo ""
echo "✅ ¡Enlaces simbólicos creados exitosamente!"
echo ""
echo "📋 Configuraciones instaladas:"
echo "   • Hyprland (gestor de ventanas)"
echo "   • Waybar (barra de estado)"
echo "   • Rofi (lanzador de aplicaciones)"
echo "   • Dunst (notificaciones)"
echo "   • Ghostty (terminal)"
echo "   • Temas GTK"
echo "   • SDDM (gestor de sesiones)"
echo "   • Fuentes personalizadas"
echo ""
echo "🔄 Es recomendable reiniciar la sesión para aplicar todos los cambios."