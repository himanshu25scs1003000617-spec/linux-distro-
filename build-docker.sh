#!/usr/bin/env bash
set -e

# build-docker.sh - Helper script to build the ISO using Docker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="aetheros-builder"

echo "==> Building Docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" -f "${SCRIPT_DIR}/Dockerfile" "${SCRIPT_DIR}"

echo "==> Preparing output directory..."
mkdir -p "${SCRIPT_DIR}/out"

echo "==> Running mkarchiso inside privileged container..."
docker run --rm --privileged \
    -v "${SCRIPT_DIR}:/workspace" \
    "${IMAGE_NAME}"

echo "==> Build complete! Output files in: ${SCRIPT_DIR}/out"
