## OK we checked if they are off the left or top of the screen.
## DONE: But what if they are off the right or bottom?!
## TODO: What if they are too large for the screen?!
## TODO: What if their geometry is 0x0?!
## BUG:  In fluxbox, if I change Y, X moves what looks like +1.
## BUG:  When I move up to bring tabbed-term within desktop, I think
##       decoration height is ignored, so we still end up outside.

# REMOVE_EXTRA_HEIGHT=0
REMOVE_EXTRA_HEIGHT=33 ## compensates for my title height under fluxbox

DESKTOP_RESOLUTION=`wmctrl -d | grep "[^ ]* *\*" | takecols 4`
DESKTOP_WIDTH=`echo "$DESKTOP_RESOLUTION" | beforefirst x`
DESKTOP_HEIGHT=`echo "$DESKTOP_RESOLUTION" | afterfirst x`

wmctrl -l -p -G -x |

while read ID DESKTOP PID X Y WIN_WIDTH WIN_HEIGHT WM_CLASS TITLE
do

	RIGHT=$((X+WIN_WIDTH))
	BOTTOM=$((Y+WIN_HEIGHT))

	NEWX="$X"
	NEWY="$Y"

	if [ "$((X+WIN_WIDTH))" -gt $DESKTOP_WIDTH ]
	then NEWX=$((DESKTOP_WIDTH-WIN_WIDTH))
	fi

	if [ "$((Y+WIN_HEIGHT))" -gt $DESKTOP_HEIGHT ]
	then NEWY=$((DESKTOP_HEIGHT-WIN_HEIGHT-REMOVE_EXTRA_HEIGHT))
	fi

	if [ "$X" -lt 0 ]
	then NEWX=0
	fi

	if [ "$Y" -lt 0 ]
	then NEWY=0
	fi

	if [ "$NEWX" != "$X" ] || [ "$NEWY" != "$Y" ]
	then
		# echo ">>>" wmctrl -r "$ID" -e 0,$NEWX,$NEWY,$WIN_WIDTH,$WIN_HEIGHT
		wmctrl -i -r "$ID" -e 0,$NEWX,$NEWY,$WIN_WIDTH,$WIN_HEIGHT
		# break
	fi

done


