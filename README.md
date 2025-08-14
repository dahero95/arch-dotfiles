# 🏠 Dotfiles
Mi configuración personal para un entorno de escritorio Arch Linux moderno con Hyprland.

## 🚀 Instalación paso a paso

### 1️⃣ Instalar dependencias del sistema
```bash
# Instalar dependencias principales
sudo pacman -S hyprland hyprlock waybar rofi dunst ghostty thunar playerctl grim slurp noto-fonts-emoji noto-fonts ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols papirus-icon-theme

# Instalar shell y herramientas adicionales
sudo pacman -S zsh git curl
```

### 2️⃣ Configurar Zsh y herramientas de terminal
```bash
# Instalar Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Instalar Starship (prompt moderno)
curl -sS https://starship.rs/install.sh | sh

# Cambiar shell por defecto a Zsh
chsh -s $(which zsh)
```

### 3️⃣ Instalar los dotfiles
```bash
# Clonar el repositorio
git clone <tu-repositorio> ~/dotfiles
cd ~/dotfiles

# Ejecutar el script de instalación
chmod +x install.sh
./install.sh
```

### 4️⃣ Configuración final
```bash
# Configurar Starship en Zsh (agregar al final de ~/.zshrc)
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

# Reiniciar la sesión para aplicar todos los cambios
# o ejecutar: source ~/.zshrc
```

## 📦 Componentes incluidos

### 🖥️ Gestor de ventanas y entorno
- **Hyprland** - Compositor Wayland dinámico con tiling
- **Waybar** - Barra de estado moderna y personalizable
- **Hyprlock** - Bloqueo de pantalla para Hyprland

### 🚀 Aplicaciones
- **Rofi** - Lanzador de aplicaciones y menú dinámico
- **Dunst** - Sistema de notificaciones ligero
- **Ghostty** - Terminal moderna y rápida

### 🐚 Shell y herramientas de terminal
- **Zsh** - Shell avanzado con autocompletado y plugins
- **Oh My Zsh** - Framework para gestionar configuración de Zsh
- **Starship** - Prompt cross-shell rápido y personalizable

### 🎨 Temas y apariencia
- **Temas GTK** - Colección de temas Orchis (Light/Dark/Compact)
- **Temas SDDM** - Tema chili incluido para el gestor de sesiones
- **Fuentes** - Fuentes Nerd Font y SF Pro Display

## 📁 Estructura del proyecto

```
dotfiles/
├── config/
│   ├── hypr/           # Configuración de Hyprland
│   │   ├── hyprland.conf
│   │   ├── hyprlock.conf
│   │   └── scripts/    # Scripts personalizados
│   ├── waybar/         # Configuración de la barra de estado
│   ├── rofi/           # Configuración del lanzador
│   ├── dunst/          # Configuración de notificaciones
│   ├── ghostty/        # Configuración del terminal
│   └── sddm/           # Configuración del gestor de sesiones
├── fonts/              # Fuentes personalizadas
├── themes/             # Temas GTK y SDDM
└── install.sh          # Script de instalación
```

## 🚀 Instalación

Sigue la guía paso a paso en la sección "🚀 Instalación paso a paso" arriba.

### Instalación rápida (si ya tienes Zsh configurado)

1. **Clonar el repositorio:**
   ```bash
   git clone <tu-repositorio> ~/dotfiles
   cd ~/dotfiles
   ```

2. **Ejecutar el script de instalación:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Reiniciar la sesión** para aplicar todos los cambios.

## ⚙️ Lo que hace el script de instalación

- ✅ Crea enlaces simbólicos para todas las configuraciones
- ✅ Instala las fuentes en `~/.local/share/fonts/`
- ✅ Configura los temas GTK en `~/.themes/`
- ✅ Instala temas de SDDM en `/usr/share/sddm/themes/`
- ✅ Hace ejecutables todos los scripts necesarios
- ✅ Actualiza el caché de fuentes
- ✅ Copia `.face.icon` al home si no existe

> **Nota**: Para actualizar los temas de SDDM después de modificarlos, vuelve a ejecutar el script de instalación.

## 🔧 Scripts incluidos

### Scripts de Hyprland (`config/hypr/scripts/`)
- `screenshot.sh` - Captura de pantalla
- `songdetail.sh` - Información de la canción actual
- `volume.sh` - Control de volumen
- `workspace-nav.sh` - Navegación entre espacios de trabajo

### Scripts de Rofi (`config/rofi/scripts/`)
- Varios lanzadores y menús de apagado

## 🎨 Personalización

### Cambiar temas de Rofi
Los temas están en `config/rofi/colors/` y `config/rofi/launchers/type-X/`.

### Modificar Waybar
Edita `config/waybar/config.jsonc` para la configuración y `config/waybar/style.css` para los estilos.

### Ajustar Hyprland
La configuración principal está en `config/hypr/hyprland.conf`.

## 📚 Dependencias

### Sistema base
- Hyprland (compositor Wayland)
- Waybar (barra de estado)
- Rofi (lanzador de aplicaciones)
- Dunst (notificaciones)
- Ghostty (terminal)
- Hyprlock (bloqueo de pantalla)
- SDDM (gestor de sesiones)

### Shell y herramientas
- Zsh (shell avanzado)
- Oh My Zsh (framework de Zsh)
- Starship (prompt personalizable)
- Git y curl (para instalación)

### Utilidades del sistema
- Thunar (gestor de archivos)
- Playerctl (control multimedia)
- Grim y Slurp (capturas de pantalla)

### Fuentes e iconos
- Noto Fonts (emojis y Unicode)
- JetBrains Mono Nerd Font
- Nerd Fonts Symbols
- Papirus Icon Theme
