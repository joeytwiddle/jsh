#!/bin/sh
if test -f "$*"; then
  awk '{ if (length($0) > max) max = length($0) } END { print max }' $*
else
  echo 0
fi
