#!/usr/bin/env bash

alias supdate="sudo aptitude update"
alias supgrade="sudo aptitude upgrade"
alias sinstall="sudo aptitude install"
alias sautoremove="sudo apt autoremove"
alias sautoclean="sudo aptitude autoclean"
alias spurge="sudo aptitude purge"

alias df="df -h"
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'
alias checkcommand="type -t"

alias cat="bat"
alias h="history | grep "
alias f="find . | grep "
alias grep="grep --color=always"

alias reposync="repo sync --force-sync"

alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias psaux='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias neoclear='clear && neofetch'
alias cls='clear'

#poweroff
alias po="sudo shutdown now"
alias rs="sudo reboot"

