#!/usr/bin/env bash
set -ex

echo "==> Host Architecture: $(uname -m)"

echo "==> Initializing Arch Linux ARM pacman keyring..."
pacman-key --init
pacman-key --populate archlinuxarm

echo "==> Configuring Arch Linux ARM mirrors..."
printf 'Server = http://nj.us.mirror.archlinuxarm.org/$arch/$repo\nServer = http://mirror.archlinuxarm.org/$arch/$repo\n' > /etc/pacman.d/mirrorlist

echo "==> Installing build tools and archiso dependencies..."
pacman -Sy --noconfirm archlinuxarm-keyring
pacman -Syu --noconfirm base-devel git arch-install-scripts dosfstools e2fsprogs libisoburn mtools squashfs-tools gawk cmake ninja extra-cmake-modules qt6-tools qt6-translations kcoreaddons kpmcore libpwquality qt6-declarative qt6-svg yaml-cpp

echo "==> Building native Calamares for Arch Linux ARM..."
useradd -m -G wheel builder || true
echo "builder ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder
chmod 0440 /etc/sudoers.d/builder

su - builder << 'BUILDER_SCRIPT'
set -ex
cd /tmp
git clone --depth 1 https://aur.archlinux.org/calamares.git
cd calamares
sed -i "s/'x86_64'/'x86_64' 'aarch64'/" PKGBUILD
makepkg -s --noconfirm --nocheck
BUILDER_SCRIPT

echo "==> Finding and copying built Calamares package as root..."
PKG_FILE=$(find /tmp/calamares /home/builder -name "calamares*.pkg.tar*" 2>/dev/null | head -n 1)
echo "==> Found built package: $PKG_FILE"
mkdir -p /workspace/custom-pkgs/aarch64
rm -f /workspace/custom-pkgs/aarch64/calamares.pkg.tar*
cp -f "$PKG_FILE" /workspace/custom-pkgs/aarch64/calamares.pkg.tar.xz
ls -lh /workspace/custom-pkgs/aarch64/

echo "==> Initializing custom repository for ARM64 Calamares GUI installer..."
rm -f /workspace/custom-pkgs/aarch64/custom.db*
repo-add /workspace/custom-pkgs/aarch64/custom.db.tar.gz /workspace/custom-pkgs/aarch64/*.pkg.tar.*

echo "==> Installing upstream archiso from git..."
git clone --depth 1 https://gitlab.archlinux.org/archlinux/archiso.git /tmp/archiso
make -C /tmp/archiso install-scripts install-profiles

echo "==> Building AetherOS ARM64 ISO with mkarchiso..."
mkdir -p /build-work
mkarchiso -v -w /build-work -o /workspace/out /workspace
