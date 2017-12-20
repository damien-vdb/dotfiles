
eval "$(direnv hook zsh)"
eval "$(zoxide init --cmd cd --hook pwd zsh)"
alias grep="rg"
alias cat='bat --paging=never'
alias ls="exa"