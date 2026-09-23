#!/usr/bin/env bash
# calamares-launcher.sh - Safe launcher for system installer
set -e

# Grant root access to local display in X11 / Xwayland
if command -v xhost &>/dev/null; then
    xhost +si:localuser:root >/dev/null 2>&1 || true
fi

# Ensure Qt applications running as root can access display under Wayland/Xwayland
export DISPLAY="${DISPLAY:-:0}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/1000}"
export QT_QPA_PLATFORM="xcb;wayland"

if command -v calamares &>/dev/null && calamares --version &>/dev/null; then
    exec sudo -E \
        PATH="$PATH" \
        DISPLAY="$DISPLAY" \
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
        XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        QT_QPA_PLATFORM="$QT_QPA_PLATFORM" \
        calamares -d "$@"
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
