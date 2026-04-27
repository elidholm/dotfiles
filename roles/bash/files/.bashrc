#!/bin/bash
# shellcheck disable=SC1090,SC1091

iatest=${-%%i*}; iatest=$((${#iatest}+1))

if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
fi

# Source global definitions
[[ -f /etc/bash.bashrc ]] && source /etc/bash.bashrc

# Enable bash programmable completion features in interactive shells
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
	source /usr/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
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
if [[ -f /usr/share/autojump/autojump.sh ]]; then
	source /usr/share/autojump/autojump.sh
elif [[ -f /usr/share/autojump/autojump.bash ]]; then
	source /usr/share/autojump/autojump.bash
else
	echo 'Unable to find the autojump script'
fi

export EDITOR=nvim

[[ -f $HOME/.config/bash/.bash_private ]] && source "$HOME/.config/bash/.bash_private"
[[ -f $HOME/.config/bash/.bash_public ]] && source "$HOME/.config/bash/.bash_public"

for file in "$HOME"/.config/bash/*.sh; do
  source "$file"
done

if [[ -d $HOME/.config/bash/work ]]; then
  [[ -f $HOME/.config/bash/work/.work_private ]] && source "$HOME/.config/bash/work/.work_private"
  [[ -f $HOME/.config/bash/work/.work_public ]] && source "$HOME/.config/bash/work/.work_public"

  for file in "$HOME"/.config/bash/work/*.sh; do
    source "$file"
  done
fi

export NVM_DIR=$HOME/.nvm
[[ -s $NVM_DIR/nvm.sh ]] && source "$NVM_DIR/nvm.sh"
[[ -s $NVM_DIR/bash_completion ]] && source "$NVM_DIR/bash_completion"
[[ -f $HOME/.cargo/env ]] && source "$HOME/.cargo/env"
[[ -f $HOME/.ghcup/env ]] && source "$HOME/.ghcup/env"
[[ -f $HOME/.fzf.bash ]] && source "$HOME/.fzf.bash"
[[ -f $HOME/.bash_completions/sb.py.sh ]] && source "$HOME/.bash_completions/sb.py.sh"

clean_path

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/elidholm/.juliaup/bin:*)
        ;;

    *)
        export PATH=$HOME/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR=$HOME/.sdkman
[[ -s $HOME/.sdkman/bin/sdkman-init.sh ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
