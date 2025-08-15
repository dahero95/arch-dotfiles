# Hypridle Configuration

Gestiona la inactividad del sistema en Hyprland usando `hypridle`.

## Instalación

```bash
sudo pacman -S hypridle
```

## Configuración

- **Timeout 1**: Bloquea la sesión después de 15 minutos
- **Timeout 2**: Apaga la pantalla después de 20 minutos
- **Timeout 3**: Suspende el sistema después de 45 minutos

## Uso

```bash
# Iniciar hypridle (automático con Hyprland)
hypridle

# Ver logs
journalctl --user -f | grep hypridle

# Reiniciar
pkill hypridle && hypridle &
```

## Integración con Hyprland

Agregar a `hyprland.conf`:
```bash
exec-once = hypridle
```

## Integración con Waybar

El módulo `idle_inhibitor` de Waybar puede pausar estos timeouts cuando esté activado.
