# 🖱️ Input Remapper

Input Remapper es una herramienta para remapear dispositivos de entrada como mouse, teclado y gamepad en Linux. Permite corregir problemas de hardware y rempear controles, como scroll invertido en trackballs y personalizar completamente los controles.

## 📦 Instalación

```bash
# Desde AUR (recomendado)
yay -S input-remapper-git

# O desde los repositorios oficiales
sudo pacman -S input-remapper
```

## 📁 Archivos incluidos

- `scroll-fix.json` — Configuración para remapear el scroll horizontal a vertical del Kensington ProFit Ergo Vertical Wireless Trackball, esto para el caso de fallo en el scroll vertical.

## 🚀 Uso automático

La configuración se carga automáticamente al iniciar Hyprland mediante:

```bash
exec-once= input-remapper-control --command start --preset "scroll-fix" --device "Kensington ProFit Ergo Vertical Wireless Trackball"
```

## 🛠️ Comandos útiles

### Control básico
```bash
# Iniciar el servicio
input-remapper-control --command start

# Parar el servicio
input-remapper-control --command stop

# Aplicar configuración específica
input-remapper-control --command start --preset "scroll-fix" --device "Kensington ProFit Ergo Vertical Wireless Trackball"
```

### GUI (opcional)
```bash
# Abrir interfaz gráfica para configurar
input-remapper-gtk
```

## 🔧 Personalización

1. **Abrir input-remapper-gtk**
2. **Seleccionar dispositivo** (ej: trackball)
3. **Mapear botones/movimientos** según necesidades
4. **Guardar preset** con nombre descriptivo
5. **Exportar configuración** en formato JSON

## 📝 Configuración actual

La configuración `scroll-fix.json` invierte los ejes de scroll del trackball Kensington:

- **Scroll horizontal** -> **Scroll horizontal**

## 🔄 Sincronización

Para aplicar esta configuración desde el repositorio de dotfiles:

```bash
cd ~/dotfiles
./sync.sh -s input-remapper
```

## 🐛 Solución de problemas

### El preset no se carga
```bash
# Verificar que el servicio está activo
systemctl status input-remapper

# Reiniciar el servicio
input-remapper-control --command stop
input-remapper-control --command start
```

### Dispositivo no detectado
```bash
# Listar dispositivos disponibles
input-remapper-control --command hello

# Verificar permisos del usuario
sudo usermod -a -G input $USER
# Reiniciar sesión después de este comando
```

### Configuración no aplica
- Verificar que el nombre del dispositivo coincida exactamente
- Revisar los logs: `journalctl -u input-remapper`
- Probar reiniciando el sistema

## 📚 Referencias

- [Input Remapper GitHub](https://github.com/sezanzeb/input-remapper)
- [Documentación oficial](https://github.com/sezanzeb/input-remapper/blob/master/readme.md)
