#!/bin/bash
set -e

# From: https://stackoverflow.com/questions/57374810/how-to-edit-the-last-git-commit-as-a-patch-file

if ! git diff-files --quiet
then
    echo "Your git repository is not clean: you have unstaged changes."
    exit 1
fi

if ! git diff-index --quiet --cached HEAD --
then
    echo "Your git repository is not clean: you have staged changes."
    exit 1
fi

git reset -N HEAD~

git add --edit

# ORIG_HEAD is the pointer to the commit before git reset
git commit --reuse-message=ORIG_HEAD

# Supposing that this edit is really what you wanted, we can throw away leftovers
# If work was lost, in can be recovered using git reflog
#git checkout -- :/
# I disabled that because that's not usually what I want to do.  I would rather throw away any unwanted changes manually.
