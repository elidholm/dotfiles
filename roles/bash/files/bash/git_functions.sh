#!/usr/bin/env bash

gcom() {
	git add .
	git commit -m "$1"
}
lazyg() {
	git add .
	git commit -m "$1"
	git push
}
m() {
  git checkout master || git checkout main
  git pull
}

