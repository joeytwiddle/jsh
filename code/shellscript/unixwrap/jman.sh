if xisrunning
then
	# WIDTH=`man "$@" | col -bx | longestline`
	# Nah running my man -> jdoc pauses for input!
	export COLUMNS=120
	# or whatever you prefer
	`jwhich man` "$@" > /dev/null
	test "$?" = 0 || exit
	WIDTH=`\`jwhich man\` "$@" | col -bx | longestline`
	WIDTH=`expr $WIDTH + 2`
	if test "$WIDTH" -lt "10"; then echo "col -bx | longestline failed"; WIDTH="80"; fi
	whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e man "$@"
else
	`jwhich man` "$@"
fi
