# 🖼️ SWWW - Gestión de Wallpapers con Efectos de Transición

Configuración de SWWW con sistema automático de descarga y rotación de wallpapers desde Wallhaven API con efectos de transición animados.

## 📦 Dependencias
```bash
# SWWW para efectos de transición
yay -S swww

# Dependencias adicionales
sudo pacman -S --needed curl jq imagemagick
```

## ⚙️ Configuración
- **Archivo principal:** `swww.conf`
- **Scripts:** `scripts/wallpaper_manager.sh`
- **Directorio de wallpapers:** `~/Pictures/Wallpapers/`

## ✨ Efectos de Transición

SWWW ofrece varios efectos de transición:
- **grow**: Efecto circular creciente (recomendado)
- **outer**: Círculo que se expande desde los bordes
- **wave**: Efecto ondulado
- **fade**: Desvanecimiento suave
- **wipe**: Barrido direccional (left/right/top/bottom)

## 🚀 Uso del Script

### Comandos Principales
```bash
# Descargar y aplicar nuevo wallpaper con efecto
~/.config/swww/scripts/wallpaper_manager.sh new

# Rotar al siguiente wallpaper
~/.config/swww/scripts/wallpaper_manager.sh next

# Rotar al anterior wallpaper  
~/.config/swww/scripts/wallpaper_manager.sh prev

# Seleccionar wallpaper aleatorio local
~/.config/swww/scripts/wallpaper_manager.sh random

# Ver información del wallpaper actual
~/.config/swww/scripts/wallpaper_manager.sh current

# Solo descargar (sin aplicar)
~/.config/swww/scripts/wallpaper_manager.sh download

# Limpiar wallpapers antiguos
~/.config/swww/scripts/wallpaper_manager.sh clean
```

### Características del Script
- **Fuente:** Wallhaven API con filtros de paisajes naturales
- **Filtros aplicados:**
  - Categoría: General (sin anime/personas)
  - Calidad: Solo contenido apropiado (SFW)
  - Resolución mínima: 1920x1080
  - Términos de búsqueda: landscape, nature, mountains, forest, ocean, sunset, etc.
- **Efectos de transición:**
  - Efecto circular por defecto (grow)
  - Duración: 1.5 segundos
  - FPS: 60 para transiciones suaves
  - Posición central para efecto circular
- **Gestión automática:**
  - Mantiene solo los últimos 20 wallpapers
  - Symlink `current.jpg` apunta al wallpaper activo
  - Notificaciones con dunst (si está disponible)
  - Manejo de errores y logs coloridos

## 🔧 Integración con Hyprland

La configuración se integra automáticamente al agregar en `hyprland.conf`:

```properties
# Autostart swww daemon
exec-once = swww-daemon

# Set initial wallpaper
exec-once = sleep 2 && ~/.config/swww/scripts/wallpaper_manager.sh random
```

## 🎛️ Integración con Waybar

Para integrar con Waybar, añade un módulo personalizado:

```json
"custom/wallpaper": {
    "format": "🖼️",
    "tooltip": true,
    "tooltip-format": "Cambiar wallpaper",
    "on-click": "~/.config/swww/scripts/wallpaper_manager.sh next",
    "on-click-right": "~/.config/swww/scripts/wallpaper_manager.sh new"
}
```

## 📁 Estructura de Archivos
```
config/swww/
├── swww.conf                # Configuración de efectos
├── scripts/
│   └── wallpaper_manager.sh # Script de gestión
└── README.md               # Esta documentación
```

```
~/Pictures/Wallpapers/
├── current.jpg             # Symlink al wallpaper actual
├── 20250817_123456_1234.jpg
├── 20250817_134567_5678.jpg
└── ...                     # Wallpapers descargados
```

## 🛠️ Resolución de Problemas

### SWWW daemon no inicia
```bash
# Verificar e iniciar daemon
swww init

# Verificar estado
pgrep swww-daemon

# Ver logs si hay errores
journalctl --user -f | grep swww
```

### Error de descarga de wallpapers
```bash
# Verificar conectividad
curl -s "https://wallhaven.cc/api/v1/search?categories=100&purity=100" | jq .

# Verificar dependencias
command -v curl jq swww
```

### Wallpaper no cambia
```bash
# Verificar que daemon esté corriendo
pgrep swww-daemon

# Reiniciar daemon
pkill swww-daemon
swww-daemon

# Aplicar wallpaper manualmente
swww img ~/Pictures/Wallpapers/current.jpg
```

## 📋 Comandos Útiles

```bash
# Ver estado actual
~/.config/swww/scripts/wallpaper_manager.sh current

# Crear alias para facilidad
echo 'alias wp="~/.config/swww/scripts/wallpaper_manager.sh"' >> ~/.zshrc
source ~/.zshrc

# Usar alias
wp new      # Descargar y aplicar nuevo
wp next     # Siguiente wallpaper
wp prev     # Anterior wallpaper
wp random   # Aleatorio local
wp current  # Ver actual
wp clean    # Limpiar antiguos
```

## 🎨 Personalización de Efectos

Puedes modificar los efectos de transición editando la función `configure_transition()` en el script:

```bash
# Efecto circular siempre
configure_transition "circle"

# Efecto ondulado
configure_transition "wave"

# Efecto aleatorio (por defecto)
configure_transition "random"
```

## 🔄 Automatización

Para rotación automática, puedes agregar a crontab:

```bash
# Cada 2 horas descargar nuevo wallpaper
0 */2 * * * ~/.config/swww/scripts/wallpaper_manager.sh new

# O rotar cada 30 minutos entre locales
*/30 * * * * ~/.config/swww/scripts/wallpaper_manager.sh next
```
