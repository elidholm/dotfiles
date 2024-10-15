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

# Removes duplicate entries from the $PATH environment variable.
clean_path() {
  OLDPATH="$PATH"
  NEWPATH=""
  colon=""
  while [ "${OLDPATH#*:}" != "$OLDPATH" ]; do
    entry="${OLDPATH%%:*}"
    search=":${OLDPATH#*:}:"
    if [ "${search#*:"$entry":}" == "$search" ]; then
      NEWPATH="$NEWPATH$colon$entry"
      colon=":"
    fi
    OLDPATH="${OLDPATH#*:}"
  done
  NEWPATH="$NEWPATH:$OLDPATH"
  export PATH="${NEWPATH}"
}
