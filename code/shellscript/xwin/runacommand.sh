#!/bin/sh
## Provides functionality like F2 in KDE and Gnome.
## I use "Mod1 F2 :ExecCommand runacommand" in my ~/.fluxbox/keys

if [ ! "$1" = -2 ]
then
	xterm -geometry 40x5 -font "-b&h-lucidatypewriter-medium-r-normal-*-*-180-*-*-m-*-iso8859-1" -e runacommand -2
else
	shift
	echo "Run what?"
	echo
	echo -n "% "
	cursegreen
	read TORUN
	cursenorm
	# echo "$TORUN" | bash &
	bigwin $TORUN
	sleep 1
fi
