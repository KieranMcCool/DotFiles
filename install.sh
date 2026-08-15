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

    if [ ! -f "$PWD/bash/.bashrc_private" ]; then
        echo "Creating private config files..."
        touch "$PWD/bash/.bashrc_private"
        ln -sf "$PWD/bash/.bashrc_private" "$HOME/.bashrc_private"
    fi
    if [ ! -f "$PWD/bash/.bash_aliases_private" ]; then
        touch "$PWD/bash/.bash_aliases_private"
        ln -sf "$PWD/bash/.bash_aliases_private" "$HOME/.bash_aliases_private"
    fi
    if [ ! -f "$PWD/zsh/.zshrc_private" ]; then
        touch "$PWD/zsh/.zshrc_private"
        ln -sf "$PWD/zsh/.zshrc_private" "$HOME/.zshrc_private"
    fi
    for f in "$PWD/bin"/*; do
        ln -sf "$f" "$HOME/.bin/$(basename "$f")"
    done
    ensure_owned_dir "$HOME/.claude"
    ensure_owned_dir "$HOME/.claude/skills"
    ensure_owned_dir "$HOME/.claude/agents"
    for f in "$HOME/.claude/skills"/*; do
        [ -L "$f" ] || continue
        [[ "$(readlink "$f")" == "$PWD/claude/skills/"* ]] && [ ! -e "$f" ] && rm "$f"
    done
    for f in "$HOME/.claude/agents"/*; do
        [ -L "$f" ] || continue
        [[ "$(readlink "$f")" == "$PWD/claude/agents/"* ]] && [ ! -e "$f" ] && rm "$f"
    done
    for f in "$PWD/claude/skills"/*; do
        [ -e "$f" ] || continue
        [ "$(basename "$f")" = ".gitkeep" ] && continue
        ln -sf "$f" "$HOME/.claude/skills/$(basename "$f")"
    done
    for f in "$PWD/claude/agents"/*; do
        [ -e "$f" ] || continue
        [ "$(basename "$f")" = ".gitkeep" ] && continue
        ln -sf "$f" "$HOME/.claude/agents/$(basename "$f")"
    done
}

# Remove symlinks
do_cleanup() {
    echo "Removing symlinks..."
    rm -f "$HOME/.bashrc" "$HOME/.bash_aliases" "$HOME/.zshrc" "$HOME/.cronfile" "$HOME/.tmux.conf"
    rm -rf "$HOME/.config/nvim"
    rm -f "$HOME/.bashrc_private" "$HOME/.bash_aliases_private" "$HOME/.zshrc_private"
    
    for f in "$PWD/bin"/*; do
        rm -f "$HOME/.bin/$(basename "$f")"
    done
    for f in "$HOME/.claude/skills"/*; do
        [ -L "$f" ] || continue
        [[ "$(readlink "$f")" == "$PWD/claude/skills/"* ]] && rm "$f"
    done
    for f in "$HOME/.claude/agents"/*; do
        [ -L "$f" ] || continue
        [[ "$(readlink "$f")" == "$PWD/claude/agents/"* ]] && rm "$f"
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
