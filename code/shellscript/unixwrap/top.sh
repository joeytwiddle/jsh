#!/bin/sh
## well we want to unexport it cos jsh exports it (useful for some apps, but not top, if you change term size whilst it's running)
unset COLUMNS

## The problem with top c, is if the user writes c mode to their .toprc with W, then this will undo that!
unj top -n 200 "$@"
# unj top "$@"
## They can get round it by saving the default non-c mode to their .toprc again.

# jwatchchanges top c n 1 "$@"
