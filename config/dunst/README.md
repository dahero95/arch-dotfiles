# 🔔 Configuración de Dunst

Configuración moderna para el demonio de notificaciones, pensada para una experiencia de escritorio limpia y coherente.

## 📋 Características

- **Diseño moderno**: Bordes redondeados, transparencia sutil y tipografía limpia
- **Colores por urgencia**: Diferentes colores para notificaciones bajas, normales y críticas
- **Reglas por aplicación**: Estilos personalizados para Discord, Spotify y notificaciones de volumen
- **Tema Gruvbox**: Consistente con el resto del escritorio
- **Posicionamiento inteligente**: Arriba y centrado, con buen espaciado

## 🎨 Colores del tema

- **Baja prioridad**: Azul (`#458588`)
- **Normal**: Verde (`#689d6a`)
- **Crítica**: Amarillo (`#d79921`)
- **Discord**: Púrpura (`#b16286`)
- **Spotify**: Lima (`#98971a`)

## 📦 Dependencias

### Fuente requerida
```bash
# JetBrainsMono Nerd Font
# Ya incluida en la carpeta fonts/ de este repositorio
```

### Tema de iconos requerido
```bash
# Instalar Papirus icon theme
sudo pacman -S papirus-icon-theme
```

### Rutas de iconos alternativas
La configuración usa estas rutas en orden:
- `/usr/share/icons/Papirus/` (principal)
- `/usr/share/icons/Adwaita/` (alternativa)
- `/usr/share/icons/hicolor/` (alternativa del sistema)
- `/usr/share/pixmaps/` (heredada)

## 🔧 Comandos útiles

### Administración del servicio
```bash
# Reiniciar el servicio de dunst
pkill dunst && dunst &

# Verificar si dunst está corriendo
pgrep -fl dunst
```

### Probar notificaciones
> ⚠️ **Nota:** El signo de exclamación (`!`) puede causar errores o que la notificación no se muestre correctamente en algunos entornos. Usa textos sin `!` para pruebas.

```bash
# Notificación de prueba
notify-send "Test" "Dunst esta funcionando"

# Probar diferentes niveles de urgencia
notify-send -u low "Baja prioridad" "Esto es una notificación de baja prioridad"
notify-send -u normal "Prioridad normal" "Esto es una notificación normal"
notify-send -u critical "Prioridad crítica" "Esto es una notificación crítica"

# Probar con iconos
notify-send -i dialog-information "Info" "Mensaje informativo"
notify-send -i dialog-warning "Warning" "Mensaje de advertencia"
notify-send -i dialog-error "Error" "Mensaje de error"

# Probar reglas por aplicación
notify-send -a Discord "Discord" "Mensaje de Discord"
notify-send -a Spotify "Now Playing" "Cancion - Artista"
```

### Script de prueba
Puedes usar el script `test_notify.sh` incluido en esta carpeta para probar todas las variantes de notificaciones de forma segura y sin errores de caracteres especiales:

```bash
chmod +x ./config/dunst/test_notify.sh && ./config/dunst/test_notify.sh
```

### Notificaciones de volumen
Hay un script en ./config/hypr/scripts/volume que gestiona el envio de notificaciones por medio de shortcut del teclado declarados en hyprland.conf
```bash
# Probar notificación de volumen (coincide con la regla de volumen)
notify-send -h string:x-canonical-private-synchronous:volume \
            -h int:value:50 \
            "  Volume"
```

## 🎛️ Explicación de opciones clave

### Apariencia de la ventana
- **Tamaño**: 350px de ancho, hasta 250px de alto
- **Posición**: Arriba y centrado, con 15px de margen
- **Transparencia**: 5% para un efecto sutil
- **Bordes**: 12px de radio para look moderno
- **Padding**: 16px vertical, 20px horizontal

### Comportamiento
- **Tiempos**: 6s (baja), 8s (normal), 16s (crítica)
- **Historial**: Guarda las últimas 50 notificaciones
- **Stacking**: Agrupa duplicados
- **Iconos**: Tamaño entre 32 y 48px

### Controles de ratón
- **Clic izquierdo**: Cierra la notificación actual
- **Clic medio**: Ejecuta acción y cierra
- **Clic derecho**: Cierra todas las notificaciones

## 🔄 Aplicar cambios

Después de modificar la configuración:

1. **Recarga dunst**:
   ```bash
   pkill dunst && dunst &
   ```

2. **Prueba los cambios**:
   ```bash
   notify-send "Test" "¡Configuración actualizada!"
   ```

## 🎨 Consejos de personalización

### Cambiar colores
Edita las secciones `[urgency_*]` para modificar colores:
- `background`: Fondo principal
- `foreground`: Color del texto
- `frame_color`: Borde
- `highlight`: Color de acento, p. ej: para barras de progreso

### Agregar reglas por aplicación
Crea nuevas secciones para apps específicas:
```toml
[your_app]
    appname = "YourApp"
    background = "#282828"
    foreground = "#ebdbb2"
    frame_color = "#your_color"
    timeout = 8
```

### Personalizar fuente
Modifica la opción `font` en `[global]`:
```toml
font = YourFont Regular 12
```

## 🐛 Solución de problemas

### No aparecen notificaciones
```bash
# Verifica si dunst está corriendo
pgrep dunst

# Busca mensajes de error
dunst -verbosity debug

# Verifica permisos de notificación
notify-send "Test" "Hola"
```

### No se ven los iconos
1. Verifica que Papirus esté instalado
2. Revisa las rutas de iconos en la config
3. Prueba con otro tema de iconos

## 🔄 Sincronización

Para aplicar esta configuración desde el repositorio de dotfiles:

```bash
cd ~/dotfiles
./sync.sh -s dunst
```

Esto copiará `config/dunst/` a `~/.config/dunst/` y reiniciará Dunst si ya está en ejecución.

### Problemas con la fuente
1. Asegúrate de tener JetBrains Mono Nerd Font instalada
2. Actualiza la caché de fuentes: `fc-cache -fv`
3. Usa una fuente alternativa temporalmente
