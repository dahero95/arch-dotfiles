#!/bin/bash
# ~/.config/hypr/scripts/screenshot.sh

# Create Pictures directory if it doesn't exist
mkdir -p ~/Pictures/Screenshots

# Generate filename with timestamp
FILENAME="screenshot-$(date +%Y%m%d-%H%M%S).png"
FILEPATH="$HOME/Pictures/Screenshots/$FILENAME"

case $1 in
    "full")
        # Full screen screenshot
        grim "$FILEPATH" && \
        wl-copy < "$FILEPATH" && \
        notify-send "Screenshot" "Full screen captured and copied to clipboard\n$FILENAME"
        ;;
    "area")
        # Area selection screenshot
        grim -g "$(slurp)" "$FILEPATH" && \
        wl-copy < "$FILEPATH" && \
        notify-send "Screenshot" "Area captured and copied to clipboard\n$FILENAME"
        ;;
    "clipboard")
        # Only to clipboard, no file
        if [ "$2" = "area" ]; then
            grim -g "$(slurp)" - | wl-copy && \
            notify-send "Screenshot" "Area copied to clipboard"
        else
            grim - | wl-copy && \
            notify-send "Screenshot" "Full screen copied to clipboard"
        fi
        ;;
esac
