#!/usr/bin/env bash
set -e

# build.sh - Build AetherOS Live ISO on a native Arch Linux machine

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="/tmp/aetheros-work"
OUT_DIR="${SCRIPT_DIR}/out"

if [ "$EUID" -ne 0 ]; then
    echo "[-] Error: mkarchiso requires root privileges. Please run with sudo:"
    echo "    sudo ./build.sh"
    exit 1
fi

if ! command -v mkarchiso &>/dev/null; then
    echo "[-] Error: 'mkarchiso' not found. Install it with: pacman -S archiso"
    exit 1
fi

echo "==> Preparing build environment..."
mkdir -p "${WORK_DIR}" "${OUT_DIR}"

echo "==> Running mkarchiso..."
mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${SCRIPT_DIR}"

echo "==> Generating SHA256 checksums..."
cd "${OUT_DIR}"
sha256sum *.iso > sha256sum.txt

echo "==> Build complete! ISO generated in: ${OUT_DIR}"
ls -lh "${OUT_DIR}"
