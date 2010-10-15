#!/bin/sh
## Unlike newwin, this allows option passing to xterm, so for execution, -e <com> is required.

# xterm -fg black -bg white "$@" &

## Cream:
# xterm -fg "#003000" -bg "#ffffeb" "$@" &
# xterm -fg "#003000" -bg "#ffffe4" "$@" &
xterm -fg "#005500" -bg "#ffffbb" "$@" &

## Green/black LCD (SpyAmp):
# xterm -fg "#222222" -bg "#88bb88" "$@" &
# $JPATH/tools/xterm -fg "#222222" -bg "#88bb88" "$@" &

