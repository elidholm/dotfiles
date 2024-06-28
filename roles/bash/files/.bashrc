#!/bin/bash
# shellcheck disable=SC1091

iatest=$(expr index "$-" i)

if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
fi

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
	 source /etc/bash.bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion
fi

if [ -f "$HOME/.bash_completion.d/alacritty" ]; then
  source "$HOME/.bash_completion.d/alacritty"
fi

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Disable the bell
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

eval "$(starship init bash)"
eval "$(pyenv virtualenv-init -)"
eval "$(register-python-argcomplete dizzy)"

#Autojump
if [ -f "/usr/share/autojump/autojump.sh" ]; then
	. /usr/share/autojump/autojump.sh
elif [ -f "/usr/share/autojump/autojump.bash" ]; then
	. /usr/share/autojump/autojump.bash
else
	echo "can't found the autojump script"
fi

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

if [[ -f "$HOME/.config/bash/.bash_private" ]]; then
  source "$HOME/.config/bash/.bash_private"
fi

if [[ -f "$HOME/.config/bash/.bash_public" ]]; then
  source "$HOME/.config/bash/.bash_public"
fi

for file in "$HOME"/.config/bash/*.sh; do
  source "$file"
done

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source  "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# if neofetch exists, run it
if [[ -z "$TMUX" ]]; then
  if command -v neofetch &> /dev/null; then neofetch; fi
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ] && source "$HOME/.sdkman/bin/sdkman-init.sh"

