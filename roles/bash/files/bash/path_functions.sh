#!/usr/bin/env bash

appendToPath() {
  if [ -d "$1" ] && [ "${PATH#*:"$1"}" == "$PATH" ]; then
    export PATH=$PATH:"$1"
  fi
}

prependToPath() {
  if [ -d "$1" ] && [ "${PATH#*"$1":}" == "$PATH" ]; then
    export PATH="$1":$PATH
  fi
}

# Takes the content of the $PATH environment variable and replaces every : with a newline character.
path() {
  echo -e "${PATH//:/\\n}"
}
