#!/bin/sh
awk 'BEGIN { max=0 } { if (length($0) > max) max = length($0) } END { print max }' "$@"
# Linux info output is full of '^H's!  Used col -bx.
# awk '{ if (length($0) > max) { max = length($0); print length($0) ">"$0"<" } } END { print max }' $*
# if test -f "$*"; then
  # awk '{ if (length($0) > max) max = length($0) } END { print max }' $*
# else
  # echo 0
# fi
