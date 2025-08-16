# 🖼️ Hyprpaper - Gestión de Wallpapers

Configuración de Hyprpaper con sistema automático de descarga y rotación de wallpapers desde Wallhaven API.

## 📦 Dependencias
```bash
sudo pacman -S --needed hyprpaper curl jq imagemagick
```

## ⚙️ Configuración
- **Archivo principal:** `hyprpaper.conf`
- **Scripts:** `scripts/wallpaper_manager.sh`
- **Directorio de wallpapers:** `~/Pictures/Wallpapers/`

## 🚀 Uso del Script

### Comandos Principales
```bash
# Descargar nuevo wallpaper aleatorio
~/.config/hyprpaper/scripts/wallpaper_manager.sh download

# Rotar entre wallpapers locales
~/.config/hyprpaper/scripts/wallpaper_manager.sh rotate

# Ver información del wallpaper actual
~/.config/hyprpaper/scripts/wallpaper_manager.sh current

# Limpiar wallpapers antiguos
~/.config/hyprpaper/scripts/wallpaper_manager.sh clean
```

### Características del Script
- **Fuente:** Wallhaven API con filtros de paisajes naturales
- **Filtros aplicados:**
  - Categoría: General (sin anime/personas)
  - Calidad: Solo contenido apropiado (SFW)
  - Resolución mínima: 1920x1080
  - Términos de búsqueda: landscape, nature, mountains, forest, ocean, sunset, etc.
- **Gestión automática:**
  - Mantiene solo los últimos 20 wallpapers
  - Symlink `current.jpg` apunta al wallpaper activo
  - Notificaciones con dunst (si está disponible)
  - Manejo de errores y logs coloridos

## 🔧 Integración con Hyprland

La configuración se integra automáticamente al agregar en `hyprland.conf`:

```properties
# Autostart hyprpaper
exec-once = hyprpaper -c ~/.config/hyprpaper/hyprpaper.conf
```

## 🎛️ Integración con Waybar

Para integrar con Waybar, añade un módulo personalizado:

```json
"custom/wallpaper": {
    "format": "🖼️",
    "tooltip": true,
    "tooltip-format": "Cambiar wallpaper",
    "on-click": "~/.config/hyprpaper/scripts/wallpaper_manager.sh next"
}
```

## 📁 Estructura de Archivos
```
config/hyprpaper/
├── hyprpaper.conf           # Configuración principal
├── scripts/
│   └── wallpaper_manager.sh # Script de gestión
└── README.md               # Esta documentación
```

```
~/Pictures/Wallpapers/
├── current.jpg             # Symlink al wallpaper actual
├── 20250816_123456_1234.jpg
├── 20250816_134567_5678.jpg
└── ...                     # Wallpapers descargados
```

## 🛠️ Resolución de Problemas

### Hyprpaper no inicia
```bash
# Verificar configuración
hyprpaper -c ~/.config/hyprpaper/hyprpaper.conf

# Verificar logs
journalctl --user -u hyprpaper -f
```

### Error de descarga de wallpapers
```bash
# Verificar conectividad
curl -s "https://wallhaven.cc/api/v1/search?categories=100&purity=100" | jq .

# Verificar dependencias
command -v curl jq hyprctl
```

### Wallpaper no cambia
```bash
# Verificar que hyprpaper esté corriendo
pgrep hyprpaper

# Reiniciar hyprpaper
pkill hyprpaper
hyprpaper -c ~/.config/hyprpaper/hyprpaper.conf &
```

## 📋 Comandos Útiles

```bash
# Ver estado actual
~/.config/hyprpaper/scripts/wallpaper_manager.sh current

# Forzar descarga de nuevo wallpaper
~/.config/hyprpaper/scripts/wallpaper_manager.sh download

# Crear alias para facilidad
echo 'alias wp="~/.config/hyprpaper/scripts/wallpaper_manager.sh"' >> ~/.zshrc
source ~/.zshrc

# Usar alias
wp download  # Descargar nuevo
wp next    # Rotar local
wp current   # Ver actual
wp clean     # Limpiar antiguos
```

## 🔄 Automatización

Para rotación automática, puedes agregar a crontab:

```bash
# Cada hora descargar nuevo wallpaper
0 * * * * ~/.config/hyprpaper/scripts/wallpaper_manager.sh download

# O rotar cada 30 minutos entre locales
*/30 * * * * ~/.config/hyprpaper/scripts/wallpaper_manager.sh next
```
