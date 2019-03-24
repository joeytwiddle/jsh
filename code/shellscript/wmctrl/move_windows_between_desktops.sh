#!/bin/sh

# Functions for moving windows between desktops.  So far only one is implemented:
#
# move_windows_between_desktops swapdesktops <direction>
#
#   Swaps all windows on current desktop with those on the desktop in the direction specified.
#

# KEYBINDS:
#
# You could make keybinds for these.  For example, a Fluxbox user would add this to his ~/.fluxbox/keys file:
#
# Control Mod4 Shift Left  :ExecCommand move_windows_between_desktops swapdesktops left
# Control Mod4 Shift Right :ExecCommand move_windows_between_desktops swapdesktops right
# Control Mod4 Shift Up    :ExecCommand move_windows_between_desktops swapdesktops up
# Control Mod4 Shift Down  :ExecCommand move_windows_between_desktops swapdesktops down

# IMPLEMENTATION NOTES:
#
# This should have been possible purely with wmctrl but `wmctrl -r id -R desk` always moved the currently focused window.

#. require_exes wmctrl xdotool

desktopsPerRow=3

notify=1

showhelp() {
cat << !

  move_windows_between_desktops swapdesktops up|down|left|right

!
}

if [ "$1" = swapdesktops ]
then

	numDesktops=` wmctrl -d | wc -l `

	fromDesktop=` wmctrl -d | grep "[^ ]* *\*" | takecols 1 `

	direction="$2"
	if [ "$direction" = up ]
	then offset="- $desktopsPerRow"
	elif [ "$direction" = down ]
	then offset="+ $desktopsPerRow"
	elif [ "$direction" = left ]
	then offset="- 1"
	elif [ "$direction" = right ]
	then offset="+ 1"
	else
		showhelp
		exit 4
	fi

	toDesktop=` expr '(' $fromDesktop $offset ')' '%' $numDesktops `
	if [ "$toDesktop" -lt 0 ]
	then toDesktop=` expr $toDesktop + $numDesktops `
	fi

	if [ -n "$notify" ]
	then
		killall osd_cat
		#font='-*-helvetica-*-r-*-*-*-400-*-*-*-*-*-*'
		#font='-*-nimbus roman no9 l-*-r-*-*-60-*-*-*-*-*-*-*'
		font='-*-helvetica-*-r-*-*-34-*-*-*-*-*-*-*'
		echo "Swapping desktops $fromDesktop and $toDesktop" |
		#echo "Moved desktop $fromDesktop $direction" |
		osd_cat -o 500 -d 2 -A center -c yellow -O 2 -f "$font"
	fi

	windowsOnDesktopA=` wmctrl -l -p -G -x | grep "^[^ ]*  *$fromDesktop " | takecols 1 `
	windowsOnDesktopB=` wmctrl -l -p -G -x | grep "^[^ ]*  *$toDesktop " | takecols 1 `

	wmctrl -s $toDesktop

	for winid in $windowsOnDesktopA
	#do wmctrl -r $winid -t $toDesktop
	do xdotool set_desktop_for_window $winid $toDesktop
	done

	for winid in $windowsOnDesktopB
	#do wmctrl -r $winid -t $fromDesktop
	do xdotool set_desktop_for_window $winid $fromDesktop
	done

	# I tried piping the commands to xdotool - which worked fine but wasn't significantly faster.

else

	showhelp
	exit 3

fi
