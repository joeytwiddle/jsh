#!/bin/sh
## BUGS: Works badly on .gzipped files.  Either skip sizing or gunzip them!

# jwhich inj vim > /dev/null
jwhich vim > /dev/null

if [ ! "$?" = "0" ]
then
	echo "viminxterm failing: vim not present"
	exit 1
fi

FILE="$1";

if [ -f "$FILE" ] && [ ! `filesize "$FILE"` = "0" ]
then

	## TODO/BUG: Longest line calculations do not work on .gz files, but could with gunzip -c ...

	# MAXVOL=`expr 80 "*" 50`
	MAXVOL=`expr 120 "*" 60`

	LINES=`countlines "$FILE"`
	LONGEST=`longestline "$FILE"`
	LONGEST=`expr '(' $LONGEST '+' 2 ')' '*' 11 '/' 10`

	# echo "LINES = $LINES"
	# echo "LONGEST = $LONGEST"

	# Determine desired height
	ROWS=`expr '(' $LINES '+' 2 ')' '*' 11 '/' 10`;
	if [ $ROWS -gt 50 ]
	then ROWS=50
	fi

	# Determine optimal distribution
	# Actually choose width cols from maxvolume and rows
	COLS=`expr $MAXVOL / $ROWS`
	# but reduce to longest line if above.
	if [ $LONGEST -lt $COLS ]
	then COLS=$LONGEST;
	fi
	## But don't go too far!
	if test $COLS -gt 180
	then COLS=180
	fi

	# Ensure at least minimum size
	if [ $COLS -lt 20 ]
	then COLS=20
	fi
	if [ $ROWS -lt 5 ]
	then ROWS=5
	fi

else

	# Default size for new file
	COLS=50
	ROWS=20

fi

INTGEOM=`echo "$COLS"x"$ROWS" | sed 's|\..*x|x|;s|\..*$||'`

TITLE=`absolutepath "$1"`" [vim-never-shown]"

# XTFONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1';
# `jwhich xterm` -fg white -bg black -geometry $INTGEOM -font $XTFONT -title "$TITLE" -e vim "$@"

# xterm -bg "#000048" -geometry $INTGEOM -title "$TITLE" -e vim "$@"
xterm -bg "#000040" -geometry $INTGEOM -title "$TITLE" -e vim "$@"
