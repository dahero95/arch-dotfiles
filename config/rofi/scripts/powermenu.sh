#!/usr/bin/env bash
# Simple Rofi Power Menu: pass type and style as arguments
# Usage: powermenu_simple.sh <type_number> <style_number>
# Example: powermenu_simple.sh 1 2

# Defaults
type_num="${1:-1}"
style_num="${2:-1}"

dir="$HOME/.config/rofi/powermenu/type-${type_num}"
theme="style-${style_num}"

uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

shutdown=' Shutdown'
reboot=' Reboot'
lock=' Lock'
suspend=' Suspend'
logout=' Logout'
yes=' Yes'
no=' No'

rofi_cmd() {
    rofi -dmenu \
        -p "$host" \
        -mesg "Uptime: $uptime" \
        -theme "${dir}/${theme}.rasi"
}

confirm_cmd() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you sure?' \
        -theme "${dir}/${theme}.rasi"
}

confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        case $1 in
            --shutdown) systemctl poweroff ;;
            --reboot) systemctl reboot ;;
            --suspend) mpc -q pause ; amixer set Master mute ; systemctl suspend ;;
            --logout)
                case "$DESKTOP_SESSION" in
                    openbox) openbox --exit ;;
                    bspwm) bspc quit ;;
                    i3) i3-msg exit ;;
                    plasma) qdbus org.kde.ksmserver /KSMServer logout 0 0 0 ;;
                esac
            ;;
        esac
    else
        exit 0
    fi
}

chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
        run_cmd --shutdown
        ;;
    $reboot)
        run_cmd --reboot
        ;;
    $lock)
        if [[ -x '/usr/bin/betterlockscreen' ]]; then
            betterlockscreen -l
        elif [[ -x '/usr/bin/i3lock' ]]; then
            i3lock
        fi
        ;;
    $suspend)
        run_cmd --suspend
        ;;
    $logout)
        run_cmd --logout
        ;;
esac
