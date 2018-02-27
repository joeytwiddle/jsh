#!/bin/sh
# Unlike newwin, this allows option passing to xterm, so for execution, -e <com> is required.

#xterm -fg black -bg white "$@" &

# Cream:
#xterm -fg "#003000" -bg "#ffffeb" "$@" &
#xterm -fg "#003000" -bg "#ffffe4" "$@" &
#xterm -fg "#005500" -bg "#ffffbb" "$@" &
# Below I start tweaking the colors for my work display:
# This looks far too yellow:
#xterm -fg "#005500" -bg "#eeee99" "$@" &
# This still looks a bit too rich, but acceptable:
#xterm -fg "#004400" -bg "#ddddaa" "$@" &
# Medium-strong cream, acceptable but still a bit bright:
#xterm -fg "#004400" -bg "#ddddbb" "$@" &
# Softened yellow, about right on Mac, but way too washed out on Linux:
#xterm -fg "#004400" -bg "#ccccb0" "$@" &
# Darker, faded weak yellow, approaching dirty grey, again just grey on Linux:
#xterm -fg "#004400" -bg "#c0c0a8" "$@" &
## Trying to find a compromise
# Awful, completely grey on Linux:
#xterm -fg "#004400" -bg "#bbbbaa" "$@" &
# Medium-strong cream, acceptable on Mac.  A bit white on Linux, but ok.
#xterm -fg "#004400" -bg "#ccccaa" "$@" &
## Looks fine on Linux (a visible cream):
#xterm -fg "#004400" -bg "#cccc99" "$@" &
# Looks a bit grey on Linux, but acceptable it if we cannot accept the previous:
#xterm -fg "#004400" -bg "#bbbb99" "$@" &
# Attempt at a compromise:
#xterm -fg "#004400" -bg "#cccca4" "$@" &

if [ "$(uname)" = "Linux" ]
then xterm -fg "#004400" -bg "#cccc99" "$@" &
else xterm -fg "#004400" -bg "#c8c8aa" "$@" &
fi

# Black on green (like the SpyAmp's LCD theme):
#xterm -fg "#222222" -bg "#88bb88" "$@" &

