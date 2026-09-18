#!/usr/bin/env bash
set -e

# build-docker.sh - Build the AetherOS Live ISO locally using Docker Desktop on macOS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Checking Docker daemon status..."
if ! docker info >/dev/null 2>&1; then
    echo "[-] Error: Docker is not running."
    echo "    Please open 'Docker Desktop' from your Applications folder and wait for it to start, then re-run this script."
    exit 1
fi

echo "==> Preparing output directory..."
mkdir -p "${SCRIPT_DIR}/out"

echo "==> Running mkarchiso inside privileged Arch Linux container..."
docker run --rm --privileged --security-opt seccomp=unconfined \
    --platform linux/amd64 \
    -v "${SCRIPT_DIR}:/workspace" \
    archlinux:latest \
    /bin/bash -c "
      set -e
      echo '==> Updating keyrings and installing archiso...'
      pacman -Sy --noconfirm archlinux-keyring
      pacman -Syu --noconfirm git archiso
      
      echo '==> Building AetherOS ISO...'
      mkdir -p /build-work
      mkarchiso -v -w /build-work -o /workspace/out /workspace
      
      echo '==> Generating SHA256 checksum...'
      cd /workspace/out
      sha256sum *.iso > sha256sum.txt
      cat sha256sum.txt
    "

echo "==> Local build complete! Your ISO is in: ${SCRIPT_DIR}/out"
ls -lh "${SCRIPT_DIR}/out"
