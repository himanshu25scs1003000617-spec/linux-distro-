#!/usr/bin/env bash
# profiledef.sh - Distribution Profile Definition for mkarchiso
# shellcheck disable=SC2034

iso_name="aetheros"
iso_label="AETHER_$(date +%Y%m)"
iso_publisher="AetherOS Project <https://github.com/aetheros>"
iso_application="AetherOS Live / Install Media"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
arch="$(uname -m)"
if [ "$arch" = "x86_64" ]; then
    bootmodes=('bios.syslinux' 'uefi.systemd-boot')
    pacman_conf="pacman.conf"
    airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
else
    bootmodes=('uefi.systemd-boot')
    pacman_conf="pacman.aarch64.conf"
    airootfs_image_tool_options=('-comp' 'xz' '-b' '1M' '-Xdict-size' '1M')
fi
airootfs_image_type="squashfs"
file_permissions=(
  ["/etc/sudoers.d/00-liveuser"]="0:0:440"
  ["/usr/local/bin/live-setup.sh"]="0:0:755"
  ["/usr/local/bin/calamares-launcher.sh"]="0:0:755"
  ["/usr/local/bin/aether-firstrun.sh"]="0:0:755"
  ["/usr/local/bin/aether-autoresize"]="0:0:755"
  ["/usr/local/bin/aether-post-install-reboot"]="0:0:755"
  ["/usr/lib/calamares/modules/initcpio/main.py"]="0:0:755"
)
