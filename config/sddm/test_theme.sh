#!/bin/bash
# Script para probar un tema de SDDM en modo test y cerrarlo automáticamente

# Verifica que se pase el nombre del tema
if [ -z "$1" ]; then
    echo "Uso: $0 <nombre_del_tema>"
    exit 1
fi

THEME="$1"

# Ejecuta sddm-greeter en modo test con el tema indicado
echo "Probando tema '$THEME' en modo test... (se cerrará en 30 segundos)"
sddm-greeter --test-mode --theme "/usr/share/sddm/themes/$THEME" &
GREETER_PID=$!

# Espera 30 segundos
timeout=30
while [ $timeout -gt 0 ]; do
    sleep 1
    timeout=$((timeout-1))
    if ! kill -0 $GREETER_PID 2>/dev/null; then
        echo "El greeter se cerró antes de tiempo."
        exit 0
    fi
    if [ $timeout -eq 10 ]; then
        echo "10 segundos restantes..."
    fi
    if [ $timeout -eq 5 ]; then
        echo "5 segundos restantes..."
    fi
    if [ $timeout -eq 1 ]; then
        echo "Cerrando greeter..."
    fi
done

# Mata el proceso del greeter si sigue activo
pkill -f "sddm-greeter --test-mode --theme /usr/share/sddm/themes/$THEME"
echo "Greeter cerrado."
