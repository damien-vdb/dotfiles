# Base configuration
# This file is sourced by .bashrc

# Set default editor
export EDITOR=vim
export VISUAL=vim

if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --exclude .git'
fi

if command -v mise &> /dev/null; then
  eval "$(mise activate bash --shims)"
fi

if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

if [ -d "$HOME/.cargo" ]; then
  . "$HOME/.cargo/env"
fi