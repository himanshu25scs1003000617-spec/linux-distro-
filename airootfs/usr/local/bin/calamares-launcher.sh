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
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export QT_QPA_PLATFORM="xcb;wayland"

# Ensure /etc/calamares is populated from /etc/calamares-custom
if [ -d /etc/calamares-custom ] && [ ! -f /etc/calamares/settings.conf ]; then
    mkdir -p /etc/calamares
    cp -rf /etc/calamares-custom/* /etc/calamares/
    if [ "$(uname -m)" = "aarch64" ]; then
        sed -i 's|/x86_64/|/aarch64/|g' /etc/calamares/modules/unpackfs.conf 2>/dev/null || true
    fi
fi

# Try launching Calamares GUI installer
if command -v calamares &>/dev/null; then
    echo "[+] Launching Calamares GUI installer..."
    set +e
    sudo -E \
        PATH="$PATH" \
        DISPLAY="$DISPLAY" \
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
        XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        QT_QPA_PLATFORM="$QT_QPA_PLATFORM" \
        calamares -d > /tmp/calamares.log 2>&1
    STATUS=$?
    set -e
    if [ $STATUS -eq 0 ]; then
        exit 0
    fi
    echo "[-] Calamares exited with code $STATUS. See /tmp/calamares.log"
fi

# Fallback to archinstall in Konsole if Calamares is unavailable or encounters error
if command -v archinstall &>/dev/null; then
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        if command -v konsole &>/dev/null; then
            exec konsole -e sudo archinstall "$@"
        fi
    fi
    exec sudo archinstall "$@"
else
    if command -v kdialog &>/dev/null; then
        kdialog --title "AetherOS Installer" --error "The graphical installer encountered an issue (exit code $STATUS).\nDetails logged to /tmp/calamares.log."
    fi
    exit 1
fi
