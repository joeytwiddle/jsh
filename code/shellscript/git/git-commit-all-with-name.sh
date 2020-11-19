#!/bin/sh

# Find all files with the given prefix, and commits each one by date, renaming it to the prefix before committing.
#
# For example: git-commit-all-with-name foo.c
# will commit foo.c.1 foo.c.2 and foo.c.3 all as foo.c

# See also: git-commit-by-date (which commits all the files it can find, without renaming them)

set -e

name="$1"
shift

if [ -e "$name" ]
then
  echo "The base file ${name} already exists.  Please remove it or rename it."
  exit 1
fi

fnd () {
  # Note that with find, * matches multiple chars but never 0 chars
  find . -type f -name "${name}*" | grep -v -F '/.git/'
}

fnd | sortfilesbydate | sed 's+^./++' |
while read file
do
  cp -f "$file" "$name"
  git add "$name"
  date="$(LC_TIME=C date -r "$file")"
  nicedate="$(date +"%Y/%m/%d %H:%M" -r "$file")"
  GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m "Add ${file} from ${nicedate}"
done
