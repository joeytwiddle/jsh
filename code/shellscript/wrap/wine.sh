#!/bin/sh
# xset fp- unix/:7101 2>/dev/null
# ( sleep 2m; xset fp+ unix/:7101 ) &
## This was confusing, when jwhich failed and returned "", we just called "@", which occasionally does run a working command under linux >.<
# `jwhich wine` "$@"
wmctrl_store_positions
unj wine "$@"
wmctrl_restore_positions
