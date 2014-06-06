#!/bin/sh

#. require_exes wmctrl xdotool

# This should have been possible purely with wmctrl but `wmctrl -r id -R desk` always moved the currently focused window.

desktopsPerRow=3

showhelp() {
cat << !

  move_windows_between_desktops swapdesktops up|down|left|right

!
}

if [ "$1" = swapdesktops ]
then

	numDesktops=` wmctrl -d | wc -l `

	fromDesktop=` wmctrl -d | grep "[^ ]* *\*" | takecols 1 `
	echo "fromDesktop: $fromDesktop"

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

	toDesktop=` expr '(' $fromDesktop $offset '%' $numDesktops ')' `
	if [ "$toDesktop" -lt 0 ]
	then toDesktop=` expr $toDesktop + $numDesktops `
	fi
	echo "toDesktop: $toDesktop"

	windowsOnDesktopA=` wmctrl -l -p -G -x | grep "^[^ ]*  *$fromDesktop " | takecols 1 `
	echo "windowsOnDesktopA: $windowsOnDesktopA"
	windowsOnDesktopB=` wmctrl -l -p -G -x | grep "^[^ ]*  *$toDesktop " | takecols 1 `
	echo "windowsOnDesktopB: $windowsOnDesktopB"

	# ...

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
