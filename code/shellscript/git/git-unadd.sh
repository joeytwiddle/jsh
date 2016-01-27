#!/bin/sh

# If you have added a file to the stage accidentally, there are two ways to
# undo it, depending whether it is a new or modified file.
#
# Both of these methods leave the current file on disk unchanged.

for file
do

  # If the file is not currently in the repo, but you have staged it, then git
  # status will report it as "new file".
  #
  # This will return its staged status to "untracked".
  #
  # But be careful: if the file is in the repo, this will stage a "removal"!
  #
  if git status --porcelain "$file" | grep "^A" >/dev/null
  then

    git rm --cached "$file"

  fi

  # If the file is already in the repo, but it has been modified on disk and
  # modifications have been staged, then git status will report it was
  # "modified".
  #
  # This will unstage its changes.
  #
  if git status --porcelain "$file" | grep "^M" >/dev/null
  then

    git reset HEAD "$file"

  fi

done
