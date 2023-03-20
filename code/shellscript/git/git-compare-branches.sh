#!/usr/bin/env bash
set -e

# Compares two branches, listing any commits which are on one branch, but not on the other
#
# Example:
#
#     git-compare-branches HEAD productivepriscilla/main

if [ "$#" = 1 ]
then
	branch1="HEAD"
	branch2="$1"
elif [ "$@" = 2 ]
then
	branch1="$1"
	branch2="$2"
else
	echo "You must provide 1 or 2 arguments" >&2
	exit 1
fi

alias glc='git log --pretty=format:"%C(yellow bold)%h%C(magenta bold)%d%C(reset) %C(black bold)%s %C(reset)%C(cyan)- %an (%ad)%Creset" --date=relative'
shopt -s expand_aliases

# I like my commits listed with extra details, but the colours might not suit all users
if [ "$USER" = joey ]
then alias glc='git log --pretty=format:"%C(yellow bold)%h%C(magenta bold)%d%C(reset) %C(black bold)%s %C(reset)%C(cyan)- %an (%ad)%Creset" --date=relative'
else alias glc='git log --pretty=oneline --decorate --abbrev-commit'
fi
shopt -s expand_aliases

base_commit="$(git merge-base "$branch1" "$branch2")"

#echo "### Base commit"
#glc -n 1 "$base_commit"

echo "<<< Only on ${branch2}"
glc "${base_commit}...${branch2}"
echo ">>> Only on ${branch1}"
glc "${base_commit}...${branch1}"
