#!/bin/sh

# jwhich inj vim > /dev/null
jwhich vim > /dev/null
if test ! "$?" = "0"; then
	echo "viminxterm failing: vim not present"
	exit 1
fi

FILE="$1";

if test -f "$FILE"; then

	MAXVOL=`expr 80 "*" 50`

	# Determine desired height
	LINES=`countlines $FILE`
	ROWS=`expr '(' $LINES '+' 2 ')' '*' 11 '/' 10`;
	if test $ROWS -gt 50; then
		ROWS=50
	fi

	# Determine desired width
	LONGEST=`longestline $FILE`
	LONGEST=`expr '(' $LONGEST '+' 2 ')' '*' 11 '/' 10`

	# Determine optimal distribution
	# Actually choose columns from maxvolume and rows
	COLS=`expr $MAXVOL / $ROWS`
	# But expand columns to fill longest line!
	if test $LONGEST -lt $COLS; then
		COLS=$LONGEST;
	fi

	# Ensure at least minimum size
	if test $COLS -lt 20; then
		COLS=20
	fi
	if test $ROWS -lt 5; then
		ROWS=5
	fi

else

	# Default size for new file
	COLS=40
	ROWS=20

fi

INTGEOM=`echo "$COLS"x"$ROWS" | sed 's|\..*x|x| ; s|\..*$||'`

TITLE=`absolutepath "$@"`" [vim]"

XTFONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1';
`jwhich xterm` -fg white -bg black -geometry $INTGEOM -font $XTFONT -title "$TITLE" -e vim "$@"
