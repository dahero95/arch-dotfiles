# Cursor Icons Directory

Este directorio contiene temas de cursores para Hyprcursor.

## Instalación
Los temas se sincronizan automáticamente a `~/.local/share/icons/` usando el script `sync.sh`.

## Estructura recomendada
```
icons/
├── Bibata-Modern-Classic/
│   ├── cursors/
│   └── index.theme
├── Bibata-Modern-Ice/
│   ├── cursors/
│   └── index.theme
└── ...
```

## Temas populares para descargar
- Bibata: https://github.com/ful1e5/Bibata_Cursor
- Capitaine: https://github.com/keeferrourke/capitaine-cursors
- Volantes: https://github.com/varlesh/volantes-cursors

## Uso
1. Descargar tema y extraer en este directorio
2. Ejecutar `./sync.sh -s icons` para sincronizar
3. Cambiar `cursor_theme` en `config/hyprcursor/hyprcursor.conf`
