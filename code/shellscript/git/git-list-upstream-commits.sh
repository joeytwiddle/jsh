#!/usr/bin/env bash
set -e

# Looks through all remote branches, and shows you which branches have commits which are not yet on your current branch

# I like my commits listed with extra details, but the colours might not suit all users
if [ "$USER" = joey ]
then alias glc='git log --pretty=format:"%C(yellow bold)%h%C(magenta bold)%d%C(reset) %C(black bold)%s %C(reset)%C(cyan)- %an (%ad)%Creset" --date=relative'
else alias glc='git log --pretty=oneline --decorate --abbrev-commit'
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
