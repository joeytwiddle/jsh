#!/bin/bash

wmctrl -l -p -G -x |

# We always restore XMMS and the panels with bad values, so let's just skip them:
grep -v "\<\(XMMS_.*\.xmms\|panel\.lxpanel\|kicker\.Kicker\)\>" |

while read ID DESKTOP PID X Y WIN_WIDTH WIN_HEIGHT WM_CLASS TITLE
do
	## Gah.  We need to adjust for wm decorations.  :F
	#X=$((X-1))
	# Using my larger Fluxbox theme
	#Y=$((Y-45))
	# Using my smaller Fluxbox theme OrangeJuiceCuteNano
	#Y=$((Y-51))
	# For my Plasma5 (with a panel at the top)
	Y=$((Y-32))
	echo "wmctrl -i -r '$ID' -e '0,$X,$Y,$WIN_WIDTH,$WIN_HEIGHT'"
done > "$HOME"/.wmctrl_stored_positions
