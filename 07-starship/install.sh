
curl -sS https://starship.rs/install.sh | sh


echo "Stowing starship dotfiles..."
cd "$MODULE_DIR"
stow --target="$HOME" --dir=. dotfiles