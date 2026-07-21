#!/usr/bin/env bash

set -e

# Detect distro
get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Ensure a directory exists and is owned by the current user, fixing
# ownership with sudo if it was created by something else (e.g. root).
ensure_owned_dir() {
    local dir="$1"
    mkdir -p "$dir"
    if [ "$(stat -c '%U' "$dir")" != "$(whoami)" ]; then
        echo "Fixing ownership of $dir..."
        sudo chown "$(id -u):$(id -g)" "$dir"
    fi
}

# Symlink function
do_symlinks() {
    echo "Symlinking config files..."
    ln -sf "$PWD/bash/bashrc" "$HOME/.bashrc"
    ln -sf "$PWD/bash/bash_aliases" "$HOME/.bash_aliases"
    ln -sf "$PWD/zsh/zshrc" "$HOME/.zshrc"
    ensure_owned_dir "$HOME/.config"
    ln -sf "$PWD/nvim" "$HOME/.config/nvim"
    ln -sf "$PWD/cron/cronfile" "$HOME/.cronfile"
    crontab "$PWD/cron/cronfile"
    ln -sf "$PWD/tmux/tmux.conf" "$HOME/.tmux.conf"
    ensure_owned_dir "$HOME/.bin"
    for f in "$PWD/bin"/*; do
        ln -sf "$f" "$HOME/.bin/$(basename "$f")"
    done
    ensure_owned_dir "$HOME/.claude"
    ln -sf "$PWD/claude/skills" "$HOME/.claude/skills"
    ln -sf "$PWD/claude/agents" "$HOME/.claude/agents"
}

# Remove symlinks
do_cleanup() {
    echo "Removing symlinks..."
    rm -f "$HOME/.bashrc" "$HOME/.bash_aliases" "$HOME/.zshrc" "$HOME/.cronfile" "$HOME/.tmux.conf"
    rm -rf "$HOME/.config/nvim"
    for f in "$PWD/bin"/*; do
        rm -f "$HOME/.bin/$(basename "$f")"
    done
    rm -rf "$HOME/.claude/skills" "$HOME/.claude/agents"
}

# Per-distro setup
setup_ubuntu() {
    echo "Ubuntu-specific setup..."
}
setup_fedora() {
    echo "Fedora-specific setup..."
}
setup_arch() {
    echo "Arch-specific setup..."
}
setup_manjaro() {
    echo "Manjaro-specific setup..."
}

# Main
case "$1" in
    install)
        do_symlinks
        distro=$(get_distro)
        case "$distro" in
            ubuntu) setup_ubuntu ;;
            fedora) setup_fedora ;;
            arch) setup_arch ;;
            manjaro) setup_manjaro ;;
            *) echo "No specific setup for $distro" ;;
        esac
        ;;
    cleanup)
        do_cleanup
        ;;
    *)
        echo "Usage: $0 {install|cleanup}"
        exit 1
        ;;
esac
