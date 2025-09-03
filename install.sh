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

# Symlink function
do_symlinks() {
    echo "Symlinking config files..."
    ln -sf "$PWD/bash/bashrc" "$HOME/.bashrc"
    ln -sf "$PWD/bash/bash_aliases" "$HOME/.bash_aliases"
    ln -sf "$PWD/zsh/zshrc" "$HOME/.zshrc"
    mkdir -p "$HOME/.config"  # Ensure .config exists
    ln -sf "$PWD/nvim" "$HOME/.config/nvim"
    ln -sf "$PWD/cron/cronfile" "$HOME/.cronfile"
    crontab "$PWD/cron/cronfile"
    ln -sf "$PWD/tmux/tmux.conf" "$HOME/.tmux.conf"
    mkdir -p "$HOME/.bin"
    for f in "$PWD/.bin"/*; do
        ln -sf "$f" "$HOME/.bin/$(basename "$f")"
    done
}

# Remove symlinks
do_cleanup() {
    echo "Removing symlinks..."
    rm -f "$HOME/.bashrc" "$HOME/.bash_aliases" "$HOME/.zshrc" "$HOME/.cronfile" "$HOME/.tmux.conf"
    rm -rf "$HOME/.config/nvim"
    for f in "$PWD/.bin"/*; do
        rm -f "$HOME/.bin/$(basename "$f")"
    done
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
