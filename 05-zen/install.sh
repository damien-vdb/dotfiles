

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd /tmp
echo "Downloading Zen..."
wget https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz
tar -xJf zen.linux-x86_64.tar.xz
sudo mv zen /opt/.
sudo chmod o+rx /opt/zen
sudo ln -s /opt/zen/zen /usr/local/bin/zen

echo "Stowing systemd configs"
cd "$MODULE_DIR"
sudo stow --target=/ --dir=. dotfiles

echo "Removing xdg-desktop-portal-gnome to fix slow browser startup"
sudo apt remove xdg-desktop-portal-gnome

echo "Zen installed !"
echo "If running with a NVIDIA GPU, look at the VAAPI driver at https://github.com/elFarto/nvidia-vaapi-driver"