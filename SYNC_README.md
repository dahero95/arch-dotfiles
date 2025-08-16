# Sync Dotfiles - Sistema de Sincronización Inteligente

Un sistema avanzado de sincronización de dotfiles que detecta cambios usando firmas criptográficas y solo sincroniza lo que ha cambiado.

## ✨ Características

- 🔍 **Detección inteligente de cambios** usando SHA256 para archivos de configuración
- ⚡  **Optimización para performance** usando timestamps para fonts y themes
- 🚀 **Sincronización selectiva** (solo archivos modificados)
- 🔄 **Reinicio automático** de servicios cuando es necesario
- 📁 **Componentes modulares** fáciles de gestionar
- 🎨 **Interfaz colorida** y informativa
- 🛡️ **Robusto** con manejo de errores y verificación de dependencias

## 🚀 Uso

### Sincronización específica
```bash
./sync.sh -s <componente>    # Sincroniza solo lo que cambió
./sync.sh -s <componente> -r # Fuerza reemplazo completo
```

### Sincronización completa
```bash
./sync.sh -a    # Sincroniza todo lo que cambió
./sync.sh -a -r # Reemplaza toda la configuración
```

## 📦 Componentes disponibles

| Componente | Descripción | Método de detección |
|------------|-------------|-------------------|
| **hyprland** | Configuración del compositor Wayland | SHA256 |
| **hypridle** | Daemon de inactividad | SHA256 |
| **hyprcursor** | Configuración de cursor | SHA256 |
| **hyprpaper** | Gestor de wallpapers | SHA256 |
| **waybar** | Barra de estado | SHA256 |
| **rofi** | Lanzador de aplicaciones | SHA256 |
| **dunst** | Sistema de notificaciones | SHA256 |
| **ghostty** | Terminal | SHA256 |
| **themes** | Temas GTK | Timestamp |
| **fonts** | Fuentes del sistema | Timestamp |
| **icons** | Iconos de cursor | Timestamp |
| **sddm** | Display manager | SHA256 |

## 📋 Ejemplos

```bash
# Sincronizar solo Hyprland si hay cambios
./sync.sh -s hyprland

# Sincronizar solo hyprpaper (gestor de wallpapers)
./sync.sh -s hyprpaper

# Forzar reemplazo de todos los temas
./sync.sh -s themes -r

# Sincronizar todo lo que cambió
./sync.sh -a

# Reemplazar toda la configuración
./sync.sh -a -r

# Ver ayuda
./sync.sh -h
```

## ⚙️ Funcionamiento interno

### 🔒 Sistema de firmas híbrido

El script utiliza dos métodos para detectar cambios según el tipo de componente:

#### 1. **Componentes de configuración** (hyprland, hypridle, hyprcursor, hyprpaper, waybar, rofi, dunst, ghostty, sddm)
- ✅ Usa firmas **SHA256** almacenadas en `.signatures/`
- ✅ Detecta archivos nuevos, modificados y eliminados
- ✅ Muestra exactamente qué cambió
- ✅ Precisión máxima

#### 2. **Componentes de recursos** (fonts, themes, icons)
- ✅ Usa **timestamps** de modificación por performance
- ✅ Ideal para directorios con muchos archivos
- ✅ Rápido y eficiente

### 🔄 Acciones automáticas post-sincronización

| Componente | Acción automática |
|------------|------------------|
| **Hyprland** | `hyprctl reload` |
| **Waybar** | Reinicia el proceso |
| **Dunst** | Reinicia y envía notificación de prueba |
| **Fonts** | Actualiza cache con `fc-cache` |
| **Rofi** | Muestra el launcher |
| **Themes** | Instrucciones de aplicación manual |
| **SDDM** | Información sobre reinicio requerido |
| **Ghostty** | Confirmación de actualización |

### 🏗️ Arquitectura modular

```
sync.sh
├── 🐍 sync_helper.py      # Sistema de firmas SHA256
├── 📁 .signatures/        # Almacén de firmas y timestamps
├── ⚙️  check_dependencies() # Verificación automática
├── 🔧 sync_component()    # Función genérica de sincronización
└── 🎯 sync_*()           # Funciones específicas por componente
```

## 📁 Estructura de archivos

```
dotfiles/
├── sync.sh                    # 🚀 Script principal
├── sync_helper.py             # 🐍 Helper Python (auto-generado)
├── SYNC_README.md             # 📖 Esta documentación
├── .signatures/               # 🔐 Firmas y timestamps (auto-generado)
│   ├── hyprland.json         # SHA256 de archivos de Hyprland
│   ├── hypridle.json         # SHA256 de archivos de Hypridle
│   ├── hyprcursor.json       # SHA256 de archivos de Hyprcursor
│   ├── hyprpaper.json        # SHA256 de archivos de Hyprpaper
│   ├── waybar.json           # SHA256 de archivos de Waybar
│   ├── rofi.json             # SHA256 de archivos de Rofi
│   ├── dunst.json            # SHA256 de archivos de Dunst
│   ├── ghostty.json          # SHA256 de archivos de Ghostty
│   ├── sddm.json             # SHA256 de archivos de SDDM
│   ├── fonts.timestamp       # Timestamp de última sync de fonts
│   ├── themes.timestamp      # Timestamp de última sync de themes
│   └── icons.timestamp       # Timestamp de última sync de icons
└── config/                   # 📂 Configuraciones fuente
    ├── hypr/
    ├── hypridle/
    ├── hyprcursor/
    ├── hyprpaper/
    ├── waybar/
    ├── rofi/
    ├── dunst/
    ├── ghostty/
    └── sddm/
```

## 🛠️ Dependencias

- **Python 3**: Para el sistema de firmas criptográficas
- **Herramientas estándar**: `cp`, `mkdir`, `find`, `cmp`, etc.
- **Opcionales**: `hyprctl`, `fc-cache`, `notify-send`, etc.

> 💡 **Nota**: El script verifica automáticamente las dependencias y crea los archivos auxiliares necesarios.

## 🔧 Personalización

Para añadir un nuevo componente:

1. **Crear función de sincronización**:
```bash
sync_mi_componente() {
    sync_component "mi_componente" "$DOTFILES_DIR/config/mi_componente" "$CONFIG_DIR/mi_componente" "Mi Componente"
}
```

2. **Añadir acción post-sync** (opcional):
```bash
case $component in
    mi_componente)
        log "ACTION" "Reiniciando Mi Componente..."
        # comandos específicos
        ;;
esac
```

3. **Actualizar listas**: Añadir a `show_help()` y `sync_all()`

## 🎯 Casos de uso típicos

### 🔄 Desarrollo activo
```bash
# Mientras modificas configuraciones de Hyprland
./sync.sh -s hyprland
```

### 🎨 Cambios de temas
```bash
# Después de actualizar temas
./sync.sh -s themes -r
```

### 🚀 Configuración nueva
```bash
# Primera instalación o cambio mayor
./sync.sh -a -r
```

### ⚡ Sincronización diaria
```bash
# Sincronizar solo cambios
./sync.sh -a
```

---

**🎉 ¡El sistema está listo para usar!** Disfruta de una sincronización inteligente y eficiente de tus dotfiles.
