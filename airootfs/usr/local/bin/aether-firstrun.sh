#!/usr/bin/env bash
# aether-firstrun.sh - Applies CachyOS style theme on user login

# Apply BreezeDark colorscheme with Emerald Accent
if command -v plasma-apply-colorscheme &>/dev/null; then
    plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
fi

# Apply Emerald Accent Color (RGB: 0, 216, 180)
if command -v kwriteconfig6 &>/dev/null; then
    kwriteconfig6 --file kdeglobals --group General --key AccentColor "0,216,180"
    kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper false
    kwriteconfig6 --file kdeglobals --group Icons --key Theme "Papirus-Dark"
elif command -v kwriteconfig5 &>/dev/null; then
    kwriteconfig5 --file kdeglobals --group General --key AccentColor "0,216,180"
    kwriteconfig5 --file kdeglobals --group General --key accentColorFromWallpaper false
    kwriteconfig5 --file kdeglobals --group Icons --key Theme "Papirus-Dark"
fi

# Apply AetherOS Wallpaper
WALLPAPER="/usr/share/wallpapers/AetherOS/contents/images/1920x1080.svg"
if [ -f "${WALLPAPER}" ] && command -v plasma-apply-wallpaperimage &>/dev/null; then
    plasma-apply-wallpaperimage "${WALLPAPER}" >/dev/null 2>&1 || true
fi

# Remove installer shortcut from desktop if booted into the installed system
if [ ! -d /run/archiso ]; then
    rm -f "$HOME/Desktop/calamares.desktop"
fi

# Remove autostart entry so it doesn't re-run
rm -f "$HOME/.config/autostart/aether-firstrun.desktop"

exit 0
