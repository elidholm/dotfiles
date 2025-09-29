#!/bin/bash
# shellcheck disable=SC1090,SC1091

iatest=${-%%i*}; iatest=$((${#iatest}+1))

if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
fi

# Source global definitions
[ -f /etc/bash.bashrc ] && source /etc/bash.bashrc

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion
fi

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

eval "$(starship init bash)"
eval "$(pyenv virtualenv-init -)"
eval "$(dircolors -b "$HOME/.dircolors")" || eval "$(dircolors -b)"

#Autojump
if [ -f "/usr/share/autojump/autojump.sh" ]; then
	source /usr/share/autojump/autojump.sh
elif [ -f "/usr/share/autojump/autojump.bash" ]; then
	source /usr/share/autojump/autojump.bash
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

if [[ -d "$HOME/.config/bash/work" ]]; then
  if [[ -f "$HOME/.config/bash/work/.work_private" ]]; then
    source "$HOME/.config/bash/work/.work_private"
  fi

  if [[ -f "$HOME/.config/bash/work/.work_public" ]]; then
    source "$HOME/.config/bash/work/.work_public"
  fi

  for file in "$HOME"/.config/bash/work/*.sh; do
    source "$file"
  done
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source  "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
[ -s "$HOME/.bash_completion.d/alacritty" ] && source "$HOME/.bash_completion.d/alacritty"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"

clean_path

export PATH=$PATH:/usr/local/go/bin

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ] && source "$HOME/.sdkman/bin/sdkman-init.sh"



[ -f "/home/elidholm/.ghcup/env" ] && . "/home/elidholm/.ghcup/env" # ghcup-env

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/elidholm/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/elidholm/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<

source '/home/elidholm/.bash_completions/sb.py.sh'
