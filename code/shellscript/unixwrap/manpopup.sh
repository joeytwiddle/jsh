REALMAN=`jwhich man`
# INJ=`jwhich inj $1`

## If user is running in X, we pop up a separate window for them
if xisrunning
then
	# [ "$INJ" ] && whitewin -title "jdoc $1" -geometry 80x60 -e jdoc "$1"
	## man will try to fit page within COLUMNS>=80plz, and then we will fit to whatever man outputs
	export COLUMNS=120
	## First, check a manual page actually exists: (man will print error for us if not)
	if rememo $REALMAN -a "$@" > /dev/null
	then
		## Need to format output to find widest line
		WIDTH=`memo $REALMAN -a "$@" | col -bx | longestline`
		# WIDTH=`expr $WIDTH + 2`
		if test "$WIDTH" -lt "10"; then echo "col -bx | longestline failed" | tee -a "$JPATH/logs/jshdebug"; WIDTH="80"; fi
		whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e $REALMAN -a "$@"
	fi
else
	$REALMAN -a "$@"
	# [ "$INJ" ] && jdoc "$1"
fi

## Always in terminal; looks for documentation within j project
if test -x "$JPATH/tools/$1"
then jdoc "$@"
fi

