#!/usr/bin/env bash
sleep 1
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-hyprland --verbose &
sleep 2
/usr/lib/xdg-desktop-portal &
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
notify-send "Hyprland Desktop Portal" "Hyprland  Desktop Portals Are Ready" -a "Hyprland"
