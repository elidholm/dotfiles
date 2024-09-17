#!/usr/bin/env bash

set -eo pipefail

print_usage() {
  cat <<EOF

Usage: ${0##*/} [optional arguments]

Optional arguments:
  -y   Auto-approve package upgrades.
  -h   Show this help message and exit.

EOF
}

print_help() {
  echo "This script updates package versions from different package sources."
  print_usage
  exit 0
}

die() {
  echo >&2 "Error: $*"
  print_usage
  exit 1
}

OPTSTRING=":yh"
while getopts $OPTSTRING opt; do
  case $opt in
  y)
    APPROVE=true
    ;;
  h)
    print_help
    ;;
  ?)
    die "Invalid option: -${OPTARG}"
    ;;
  esac
done
shift $((OPTIND - 1))

if [ -n "${CRON}" ]; then
  set +e
  echo  | tee >(cat >&2)
  echo "******* Script ran at $(date) *******" | tee >(cat >&2)
fi


if [ -z "${APPROVE}" ]; then
  FLATPAK_COMMAND="flatpak update"
  APTITUDE_COMMAND="sudo aptitude upgrade"
  APT_COMMAND="sudo apt upgrade"
else
  FLATPAK_COMMAND="flatpak update --assumeyes"
  APTITUDE_COMMAND="sudo aptitude upgrade -y"
  APT_COMMAND="sudo apt upgrade -y"
fi

# Check if snap is installed
if command -v snap &> /dev/null; then
  if [ -z "${CRON}" ]; then
    echo
    echo "**********************************"
    echo "*     Updating snap packages     *"
    echo "**********************************"
    echo
  fi
  sudo snap refresh
fi

# Check if flatpak is installed
if command -v flatpak &> /dev/null; then
  if [ -z "${CRON}" ]; then
    echo
    echo "**********************************"
    echo "*   Updating flatpak packages    *"
    echo "**********************************"
    echo
  fi
  ${FLATPAK_COMMAND}
fi

# Check if aptitude is installed
if command -v aptitude &> /dev/null; then
  if [ -z "${CRON}" ]; then
    echo
    echo "**********************************"
    echo "*    Updating using aptitude     *"
    echo "**********************************"
    echo
    echo "Updating package repository cache..."
    echo
  fi
  sudo aptitude update &> /dev/null
  ${APTITUDE_COMMAND}
else
  if [ -z "$CRON" ]; then
    echo
    echo "**********************************"
    echo "*    Updating using apt          *"
    echo "**********************************"
    echo
    echo "Updating package repository cache..."
    echo
  fi
  sudo apt update &> /dev/null
  ${APT_COMMAND}
fi

