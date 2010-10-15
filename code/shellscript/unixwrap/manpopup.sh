#!/bin/sh
## DONE: Problems under Gentoo because memo is not caching because man returns non-zero exit code.
##       OK added fix to rememo, so it cats the cache whether the command succeeded or not.  (Seems appropriate!)

REALMAN=`jwhich man`
# INJ=`jwhich inj $1`

## If screen is running, could pop up in an extra window.  Could make this X/screen window popup functionality generic

## If user is running in X, we pop up a separate window for them
## DONE: This has caused problems when vnc is initialised from X, and has this variable exported to its children!  OK jsh has removed its export STY for now so this shouldn't be a problem.
if [ "$STY" ]
then screen -X screen -t '"'"$1"'"' $REALMAN -a "$@"
elif xisrunning
then
	# [ "$INJ" ] && whitewin -title "jdoc $1" -geometry 80x60 -e jdoc "$1"
	## man will try to fit page within COLUMNS>=80plz, and then we will fit to whatever man outputs
	export COLUMNS=120
	## First, check a manual page actually exists: (man will print error for us if not)
	if [ `memo $REALMAN -a "$@" | wc -l` -gt 0 ]
	then
		## Need to format output to find widest line
		WIDTH=`memo $REALMAN -a "$@" | col -bx | longestline`
		# WIDTH=`expr $WIDTH + 2`
		if test "$WIDTH" -lt "10"; then echo "col -bx | longestline failed" | tee -a "$JPATH/logs/jshdebug"; WIDTH="80"; fi
		# whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e $REALMAN -a "$@"
		whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e $REALMAN -a "$@"
		## TODO: whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e inscreendo man $REALMAN -a "$@"
	fi
else
	$REALMAN -a "$@"
	# [ "$INJ" ] && jdoc "$1"
fi

## Always in terminal; looks for documentation within j project
# if test -x "$JPATH/tools/$1"
# then jdoc "$@"
# fi

