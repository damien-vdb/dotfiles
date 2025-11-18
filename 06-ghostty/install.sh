
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd /tmp
echo "Installing Ghostty"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

echo "Stowing Ghostty configs"
cd "$MODULE_DIR"
sudo stow --target="$HOME" --dir=. dotfiles