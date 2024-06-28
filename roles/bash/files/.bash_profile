export XDG_CONFIG_HOME="$HOME"/.config

export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
  [ "${PATH#*"$PYENV_ROOT"/bin:}" == "$PATH" ] && export PATH="$PYENV_ROOT/bin:$PATH"
fi
eval "$(pyenv init -)"

if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

if [ -f "$DOTFILES/scripts/clean-path.py" ]; then
  export "$($DOTFILES/scripts/clean-path.py)" 1> /dev/null
fi

