REALMAN=`jwhich man`

## If X is running, will pop up a terminal at appropriate width
if xisrunning
then
	rememo $REALMAN -a "$@" > /dev/null
	test "$?" = 0 || exit 5
	WIDTH=`memo $REALMAN -a "$@" | col -bx | longestline`
	export COLUMNS=120
	# or whatever you prefer
	WIDTH=`expr $WIDTH + 2`
	if test "$WIDTH" -lt "10"; then echo "col -bx | longestline failed"; WIDTH="80"; fi
	whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e $REALMAN "$@"
else
	$REALMAN -a "$@"
fi

## Always in terminal; looks for documentation within j project
if test -x "$JPATH/tools/$1"
then jdoc "$@"
fi

