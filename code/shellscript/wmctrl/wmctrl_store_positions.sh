#!/bin/bash
wmctrl -l -p -G -x |
while read ID DESKTOP PID X Y WIN_WIDTH WIN_HEIGHT WM_CLASS TITLE
do
	## Gah.  We need to adjust for wm decorations.  :F
	X=$((X-1))
	Y=$((Y-51))
	echo "wmctrl -i -r '$ID' -e '0,$X,$Y,$WIN_WIDTH,$WIN_HEIGHT'"
done > "$HOME"/.wmctrl_stored_positions
