if xisrunning; then
	# WIDTH=`man "$@" | col -bx | longestline`
	# Nah running my man -> jdoc pauses for input!
	export COLUMNS=120
	# or whatever you prefer
	WIDTH=`\`jwhich man\` "$@" | col -bx | longestline`
	WIDTH=`expr $WIDTH + 2`
	if test "$WIDTH" -lt "10"; then WIDTH="80"; fi
	whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e man "$@"
else
	man "$@"
fi
