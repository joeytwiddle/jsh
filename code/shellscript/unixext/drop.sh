#!/bin/sh
# Skips N lines from the front of a stream.
# Note: awkdrop is recommended for speed.

N=$1
shift
cat "$@" | while read LINE; do
  if test "$N" = "0"; then
    echo "$LINE"
  else
    N=$(($N-1));
  fi
done
