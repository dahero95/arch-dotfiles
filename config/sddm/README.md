# SDDM

Configuración y temas para el gestor de sesiones SDDM.

## 📦 Temas incluidos
- **chili**: Tema moderno incluido en este repo, basado en https://github.com/MarianArlt/sddm-chili/tree/master

## 📄 Archivos incluidos
- `sddm.conf`: Configuración principal de SDDM (Wayland, tema, autologin opcional)
- `test_theme.sh`: Script para probar temas de SDDM en modo test
- Carpeta `../../themes/sddm/`: Temas personalizados listos para usar

## 🛠️ Dependencias necesarias
Para que los temas funcionen correctamente, asegúrate de tener instalados:
```bash
sudo pacman -S sddm qt5 qt5-quickcontrols qt5-graphicaleffects
```

## 🚀 Instalación de temas SDDM

1. **Instala SDDM si no lo tienes:**
   ```bash
   sudo pacman -S sddm
   ```

2. **Sincroniza con el script principal:**
   ```bash
   cd ~/dotfiles
   ./sync.sh -s sddm
   ```
   Esto copiará `config/sddm/sddm.conf` a `/etc/sddm.conf` (requiere sudo) y los temas desde `themes/sddm/` a `/usr/share/sddm/themes/`.

   Si prefieres hacerlo manualmente:
   ```bash
   sudo cp ~/dotfiles/config/sddm/sddm.conf /etc/sddm.conf
   sudo mkdir -p /usr/share/sddm/themes
   sudo cp -r ~/dotfiles/themes/sddm/* /usr/share/sddm/themes/
   ```

3. **Configura el tema en `sddm.conf`:**
   Edita la sección `[Theme]` y pon el nombre del tema:
   ```ini
   [Theme]
   Current=chili  # Cambia por el nombre de tu tema
   ThemeDir=/usr/share/sddm/themes
   ```

4. **Reinicia SDDM para aplicar los cambios:**
   ```bash
   sudo systemctl restart sddm
   ```

## 🧪 Probar un tema rápidamente

Puedes usar el script `test_theme.sh` para previsualizar cualquier tema sin reiniciar SDDM:

```bash
cd ~/dotfiles/config/sddm
chmod +x test_theme.sh  # Solo la primera vez
./test_theme.sh <nombre_del_tema>
```
- El tema se abrirá en modo test y se cerrará automáticamente a los 30 segundos.
- Puedes cerrar la ventana antes si lo deseas.

## ℹ️ Notas
- El autologin está desactivado por defecto por seguridad. Si lo necesitas, descomenta y edita la sección `[Autologin]` en `sddm.conf`.
- Si ya tienes un `sddm.conf` en `/etc/`, el script no sobreescribe si no hay cambios; puedes hacer backup manual si lo prefieres.
- Los temas deben estar en `/usr/share/sddm/themes/` para que SDDM los detecte correctamente.

---

¿Dudas? Consulta la documentación oficial: https://wiki.archlinux.org/title/SDDM
