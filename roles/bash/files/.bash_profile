#!/bin/bash
# shellcheck disable=SC1090,SC1091

export XDG_CONFIG_HOME="$HOME"/.config

export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
  [ "${PATH#*"$PYENV_ROOT"/bin:}" == "$PATH" ] && export PATH="$PYENV_ROOT/bin:$PATH"
fi
eval "$(pyenv init -)"

if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

