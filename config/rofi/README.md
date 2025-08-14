# Rofi Configuración y Temas

Rofi es un lanzador de aplicaciones, menú de energía y switcher de ventanas altamente personalizable para entornos gráficos en Linux. Permite buscar y ejecutar aplicaciones, cambiar entre ventanas, ejecutar comandos, navegar archivos y más, todo con una interfaz rápida y adaptable a cualquier estilo visual.

Temas y scripts tomados de: https://github.com/adi1090x/rofi

## 📦 Estructura

- `config.rasi` — Configuración principal de Rofi
- `launchers/` — Temas y estilos para lanzadores de aplicaciones
- `powermenu/` — Temas y estilos para menús de energía
- `scripts/` — Scripts para lanzar rofi con diferentes estilos y menús

## 🚀 Scripts útiles

Estos scripts siven tanto para probar el tema seleccionado como para configurar el tema en hyprland.conf
Revisa las imagenes preview en ./examples
- `launcher.sh <tipo> <estilo>`
  - Lanza el lanzador de aplicaciones con el tipo y estilo deseado
  - Ejemplo: `./launcher.sh 1 5`
- `powermenu.sh <tipo> <estilo>`
  - Lanza el menú de energía con el tipo y estilo deseado
  - Ejemplo: `./powermenu.sh 1 2`

### 🛡️ Permisos de ejecución

Antes de poder ejecutar los scripts, asegúrate de darles permiso de ejecución:

```bash
chmod +x ~/.config/rofi/scripts/*.sh
```

Esto es necesario para poder lanzarlos desde la terminal o desde atajos de teclado.

## 🎨 Temas

Todos los temas y estilos provienen del repositorio de Aditya Shakya:
https://github.com/adi1090x/rofi

Puedes personalizar los estilos editando los archivos `.rasi` en las carpetas `launchers/type-X/` y `powermenu/type-X/`.

## ⚙️ Requisitos

- **Rofi** (recomendado 1.7+)
- **Tema de iconos**: Papirus (o el que prefieras)
- **Fuentes recomendadas**: Nerd Font, JetBrains Mono, o similar


## 🖌️ Cambiar el tema por defecto

Para cambiar el tema por defecto de Rofi, edita la última línea del archivo `config.rasi`:

```rasi
@theme "~/.config/rofi/launchers/type-3/style-1.rasi"
```

Esto hará que cualquier script que use la configuración global de Rofi tome ese tema por defecto.

Si usas los scripts genéricos (`launcher.sh` y `powermenu.sh`) puedes seguir pasando el tipo y estilo como argumentos para forzar un tema diferente temporalmente.

## ⌨️ Atajos de teclado en Hyprland

Puedes agregar shortcuts en tu archivo `hyprland.conf` para lanzar el launcher o el powermenu con una combinación de teclas. Ejemplo:

```ini
# Lanzador de aplicaciones (Rofi)
bind = SUPER, D, exec, ~/.config/rofi/scripts/launcher.sh 1 5

# Powermenu (Rofi)
bind = SUPER, F12, exec, ~/.config/rofi/scripts/powermenu.sh 1 2
```

Cambia la ruta y los argumentos según el tipo y estilo que prefieras.

## 🔄 Sincronización

Para aplicar esta configuración desde el repositorio de dotfiles:

```bash
cd ~/dotfiles
./sync.sh -s rofi
```

Esto copiará `config/rofi/` a `~/.config/rofi/`.