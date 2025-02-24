#!/usr/bin/env bash
set -e

# Tries to find a commit in this branch which matches a commit in the target branch. Not the same commit, but the same set of files.
#
# This may be useful when you have a bunch of commits, but some of them have been merged into trunk, but with a squash merge. In this situation, git will not recognise the similarity, so it will try to merge or rebase your commits again, resulting in merge or rebase conflicts.
#
# Once you have found the matching commit, you can reset to the commit in trunk instead, and replay (cherry-pick) any commits in this branch which came after the matching commit.

# Check if the required branches are provided
if [ "$#" = 0 ]
then
	# We will use HEAD, but use the branch name if possible
	current_branch="$(git rev-parse --abbrev-ref HEAD)"
	other_branch="origin/main"
elif [ "$#" = 1 ]
then
	# We will use HEAD, but use the branch name if possible
	current_branch="$(git rev-parse --abbrev-ref HEAD)"
	other_branch="$1"
	shift
elif [ "$#" = 2 ]
then
	current_branch="$1"
	other_branch="$2"
	shift
	shift
else
	echo "Usage: git-find-fork-point [[<current-branch>] <other-branch>]"
	echo
	echo "Will try to find a commit in target-branch which has a tree matching a commit in other-branch"
	exit 1
fi

# Get the tree hashes for the 'other' branch
# This is quite heavy, so we won't look too far back
other_tree_hashes="$(
	git rev-list -n 100 "$other_branch" |
	while read commit
	do printf "%s\n" "$(git rev-parse "${commit}^{tree}") ${commit}"
	done
)"

# Iterate through the commits in the 'current' branch
git rev-list -n 500 "$current_branch" |
while read commit
do
	# Get the tree hash for this commit
	current_tree_hash="$(git rev-parse "$commit^{tree}")"

	# Check if the current tree hash is in the other branch's tree hashes
	if other_commit="$(printf "%s\n" "$other_tree_hashes" | grep -m 1 "^${current_tree_hash} " | cut -d ' ' -f 2 | grep .)"
	then
		if [ "$other_commit" = "$commit" ]
		then
			echo "Branch ${current_branch} and branch ${other_commit} have a common ancestor: ${commit}"
			exit 0
		else
			echo "Commit ${commit} in ${current_branch} has an identical file tree to commit ${other_commit} in ${other_branch}"
			echo
			echo "Therefore commit ${commit} is redundant if you rebase against ${other_branch}"
			echo
			echo "You may now like to:"
			echo "  git rebase -i ${other_branch}"
			echo "and delete all commits up to and including ${commit}"
			exit 0
		fi
	fi
done | grep ^ ||
echo "No matching tree hash found in '$current_branch'."
