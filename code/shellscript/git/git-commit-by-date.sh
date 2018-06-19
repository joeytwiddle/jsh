#!/bin/sh

fnd () {
  find . -type f "$@" | grep -v '/.git/'
}

fnd | sortfilesbydate | sed 's+^./++' |
while read file
do
    fnd -not -newer "$file" | withalldo git add
    date="$(date -r "$file")"
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m "Add $file"
done
