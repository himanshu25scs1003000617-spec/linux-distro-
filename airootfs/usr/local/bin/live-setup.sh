#!/usr/bin/env bash
set -e

# live-setup.sh - Runs once during live environment boot

# Create live user if not exists
if ! id "liveuser" &>/dev/null; then
    useradd -m -g users -G wheel,audio,video,optical,storage,input,network,power -s /bin/bash liveuser
    passwd -d liveuser >/dev/null 2>&1
fi

# Populate home directory skeleton
if [ -d /etc/skel ]; then
    cp -rT /etc/skel /home/liveuser
fi

# Ensure Desktop directory and installer shortcut permissions
mkdir -p /home/liveuser/Desktop
if [ -f /etc/skel/Desktop/calamares.desktop ]; then
    cp /etc/skel/Desktop/calamares.desktop /home/liveuser/Desktop/
    chmod +x /home/liveuser/Desktop/calamares.desktop
fi

chown -R liveuser:users /home/liveuser

# Generate locales
locale-gen >/dev/null 2>&1 || true

# Initialize pacman keyring in the background
(
    pacman-key --init >/dev/null 2>&1 || true
    pacman-key --populate archlinux >/dev/null 2>&1 || true
) &

exit 0
