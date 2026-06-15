#!/usr/bin/env bash
set -e

MAX_DEPTH="${MAX_DEPTH:-8}"

dir="$1" ; shift

depth=1

while true
do
    # -printf "%d\t%p\n"
    find "$dir" -mindepth "$depth" -maxdepth "$depth" "$@" |
      if [ -n "$SORT" ]
      then sort
      else cat
      fi |
      # Loop as long as find returns any results for the current depth
      #grep . || break
      # Loop until MAX_DEPTH is reached
      cat
      # Orders results, but takes longer for deep results to appear
      #sort
    depth="$((depth + 1))"
    if [ "$depth" -gt "$MAX_DEPTH" ]
    then break
    fi
done

true
