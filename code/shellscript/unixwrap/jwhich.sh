#!/bin/sh

if [ "$1" = "" ]; then
  echo "jwhich [ inj ] <file> [ quietly ]"
  echo "  will find the file in your \$PATH minus \$JPATH (unless inj specified)"
  exit 1
fi

fakeungrep () {
	sed "s|.*$*.*||"
}

if test "$1" = "inj"; then
  PATHS=`echo "$PATH" | tr ":" "\n"`
  shift
else
  # Remove all references to JLib from the path
  PATHS=`echo "$PATH" | tr ":" "\n" | fakeungrep "$JPATH"`;
fi
FILE="$1"
QUIETLY="$2"

# Note the quotes around $PATHS here are important, otherwise unix converts into one line again!
# This is no good cos it spawns a new process, and the exit doesn't work.
# echo "$PATHS" | while read dir; do
# This seems to work better, although there may be problems with spaces in the PATH
for dir in $PATHS; do
  if test -f "$dir/$FILE"; then
    if [ ! "$QUIETLY" = "quietly" ]; then
      echo $dir/$FILE
    fi
    exit 0      # Found!  :)
  # else
    # echo "$dir/$FILE does not exist"
  # else
	  # echo "$dir/$FILE is not a file"
  fi
done

if [ ! "$QUIETLY" = "quietly" ]; then
  echo "Could not find $FILE in any of"
  echo "$PATHS"
fi >&2
exit 1          # Not found  :(
