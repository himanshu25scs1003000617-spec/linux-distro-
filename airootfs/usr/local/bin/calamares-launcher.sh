#!/usr/bin/env bash
# calamares-launcher.sh - Safe launcher for Calamares under KDE Plasma Wayland & X11
set -e

# Grant root access to local display
xhost +si:localuser:root >/dev/null 2>&1 || true

# Execute Calamares with preserved environment
exec sudo -E calamares -d "$@"
