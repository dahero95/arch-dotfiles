#!/bin/bash
# ~/.config/hypr/scripts/workspace-nav.sh

# Get current workspace
current=$(hyprctl activeworkspace -j | jq '.id')

case $1 in
    "next")
        next=$((current + 1))
        if [ $next -gt 10 ]; then
            next=1
        fi
        hyprctl dispatch workspace $next
        ;;
    "prev")
        prev=$((current - 1))
        if [ $prev -lt 1 ]; then
            prev=10
        fi
        hyprctl dispatch workspace $prev
        ;;
    "move-next")
        next=$((current + 1))
        if [ $next -gt 10 ]; then
            next=1
        fi
        hyprctl dispatch movetoworkspace $next
        ;;
    "move-prev")
        prev=$((current - 1))
        if [ $prev -lt 1 ]; then
            prev=10
        fi
        hyprctl dispatch movetoworkspace $prev
        ;;
esac
