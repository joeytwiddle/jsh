#!/bin/sh

if [ "$1" = "" ]; then
  echo "jwhich [ inj ] <file> [ quietly ]"
  echo "  will find the file in your \$PATH minus \$JPATH (unless inj specified)"
  echo "  quietly means it just checks and returns 1/0, but does not print anything."
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
    test ! "$QUIETLY" && echo $dir/$FILE
    exit 0      # Found!  :)
  # else
    # echo "$dir/$FILE does not exist"
  # else
	  # echo "$dir/$FILE is not a file"
  fi
done

## For debug: returns this command as "found" file (useful cos it's non-empty so it reaches further!)
# echo "jwhich_error_could_not_find_$FILE"

exit 1          # Not found  :(
