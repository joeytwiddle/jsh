REALMAN=`jwhich man`
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

if test -x "$JPATH/tools/$1"
then jdoc "$@"
fi

