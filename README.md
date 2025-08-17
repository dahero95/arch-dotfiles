# 🏠 Dotfiles — Arch Linux + Hyprland

Configuración personal para un escritorio moderno en Wayland con Hyprland. Incluye sincronización inteligente de dotfiles, componentes modulares y una instalación rápida.

## ✨ Características
- Hyprland + Waybar + Rofi + Dunst + Ghostty + Hyprlock + Hypridle + Hyprcursor + SWWW
- Sincronización selectiva de dotfiles con firmas SHA256 y timestamps
- Estructura modular por componente (cada uno con su propio README)
- Temas GTK, SDDM, cursores y fuentes Nerd
- Gestión automática de wallpapers con Wallhaven API

## ⚙️ Requisitos
- Arch Linux (o derivado)
- Paquetes base recomendados:
   ```bash
   sudo pacman -S --needed base-devel hyprland hyprlock hypridle hyprcursor waybar rofi dunst ghostty thunar playerctl grim slurp curl jq imagemagick noto-fonts-emoji noto-fonts ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-montserrat papirus-icon-theme zsh git curl
   yay -S swww
   ```

## 🚀 Instalación rápida
```bash
# 1) Clonar
git clone https://github.com/dahero95/arch-dotfiles ~/dotfiles
cd ~/dotfiles

# 2) Primera sincronización (recomendado forzar reemplazo completo)
chmod +x sync.sh
./sync.sh -a -r

# 3) (Opcional) Activar Starship en Zsh
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

# 4) Reiniciar sesión o: source ~/.zshrc
```

- Uso diario: `./sync.sh -a` (solo cambios)
- Sincronización por componente: `./sync.sh -s <componente>`
- Documentación completa: ver `SYNC_README.md`

## 📦 Componentes
Cada componente tiene su propio README dentro de su carpeta:
- Hyprland: `config/hypr/`
- Hypridle: `config/hypridle/`
- Hyprcursor: `config/hyprcursor/`
- SWWW: `config/swww/`
- Waybar: `config/waybar/`
- Rofi: `config/rofi/`
- Dunst: `config/dunst/`
- Ghostty: `config/ghostty/`
- SDDM: `config/sddm/`
- Temas (GTK y sddm): `themes/`
- Fuentes: `fonts/`
- Iconos de cursor: `icons/`

## 📁 Estructura
```
dotfiles/
├── config/
│   ├── hypr/
│   ├── hypridle/
│   ├── hyprcursor/
│   ├── swww/
│   ├── waybar/
│   ├── rofi/
│   ├── dunst/
│   ├── ghostty/
│   └── sddm/
├── fonts/
├── themes/
├── icons/
├── sync.sh
├── SYNC_README.md
└── .signatures/        # generado automáticamente
```

## 🧩 Lo que hace `sync.sh`
- Copia configuraciones a `~/.config/`
- Instala fuentes en `~/.local/share/fonts/` y actualiza caché (`fc-cache`)
- Instala iconos de cursor en `~/.local/share/icons/`
- Copia temas GTK a `~/.themes/`
- Copia SDDM: `config/sddm/sddm.conf` a `/etc/sddm.conf` y temas a `/usr/share/sddm/themes/` (requiere sudo)
- Sincroniza `.face.icon` si existe
- Configura directorio de wallpapers en `~/Pictures/Wallpapers/`
- Recarga/reenlaza servicios cuando aplica: Hyprland, Waybar, Dunst, Rofi, SWWW

## 🎨 Personalización rápida
- Rofi: `config/rofi/` (temas en `launchers/` y `powermenu/`)
- Waybar: `config/waybar/config.jsonc` y `config/waybar/style.css`
- Hyprland: `config/hypr/hyprland.conf`
- Wallpapers: `~/.config/swww/scripts/wallpaper_manager.sh new`

## 🆘 Problemas comunes
- Fuentes nuevas no aparecen: ejecutar `fc-cache -rv`
- Cambios en Hyprland no aplican: `hyprctl reload`
- Waybar/Dunst no reflejan cambios: sincroniza y se reiniciarán automáticamente

Para detalles avanzados del sistema de sincronización, ver `SYNC_README.md`.
