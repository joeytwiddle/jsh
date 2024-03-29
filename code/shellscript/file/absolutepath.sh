#!/bin/sh
# jsh-ext-depends-ignore: file
# jsh-depends: isabsolutepath

# Alternative: ( cd "$1" && pwd )

if test "$1" = ""; then
  echo "absolutepath <file>"
  echo "  or"
  echo "absolutepath <parentdir> <file>"
  exit 1
fi

if test "$2" = ""; then
  PARENT="$PWD"
  FILE="$1"
else
  PARENT="$1"
  FILE="$2"
fi

if isabsolutepath "$FILE"; then
  echo "$FILE"
else
  echo "$PARENT/$FILE"
fi
