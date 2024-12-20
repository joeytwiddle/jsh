#!/usr/bin/env bash
set -e

# Tries to find a commit in this branch which matches a commit in the target branch. Not the same commit, but the same set of files.
#
# This may be useful when you have a bunch of commits, but some of them have been merged into trunk, but with a squash merge. In this situation, git will not recognise the similarity, so it will try to merge or rebase your commits again, resulting in merge or rebase conflicts.
#
# Once you have found the matching commit, you can reset to the commit in trunk instead, and replay (cherry-pick) any commits in this branch which came after the matching commit.

# Check if the required branches are provided
if [ "$#" = 1 ]
then
	current_branch=HEAD
	other_branch="$1"
	shift
elif [ "$#" = 2 ]
then
	current_branch="$1"
	other_branch="$2"
	shift
	shift
else
	echo "Usage: $0 [<current-branch>] <other-branch>"
	exit 1
fi

# Get the tree hashes for the 'other' branch
# I think --no-walk will not look inside the merges of the other branch, but that's something we probably need to do
# We could perhaps use -all instead of -n 500
other_tree_hashes="$(git rev-list -n 500 --objects $(git rev-parse "$other_branch") | awk '{print $1}')"

# Iterate through the commits in the 'current' branch
git rev-list -n 500 "$current_branch" |
while read commit
do
	# Get the tree hash for the current commit
	current_tree_hash="$(git rev-parse "$commit^{tree}")"

	# Check if the current tree hash is in the other branch's tree hashes
	if printf "%s\n" "$other_tree_hashes" | grep -q "$current_tree_hash"
	then
		echo "First matching commit in '$current_branch': $commit"
		exit 0
	fi
done

echo "No matching tree hash found in '$current_branch'."
