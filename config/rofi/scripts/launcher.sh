#!/usr/bin/env bash
# Simple Rofi launcher: pass launcher type and style as arguments
# Usage: launcher_simple.sh <type_number> <style_number>
# Example: launcher_simple.sh 1 5

# Defaults
type_num="${1:-1}"
style_num="${2:-1}"

dir="$HOME/.config/rofi/launchers/type-${type_num}"
theme="style-${style_num}"

rofi \
    -show drun \
    -theme "${dir}/${theme}.rasi"
