#!/usr/bin/env bash
# calamares-launcher.sh - Safe launcher for system installer
set -e

# Grant root access to local display if running under X11/Wayland
xhost +si:localuser:root >/dev/null 2>&1 || true

if command -v calamares &>/dev/null; then
    exec sudo -E calamares -d "$@"
elif command -v archinstall &>/dev/null; then
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        if command -v konsole &>/dev/null; then
            exec konsole -e sudo archinstall "$@"
        fi
    fi
    exec sudo archinstall "$@"
else
    echo "[-] Error: No system installer available."
    exit 1
fi
