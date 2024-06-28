#!/usr/bin/env bash

alias supdate="sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y"
alias supgrade="sudo nala upgrade -y"
alias sinstall="sudo nala install"
alias sautoremove="sudo nala autoremove -y"
alias spurge="sudo nala purge"

alias df="df -h"
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias checkcommand="type -t"

alias cat="batcat"
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

