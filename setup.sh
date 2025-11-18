#!/bin/bash

set -euo pipefail

if [ ! -f $HOME/.local/bin/chezmoi ]; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
fi

$HOME/.local/bin/chezmoi init --apply https://github.com/damien-vdb/dotfiles.git --branch chezmoi
