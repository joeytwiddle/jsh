#!/usr/bin/env bash
set -e

# Compares two branches, listing any commits which are on one branch, but not on the other
#
# Example:
#
#     git-compare-branches HEAD productivepriscilla/main

branch1="$1"
branch2="$2"

alias glc='git log --pretty=format:"%C(yellow bold)%h%C(magenta bold)%d%C(reset) %C(black bold)%s %C(reset)%C(cyan)- %an (%ad)%Creset" --date=relative'
shopt -s expand_aliases

base_commit="$(git merge-base "$branch1" "$branch2")"

#echo "### Base commit"
#glc -n 1 "$base_commit"

echo "<<< Only on ${branch2}"
glc "${base_commit}...${branch2}"
echo ">>> Only on ${branch1}"
glc "${base_commit}...${branch1}"
