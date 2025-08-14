Waybar es una barra de estado altamente configurable para entornos Wayland, especialmente popular en Hyprland y Sway. Permite mostrar información del sistema, notificaciones, controles multimedia, módulos personalizados y más, todo con soporte para temas y scripts.

## 📦 Estructura

- `config.jsonc` — Configuración principal de módulos y comportamiento
- `style.css` — Estilos visuales (colores, fuentes, espaciado, etc.)

## 🚀 Características principales

- Módulos para workspaces, ventana activa, red, volumen, CPU, RAM, reloj, bandeja del sistema, etc.
- Soporte para módulos personalizados (por ejemplo, botón de apagado con Rofi)
- Tematización completa vía CSS
- Integración con Hyprland y otros compositores Wayland

## ⚙️ Requisitos

- **Waybar** (recomendado última versión)
- **Hyprland** o compositor compatible
- **Rofi** (para el powermenu integrado)
- **Fuentes e iconos**: Nerd Font, Papirus, etc.

## 🛠️ Comandos útiles

### Reiniciar Waybar y aplicar cambios

Puedes usar el siguiente script para reiniciar Waybar y asegurarte de que tome la configuración y estilos actualizados:

```bash
#!/usr/bin/env bash
# Script: restart_waybar.sh
# Uso: ./restart_waybar.sh

# Matar instancias existentes
pkill waybar
sleep 1

# Lanzar waybar con config y estilos personalizados
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &
```

Hazlo ejecutable:
```bash
chmod +x ~/.config/waybar/restart_waybar.sh
```

Y ejecútalo cada vez que cambies la configuración o el CSS.

## 📝 Notas

- Puedes personalizar los módulos y su orden editando `config.jsonc`.
- El estilo visual se controla completamente desde `style.css`.
- El módulo `custom/power` está configurado para lanzar el powermenu de Rofi.
- Si tienes problemas con iconos, asegúrate de tener las fuentes e iconos necesarios instalados.
