#!/bin/bash
[[ "$(find "$2" -maxdepth 0 -newer "$1")" = "" ]]
# exit "$?"

## Older:
# N=`jwhich newer`
# if [ "$N" ]
# then "$N" "$@"
# else [ ! "`find "$2" -maxdepth 0 -newer "$1"`" ]
# fi
# exit "$?"

## Even older:
# jsh-depends: unj mynewer
## Returns true (0) if they are the same age:
# unj -quiet newer "$@" ||
## Used to return false (1) if they were the same age, but now it behaves the same as the other :)
# mynewer "$@"

