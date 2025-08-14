Hyprland es un compositor Wayland dinámico con tiling automático que combina la eficiencia de un gestor de ventanas en mosaico con animaciones fluidas y efectos visuales modernos. Es altamente personalizable y está construido en C++ para un rendimiento óptimo.

# 🏗️ Configuración de Hyprland

Configuración completa para Hyprland con temas, atajos de teclado, efectos y scripts personalizados.

## 📦 Estructura

- `hyprland.conf` — Configuración principal del compositor
- `hyprlock.conf` — Configuración del bloqueo de pantalla
- `hyprlock.png` — Imagen de fondo para el bloqueo
- `scripts/` — Scripts personalizados para funcionalidades extra

## 🚀 Características incluidas

### 🎨 Apariencia
- **Bordes redondeados** con efectos de blur
- **Transparencia** ajustable para ventanas inactivas
- **Animaciones suaves** personalizadas con curvas bezier
- **Gaps** configurables entre ventanas
- **Colores** personalizados para bordes activos/inactivos

### ⌨️ Atajos de teclado
- `Super + Return` → Abrir terminal (Ghostty)
- `Super + Space` → Lanzador de aplicaciones (Rofi)
- `Super + E` → Explorador de archivos
- `Super + Backspace` → Cerrar ventana activa
- `Ctrl + Alt + ←/→` → Cambiar entre espacios de trabajo
- `Ctrl + Alt + Shift + ←/→` → Mover ventana a espacio de trabajo adyacente
- `Super + 1-9` → Ir a espacio de trabajo específico
- `Print` → Captura de pantalla

### 🔧 Scripts incluidos
- `screenshot.sh` — Capturas de pantalla con diferentes modos
- `volume.sh` — Control de volumen con notificaciones
- `workspace-nav.sh` — Navegación avanzada entre espacios
- `songdetail.sh` — Información de la canción actual

## ⚙️ Requisitos

- **Hyprland** (compositor principal)
- **Waybar** (barra de estado)
- **Rofi** (lanzador de aplicaciones)
- **Dunst** (notificaciones)
- **Ghostty** (terminal por defecto)
- **Playerctl** (control multimedia)
- **Grim + Slurp** (capturas de pantalla)

## 🛠️ Comandos útiles

### Reiniciar Hyprland
```bash
# Usar el script incluido
~/.config/hypr/restart_hyprland.sh

# O manualmente
hyprctl reload
```

### Control de configuración
```bash
# Recargar configuración sin reiniciar
hyprctl reload

# Ver información de ventanas
hyprctl clients

# Ver información de espacios de trabajo
hyprctl workspaces

# Ejecutar comando
hyprctl dispatch exec "comando"
```

### Debugging
```bash
# Ver logs de Hyprland
journalctl -f -u hyprland

# Ejecutar en modo debug
Hyprland --debug
```

## 🔄 Configuración de inicio

La configuración incluye autostart para:
- Waybar (barra de estado)
- Variables de entorno necesarias
- Tema de cursor

## 🎛️ Personalización

### Cambiar animaciones
Edita la sección `animations` en `hyprland.conf`:
```ini
animation = windows, 1, 4.79, easeOutQuint
animation = workspaces, 1, 1.94, almostLinear, fade
```

### Modificar atajos
Agrega o modifica binds en la sección `KEYBINDINGS`:
```ini
bind = $mainMod, Q, killactive,
bind = $mainMod SHIFT, R, exec, hyprctl reload
```

### Ajustar apariencia
Modifica la sección `decoration` para cambiar:
- Bordes redondeados (`rounding`)
- Transparencia (`active_opacity`, `inactive_opacity`)
- Efectos de blur (`blur`)
- Sombras (`shadow`)

## 🔒 Hyprlock (Bloqueo de pantalla)

### Características
- Reloj y fecha en tiempo real
- Campo de entrada de contraseña
- Imagen de perfil de usuario
- Información de canción actual
- Fondo personalizable con efectos

### Comandos
```bash
# Bloquear pantalla
hyprlock

# Bloquear con imagen específica
hyprlock --config ~/.config/hypr/hyprlock.conf
```

## 🐛 Solución de problemas

### Hyprland no inicia
```bash
# Verificar dependencias
pacman -Q hyprland waybar rofi

# Revisar logs
journalctl -u hyprland --since today
```

### Problemas con aplicaciones
```bash
# Para aplicaciones que no se ven
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=Hyprland
```

### Performance issues
```bash
# Deshabilitar animaciones temporalmente
hyprctl keyword animations:enabled 0

# Verificar uso de GPU
hyprctl systeminfo
```

## 📝 Notas importantes

- Asegúrate de tener drivers de GPU actualizados
- Algunas aplicaciones X11 pueden necesitar configuración adicional
- Los scripts requieren permisos de ejecución
- Revisa la wiki oficial para configuraciones avanzadas: https://wiki.hypr.land/
