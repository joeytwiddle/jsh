#!/bin/sh
# Skips N lines from the front of a stream.
# Note: awkdrop is recommended for speed.

## TODO: echo (and even printf) can muck up lines with adjacent spaces!
##       deprecate this method, in favour of some other, eg. awkdrop.

N=$1
shift
cat "$@" |
while read LINE
do
  if test "$N" = "0"
  then printf "%s\n" "$LINE"
  else N=$(($N-1));
  fi
done
