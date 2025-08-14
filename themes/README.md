# 🎨 Temas (GTK y SDDM)

Instrucciones rápidas para instalar y usar los temas incluidos en este repositorio.

## 📁 Estructura

- `GTK/` — Temas GTK (Orchis y variantes)
- `sddm/` — Temas para el display manager SDDM (ej. chili)

## 🔄 Instalación con sync.sh (recomendada)

```bash
cd ~/dotfiles
# Temas GTK → ~/.themes/
./sync.sh -s themes

# Temas SDDM → /usr/share/sddm/themes/ y /etc/sddm.conf (requiere sudo)
./sync.sh -s sddm
```

## 🖼️ Aplicar tema GTK
- Copiados a `~/.themes/` tras sincronizar.
- Aplica el tema con tu herramienta de apariencia (por ejemplo, `gnome-tweaks`, `lxappearance`, o desde tu entorno).

## 🔐 SDDM
- El tema se copia a `/usr/share/sddm/themes/`.
- Configura el tema en `/etc/sddm.conf` (la sync lo actualiza si cambió).
- Reinicia SDDM para ver el cambio:

```bash
sudo systemctl restart sddm
```

## 🆘 Problemas comunes
- Si un tema GTK no aparece, cierra sesión y vuelve a entrar.
- Si un tema SDDM no carga, revisa que exista en `/usr/share/sddm/themes/<nombre>` y que `Current=<nombre>` esté en `[Theme]` dentro de `/etc/sddm.conf`.
