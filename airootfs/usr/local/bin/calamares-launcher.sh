#!/usr/bin/env bash
# calamares-launcher.sh - Safe launcher for system installer
set -e

# Grant root access to local display
xhost +si:localuser:root >/dev/null 2>&1 || true

if command -v calamares &>/dev/null; then
    exec sudo -E calamares -d "$@"
elif command -v archinstall &>/dev/null; then
    if command -v konsole &>/dev/null; then
        exec konsole --new-tab -e sudo archinstall "$@"
    elif command -v gnome-terminal &>/dev/null; then
        exec gnome-terminal -- sudo archinstall "$@"
    else
        exec sudo archinstall "$@"
    fi
else
    echo "[-] Error: No system installer available."
fi
