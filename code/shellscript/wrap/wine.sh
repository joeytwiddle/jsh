#!/bin/sh

## Wine used to crash due to my crazy fonts, so this disabled them temporarily
# xset fp- unix/:7101 2>/dev/null
# ( sleep 2m; xset fp+ unix/:7101 ) &
## This was confusing, when jwhich failed and returned "", we just called "@", which occasionally does run a working command under linux >.<
# `jwhich wine` "$@"

## Fullscreen wine apps (games, demos) often shrink the desktop, disturbing window positioning.
## Not all of them restore the desktop after running either!
## So we will store window positions before running, and restore afterwards.
wmctrl_store_positions
unj wine "$@"
xrandr -s 1280x1024
# wmctrl_restore_positions doesn't work in compiz
findjob compiz >/dev/null ||
wmctrl_restore_positions
