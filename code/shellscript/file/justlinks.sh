#!/bin/sh
# jsh-depends: absolutepath takecols
# jsh-ext-depends: sed dirname
# jsh-ext-depends-ignore: symlinks
# See also: readlink(1)

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo
  echo "justlinks <symlinks>"
  echo "  or"
  echo "justlinks -absolute <symlink>"
	echo
  exit 1
fi

if [ "$1" = "-absolute" ]
then
  absolutepath `dirname "$2"` `'ls' -ld "$2" | takecols 11`
else
  # "ls" -l "$@" | awk ' { printf($9"symlnk"$11"\n"); } '
  # "ls" -l "$@" | awk ' { printf($11"\n"); } '
  # "ls" -ld "$@" | awk ' { printf($11"\n"); } '
  # 'ls' -ld "$@" | takecols 11 12 13 14 15 17 18 19 20 21 22 23 24 25 26
  # 'ls' -ld "$@" | sed "s/[^ ]*[ ]*[^ ] [^ ]*[ ]*[^ ]*[ ]*[^ ]* [^ ]* [^ ]* [^ ]* [^ ]* [^ ]* //"
  # 'ls' -ld "$@" | grep " -> " | trimempty | afterfirst " -> "
  ## Made run-aloneable for refreshtoollinks
  'ls' -ld "$@" | grep " -> " | grep -v "^$" | sed 's+.* -> ++'
fi

