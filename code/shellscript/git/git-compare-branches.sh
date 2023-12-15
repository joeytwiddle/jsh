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
elif [ "$#" = 2 ]
then
	branch1="$1"
	branch2="$2"
else
	echo "You must provide 1 or 2 arguments" >&2
	exit 1
fi

shopt -s expand_aliases
# Very basic
#alias glc='git log --pretty=oneline'
# Standard one-liner, with fewer details
#alias glc='git log --pretty=oneline --decorate --abbrev-commit'
# More details, using default colours (mostly white)
alias glc="git log --pretty=format:'%C(auto)%h%d %s - %an (%ad)' --abbrev-commit --date=relative"
if [ "$USER" = joey ]
then
	# My favourite, but the colours might not suit all users
	unalias glc
	alias glc='git log --pretty=format:"%C(yellow bold)%h%C(magenta bold)%d%C(reset) %C(black bold)%s %C(reset)%C(cyan)- %an (%ad)%Creset" --date=relative'
fi

base_commit="$(git merge-base "$branch1" "$branch2")"

#echo "### Base commit"
#glc -n 1 "$base_commit"

(
	echo "<<< Only on ${branch2}"
	glc --color=always "${base_commit}...${branch2}"
	# On macOS, the previous command was not emitting a trailing newline
	# (Although curiously it works properly with the "Very basic" alias)
	echo
	echo ">>> Only on ${branch1}"
	glc --color=always "${base_commit}...${branch1}"
) |
less -RX
