#!/usr/bin/env bash
set -e

# Looks through all remote branches, and shows you which branches have commits which are not yet on your current branch

if [ "$USER" = joey ]
then
	# My favourite, but the colours might not suit all users
	alias glc='git log --pretty=format:"%C(magenta bold)(%D)%C(reset) %C(black bold)%s %C(reset)%C(cyan)- %an (%ad)%Creset" --date=relative'
else
	# Standard one-liner, with fewer details
	#alias glc='git log --pretty=oneline --decorate --abbrev-commit'
	# More details, using default colours (mostly white)
	alias glc="git log --pretty=format:'%C(auto)(%D) %s - %an (%ad)' --date=relative"
fi
shopt -s expand_aliases

#git branch -r |
# Prefer to sort branches by most-recent-commit
git for-each-ref --sort=committerdate refs/remotes --format="%(refname:short)" |

# Trim some repeats
grep -v ' -> ' |
grep -v '/HEAD$' |

while read -r branch
do
	base_commit="$(git merge-base HEAD "$branch")"
	count="$(git log --oneline "${base_commit}...${branch}" | wc -l)"
	if [ "$count" -gt 0 ]
	then
		branch_name_and_last_commit_info="$(glc -n 1 --color=always "$branch")"
		echo "${count} unmerged commits on ${branch_name_and_last_commit_info}"
	fi
done
