#!/bin/bash
# jsh-ext-depends: find

## Problem: many filesystems do not hold accurate enough dates that allow us to
## notice two writes in one second.
## Therefore 'find -newer' acts paranoid, and actually reports files written to
## in the same second as newer than each other!
## In some jsh applications this is useful/essential (vfs), in others it is
## problematic.
## TODO: We must adopt a default behaviour, and an override option.
##       What does the original 'newer' do?  I think we have matched its
##       behaviour.

## This does not work!
# find "$2" -maxdepth 0 -newer "$1" >/dev/null
## Although it would with | grep .

## This does
[[ "$(find "$2" -maxdepth 0 -newer "$1")" = "" ]]

# exit "$?"   ## Don't use exit, so we can be imported with importshfn.



## Older:
# N=`jwhich newer`
# if [ "$N" ]
# then "$N" "$@"
# else [ ! "`find "$2" -maxdepth 0 -newer "$1"`" ]
# fi
# exit "$?"

## Even older:
# OLD-jsh-depends: unj mynewer
## Returns true (0) if they are the same age:
# unj -quiet newer "$@" ||
## Used to return false (1) if they were the same age, but now it behaves the same as the other :)
# mynewer "$@"

