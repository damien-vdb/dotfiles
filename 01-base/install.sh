#!/bin/bash
set -e

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_MANAGER="${PACKAGE_MANAGER:-apt}"

echo "Installing base packages..."
case "$PACKAGE_MANAGER" in
    apt)
        sudo apt update
        sudo apt install -y curl vim jq yq glances make htop btop gh stow libfuse2t64
        ;;
    dnf)
        sudo dnf install -y curl vim jq yq glances make htop btop gh stow libfuse2t64
        ;;
    pacman)
        sudo pacman -S --noconfirm curl vim jq yq glances make htop btop github-cli stow
        ;;
    *)
        echo "Unsupported package manager: $PACKAGE_MANAGER"
        echo "Please install packages manually"
        exit 1
        ;;
esac

echo "Creating .bashrc.d and .profile.d directories..."
mkdir -p "$HOME/.bashrc.d"
mkdir -p "$HOME/.profile.d"

echo "Install JetBrainsMono font"
wget -P $HOME/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.tar.xz \
  && cd $HOME/.local/share/fonts \
  && tar -xJf JetBrainsMono.tar.xz \
  && rm JetBrainsMono.tar.xz \
  && fc-cache -fv
echo "Fonts refreshed"

echo "Install Rust (Cargo)"
curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path --profile minimal

echo "Configure Flatpak"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Install Flatpaks"
flatpak install flathub org.gnome.SimpleScan
flatpak install flathub com.mattjakeman.ExtensionManager

echo "Install snaps"
snap install onlyoffice-desktopeditors
snap install gimp
snap install vlc
snap install pdfarranger

echo "Stowing base dotfiles..."
cd "$MODULE_DIR"
stow --target="$HOME" --dir=. dotfiles

echo "Base module installed!"
