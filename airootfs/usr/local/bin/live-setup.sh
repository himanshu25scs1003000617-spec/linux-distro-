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

# Ensure Desktop directory and desktop shortcut permissions
mkdir -p /home/liveuser/Desktop
if [ -d /etc/skel/Desktop ]; then
    cp -rf /etc/skel/Desktop/* /home/liveuser/Desktop/
    chmod +x /home/liveuser/Desktop/*.desktop 2>/dev/null || true
fi

# Apply custom Calamares configuration and branding
if [ -d /etc/calamares-custom ]; then
    mkdir -p /etc/calamares
    cp -rf /etc/calamares-custom/* /etc/calamares/
    if [ "$(uname -m)" = "aarch64" ]; then
        sed -i 's|/x86_64/|/aarch64/|g' /etc/calamares/modules/unpackfs.conf 2>/dev/null || true
    fi
fi

# Enable SDDM auto-login strictly for the live session (KDE Plasma 6)
if [ -d /etc/sddm.conf.d-live ]; then
    mkdir -p /etc/sddm.conf.d
    cp -f /etc/sddm.conf.d-live/autologin.conf /etc/sddm.conf.d/autologin.conf
fi

chown -R liveuser:users /home/liveuser

# Generate locales
locale-gen >/dev/null 2>&1 || true

# Initialize pacman keyring in the background
(
    pacman-key --init >/dev/null 2>&1 || true
    if [ "$(uname -m)" = "aarch64" ]; then
        pacman-key --populate archlinuxarm >/dev/null 2>&1 || true
    else
        pacman-key --populate archlinux >/dev/null 2>&1 || true
    fi
) &

exit 0
