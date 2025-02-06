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


# >>> JVM installed by coursier >>>
export JAVA_HOME="/home/elidholm/.cache/coursier/arc/https/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.25%252B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.25_9.tar.gz/jdk-11.0.25+9"
export PATH="$PATH:/home/elidholm/.cache/coursier/arc/https/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.25%252B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.25_9.tar.gz/jdk-11.0.25+9/bin"
# <<< JVM installed by coursier <<<

# >>> coursier install directory >>>
export PATH="$PATH:/home/elidholm/.local/share/coursier/bin"
# <<< coursier install directory <<<

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


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
# shellcheck disable=SC2015
test -r '/home/elidholm/.opam/opam-init/init.sh' && . '/home/elidholm/.opam/opam-init/init.sh' > /dev/null 2> /dev/null || true
# END opam configuration
