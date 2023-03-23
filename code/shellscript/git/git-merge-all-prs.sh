#!/usr/bin/env bash
set -e

# NOTE: You should run git-fetch-all-prs before running this

# TODO: It doesn't know which PRs have been merged, or closed, I think.  (Merged doesn't matter, closed does.)

base_branch="${BASE_BRANCH:-origin/main}"
target_branch="${TARGET_BRANCH:-auto-merge-all-prs}"

# In case we are already on the target_branch, try to to move off it
git checkout main || git checkout master
current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$current_branch" = "$target_branch" ]
then
	echo "Already on ${target_branch}, so not resetting"
	echo
else
	# Delete the target branch, to start the merges from scratch
	git branch -D "$target_branch" || true
	git checkout -b "$target_branch" "$base_branch"
fi

git branch -r | grep origin/pull | sort -t / -k 3 -n |

while read remote_branch_to_merge
do
	echo
	echo "# Merging ${remote_branch_to_merge}"
	git merge --no-edit --no-ff "$remote_branch_to_merge" 2>&1 || git merge --abort
done
