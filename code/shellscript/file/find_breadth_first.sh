#!/usr/bin/env bash

dir="$1" ; shift

depth=1

# Loop as long as find returns any results for the current depth
while true
do
    # -printf "%d\t%p\n"
    find "$dir" -mindepth "$depth" -maxdepth "$depth" "$@" |
      if [ -n "$SORT" ]
      then sort
      else cat
      fi |
      grep . || break
    depth="$((depth + 1))"
done

true
