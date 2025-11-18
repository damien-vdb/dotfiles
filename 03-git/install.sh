#!/bin/bash
set -e

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_MANAGER="${PACKAGE_MANAGER:-apt}"

case "$PACKAGE_MANAGER" in
    apt)
        sudo apt update
        sudo apt install git
        ;;
    dnf)
        sudo dnf install git
        ;;
    pacman)
        sudo pacman -S --noconfirm git
        ;;
    *)
        echo "Unsupported package manager: $PACKAGE_MANAGER"
        echo "Please install packages manually: curl vim jq yq glances make htop btop gh stow"
        exit 1
        ;;
esac

git config --global core.autocrlf input

echo "Stowing git dotfiles..."
cd "$MODULE_DIR"
stow --target="$HOME" --dir=. dotfiles

echo "Git module installed!"
echo "Note: Update .gitconfig with your name and email if needed."
