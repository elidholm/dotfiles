#!/usr/bin/env bash

alias v="fdfind --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim"
alias vi="nvim"
alias vim="nvim"
alias svi="sudo nvim"
alias vis='nvim "+set si"'
alias nvimsetup="cd \$HOME/.config/nvim"

#config
alias bconf="nvim ~/.bashrc"
alias iconf="nvim ~/.inputrc"
alias nconf="nvim ~/.config/nvim"
alias tconf="nvim ~/.tmux.conf"
alias aconf="nvim ~/.config/alacritty/alacritty.toml"
