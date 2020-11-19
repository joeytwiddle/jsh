#!/bin/sh

# This adds all the files below the current folder to git, but it adds them in separate commits, according to the date of each file.
#
# If you want to add a series of versioned files all under the same base filename, then see: git-commit-all-with-name

set -e

fnd () {
  find . -type f "$@" | grep -v -F '/.git/'
}

fnd | sortfilesbydate | sed 's+^./++' |
while read file
do
  fnd -not -newer "$file" | withalldo git add
  date="$(LC_TIME=C date -r "$file")"
  GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m "Add $file"
done
