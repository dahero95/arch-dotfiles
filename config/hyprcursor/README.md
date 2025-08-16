# Hyprcursor Configuration

Configuración para Hyprcursor, el sistema de cursores nativo de Hyprland.

## ⚙️ Configuración

### Ubicación
- Temas: `~/.local/share/icons/`

### Parámetros principales
- `cursor_theme`: Nombre del tema del cursor
- `cursor_size`: Tamaño del cursor (24 por defecto)
- `hot_reload`: Recarga automática de temas
- `fallback_theme`: Tema de respaldo

## 🎨 Temas recomendados

### Instalar temas populares
```bash
# Rose Pine
yay -S rose-pine-hyprcursor
yay -S rose-pine-cursor  # Versión para XCURSOR

# Bibata cursors
yay -S bibata-cursor-theme

# Capitaine cursors
yay -S capitaine-cursors

# Breeze cursor
sudo pacman -S breeze

# Numix cursor
yay -S numix-cursor-theme
```

### Aplicar tema
1. Instalar el tema en `~/.local/share/icons/` o `/usr/share/icons/`
2. Validar temas instanado:
```bash
ls /usr/share/icons/ | grep -i rose
```
3. Agregar a `hyprland.conf`:
```bash
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,BreezeX-RosePine-Linux
env = HYPRCURSOR_SIZE,24
env = HYPRCURSOR_THEME,rose-pine-hyprcursor
```
4. Reiniciar Hyprland

## 🚀 Uso

**Nota:** Las variables XCURSOR son para compatibilidad con aplicaciones X11/legacy.

### Aplicar cambios
```bash
hyprctl reload

# Si no funciona, reiniciar la sesión de Hyprland:
hyprctl dispatch exit
```

### ⚠️ Troubleshooting
Si el cursor no cambia:
1. **Verificar que el tema existe:**
   ```bash
   ls /usr/share/icons/Bibata-Modern-Classic/
   ```

2. **Probar con Adwaita (tema por defecto):**
   ```bash
   # Cambiar temporalmente en hyprland.conf:
   env = HYPRCURSOR_THEME,Adwaita
   ```

3. **Usar solo XCURSOR (fallback):**
   ```bash
   # Si hyprcursor no funciona, usar solo:
   env = XCURSOR_THEME,Bibata-Modern-Classic
   env = XCURSOR_SIZE,24
   ```

### Verificar funcionamiento
```bash
# Verificar si hyprcursor está corriendo
pgrep hyprcursor

# Ver logs
journalctl --user -f | grep hyprcursor

# Verificar tema activo (si usas variables de entorno)
echo $HYPRCURSOR_THEME
```

## 📝 Notas
- Hyprcursor funciona mejor con temas específicamente compilados para Wayland
- Si un tema no funciona correctamente, usar el fallback_theme

**Aplicaciones con soporte limitado de cursores:**
- VSCode (Microsoft) - Usa cursor por defecto
- Algunas aplicaciones Electron antiguas
- Aplicaciones Java/Swing

**Aplicaciones que funcionan correctamente:**
- Navegadores modernos (Chrome, Firefox)
- Aplicaciones GTK4/Qt6 nativas  
- Terminal (Ghostty, Alacritty, etc.)
- Hyprland y sus componentes