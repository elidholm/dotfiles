#!/usr/bin/env bash

alias status="git status"
alias push="git push origin HEAD:refs/for/master"
alias pull="git pull origin master"
alias commit="git commit -m"
alias amend="git commit --amend"
alias add="git add ."
alias ginit="git init"
alias remote="git remote add origin"
alias rebase="git pull --rebase origin HEAD:refs/for/master"
alias glog="git log --graph --pretty='%C(yellow) Hash: %h %C(blue)Date: %ad %C(red) Message: %s ' --date=human"

