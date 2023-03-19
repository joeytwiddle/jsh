#!/usr/bin/env bash
set -e

# Looks through all remote branches, and shows you which branches have commits which are not yet on your current branch

alias glc='git log --pretty=format:"%C(yellow bold)%h%C(magenta bold)%d%C(reset) %C(black bold)%s %C(reset)%C(cyan)- %an (%ad)%Creset" --date=relative'
shopt -s expand_aliases

# Needed for something below, but not sure what!
set +e
#git branch -r |
git for-each-ref --sort=committerdate refs/remotes --format="%(refname:short)" |
grep -v ' -> ' |
while read -r branch
do
	base_commit="$(git merge-base HEAD "$branch")"
	count="$(glc --color=always "${base_commit}...${branch}" | wc -l)"
	if [ "$count" -gt 0 ]
	then
		branch_name_and_last_commit_info="$(cursemagenta;cursebold)$(glc -n 1 --color=always "$branch" | dropcols 1)"
		echo "${count} unmerged commits on ${branch_name_and_last_commit_info}"
	fi
done
