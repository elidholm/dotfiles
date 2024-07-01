#!/usr/bin/env bash

m() {
  git checkout master || git checkout main
  git pull
}

