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
# This looks far too dirty grey:
#xterm -fg "#004400" -bg "#bbbb99" "$@" &
# Medium-strong cream, acceptable but still a bit bright:
#xterm -fg "#004400" -bg "#ddddbb" "$@" &
# Medium-strong cream, acceptable:
#xterm -fg "#004400" -bg "#ccccaa" "$@" &
# Softened yellow, about right (originally weaker b4):
xterm -fg "#004400" -bg "#ccccb0" "$@" &
# Darker, faded weak yellow, approaching dirty grey:
#xterm -fg "#004400" -bg "#c0c0a8" "$@" &

# Black on green (like the SpyAmp's LCD theme):
#xterm -fg "#222222" -bg "#88bb88" "$@" &

