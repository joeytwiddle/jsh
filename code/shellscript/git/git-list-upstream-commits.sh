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

# To check remote branches which have not been merged into your current branch
branches_to_check="refs/remotes"
branch_to_compare_against="HEAD"
show_zero_only=.

# To check local branches which have (not) been merged into origin/master
#branches_to_check="refs/heads"
#branch_to_compare_against="origin/master"
#show_zero_only=

#git branch -r |
# Prefer to sort branches by most-recent-commit
git for-each-ref --sort=committerdate "$branches_to_check" --format="%(refname:short)" |

# Trim some repeats
grep -v ' -> ' |
grep -v '/HEAD$' |

while read -r branch
do
	base_commit="$(git merge-base "$branch_to_compare_against" "$branch")"
	count="$(git log --oneline "${base_commit}...${branch}" | wc -l)"
	if [ "$count" -gt 0 ] || [ -z "$show_zero_only" ]
	then
		branch_name_and_last_commit_info="$(glc -n 1 --color=always "$branch")"
		echo "${count} unmerged commits on ${branch_name_and_last_commit_info}"
	fi
done
