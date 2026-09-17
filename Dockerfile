FROM archlinux:latest

# Install archiso and required build tools
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso git bash coreutils util-linux squashfs-tools dosfstools

WORKDIR /workspace

# Default command to build the ISO
CMD ["/bin/bash", "-c", "mkdir -p /workspace/out /workspace/work && mkarchiso -v -w /workspace/work -o /workspace/out /workspace"]
