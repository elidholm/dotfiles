#!/usr/bin/env bash

git() {
  case "$1" in
  checout | chekout | cehckout | chekcout | chehckout)
    shift
    command git checkout "$@"
    ;;
  comit | commmit)
    shift
    command git commit "$@"
    ;;
  rebsae)
    shift
    command git rebase "$@"
    ;;
  brnach)
    shift
    command git branch "$@"
    ;;
  statsu)
    shift
    command git status "$@"
    ;;
  *) command git "$@" ;;
  esac
}

docker() {
  case "$1" in
  imagse)
    shift
    command docker images "$@"
    ;;
  componse)
    shift
    command docker compose "$@"
    ;;
  exex)
    shift
    command docker exec "$@"
    ;;
  buidl)
    shift
    command docker build "$@"
    ;;
  inspec)
    shift
    command docker inspect "$@"
    ;;
  *) command docker "$@" ;;
  esac
}
