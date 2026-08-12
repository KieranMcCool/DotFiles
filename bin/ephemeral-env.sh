#!/usr/bin/env bash

set -e

# Usage: ./ephemeral-env.sh [distro]
# Supported distros: ubuntu, fedora, manjaro, alpine
# Default: alpine

REPO_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
DISTRO=${1:-alpine}
DOCKERFILE="$REPO_ROOT/Dockerfile.$DISTRO"
TAG="dotfiles-$DISTRO-test"

if [ ! -f "$DOCKERFILE" ]; then
    echo "Dockerfile for $DISTRO not found. Falling back to Dockerfile.alpine."
    DOCKERFILE="$REPO_ROOT/Dockerfile.alpine"
    TAG="dotfiles-alpine-test"
fi

INSTANCE_LABEL="$DISTRO-$(date +%Y%m%d-%H%M%S)"
HOST_ENVS_ROOT="$HOME/EphemeralEnvs"
HOST_SHARED_DIR="$HOST_ENVS_ROOT/shared"
HOST_INSTANCE_DIR="$HOST_ENVS_ROOT/$INSTANCE_LABEL"

mkdir -p "$HOST_SHARED_DIR" "$HOST_INSTANCE_DIR"

CONTEXT_HASH=$(find "$REPO_ROOT" -type f ! -path "*/.git/*" | sort | xargs sha256sum 2>/dev/null | sha256sum | awk '{print $1}')
CACHED_HASH=$(docker inspect --format '{{ index .Config.Labels "build-hash" }}' "$TAG" 2>/dev/null || true)

if [ "$CONTEXT_HASH" != "$CACHED_HASH" ]; then
    echo "Building Docker image using $DOCKERFILE..."
    docker build --label "build-hash=$CONTEXT_HASH" -f "$DOCKERFILE" -t "$TAG" "$REPO_ROOT"
else
    echo "Docker image '$TAG' is up to date, skipping build."
fi

echo "Running container '$INSTANCE_LABEL'. Home directory is /home/testuser."
docker run --rm -it \
    --hostname "$INSTANCE_LABEL" \
    --label "ephemeral-env=$INSTANCE_LABEL" \
    --cap-drop=NET_RAW \
    --cap-drop=MKNOD \
    --cap-drop=AUDIT_WRITE \
    -v "$HOST_SHARED_DIR:/home/testuser/shared" \
    -v "$HOST_INSTANCE_DIR:/home/testuser/instance" \
    --workdir /home/testuser/instance \
    "$TAG"

# Clean up instance folder if nothing was written to it
if [ -z "$(ls -A "$HOST_INSTANCE_DIR")" ]; then
    rmdir "$HOST_INSTANCE_DIR"
fi
