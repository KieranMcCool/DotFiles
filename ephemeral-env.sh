#!/usr/bin/env bash

set -e

# Usage: ./ephemeral-env.sh [distro]
# Supported distros: ubuntu, fedora, manjaro, alpine
# Default: alpine

DISTRO=${1:-alpine}
DOCKERFILE="Dockerfile.$DISTRO"
TAG="dotfiles-$DISTRO-test"

if [ ! -f "$DOCKERFILE" ]; then
    echo "Dockerfile for $DISTRO not found. Falling back to Dockerfile.alpine."
    DOCKERFILE="Dockerfile.alpine"
    TAG="dotfiles-alpine-test"
fi

echo "Building Docker image using $DOCKERFILE..."
docker build -f "$DOCKERFILE" -t "$TAG" .

echo "Running container. Home directory is /home/testuser."
docker run --rm -it "$TAG"
