#!/bin/sh
# exec git checkout --orphan "$@"

# This script offers a simple way to save disk space of a git project which you are not currently working on.

set -e

# Go to the root folder (only really needed for du)
cd "$(git rev-parse --show-toplevel)"

du -sh .

# If there are any uncommitted changes, we had better stash them first
git stash save || true

# If an empty branch already exists, switch to it
if git checkout _empty_ 2>/dev/null
then
	# The branch already exists
	:
else
	# Otherwise, create the empty branch
	git checkout --orphan _empty_
	git reset --hard
	git commit --allow-empty -m "empty"
fi

du -sh .

git gc

du -sh .
