#!/usr/bin/env bash

set -e

# Usage: ./ephemeral-env.sh [distro]
# Supported distros: ubuntu, fedora, manjaro
# Default: ubuntu

DISTRO=${1:-ubuntu}
DOCKERFILE="Dockerfile.$DISTRO"
TAG="dotfiles-$DISTRO-test"

if [ ! -f "$DOCKERFILE" ]; then
    echo "Dockerfile for $DISTRO not found. Falling back to Dockerfile.ubuntu."
    DOCKERFILE="Dockerfile.ubuntu"
    TAG="dotfiles-ubuntu-test"
fi

echo "Building Docker image using $DOCKERFILE..."
docker build -f "$DOCKERFILE" -t "$TAG" .

echo "Running container. Home directory is /home/testuser."
docker run --rm -it "$TAG"
