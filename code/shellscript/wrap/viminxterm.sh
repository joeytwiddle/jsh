#!/bin/sh

# jwhich inj vim > /dev/null
jwhich vim > /dev/null
if test ! "$?" = "0"; then
	echo "viminxterm failing: vim not present"
	exit 1
fi

FILE="$1";

MAXVOL=`expr 80 "*" 50`

if test -f "$FILE"; then

	# Determine optimal height
	LINES=`cat $FILE | countlines`
	ROWS="50"
	if test $LINES -lt $ROWS; then
		ROWS=`expr '(' $LINES '+' 2 ')' '*' 11 '/' 10`;
	fi

	# Determine optimal width
	LONGEST=`longestline $FILE`
	LONGEST=`expr "(" $LONGEST "+" 2 ")" "*" 11 "/" 10`

	# Determine optimal distribution
	COLS=`expr $MAXVOL / $ROWS`
	if test $LONGEST -lt $COLS; then
		COLS=$LONGEST;
	fi

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

# echo "$COLS"x"$ROWS"

INTGEOM=`echo "$COLS"x"$ROWS" | sed 's|\..*x|x| ; s|\..*$||'`

# TITLE="vi:$ARGS"
# TITLE=`filename "$ARGS"`"("`dirname "$ARGS"`"/)" # This seems to be what Vim actually forces on the xterm.
TITLE=`absolutepath "$ARGS"`" [vim]"

# FONT="-font '-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv'"
# XTFONT='-schumacher-clean-medium-r-normal-*-*-150-*-*-c-*-iso646.1991-irv';
# XTFONT='-b&h-lucidatypewriter-medium-r-normal-*-*-120-*-*-m-*-iso8859-1';
XTFONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1';
`jwhich xterm` -fg white -bg black -geometry $INTGEOM -font $XTFONT -title "$TITLE" -e vim "$@"

# xterm -geometry 70x40 -font '-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1' -title "vim:$ARGS" -e "vim $ARGS"
# gnome-terminal -geometry 70x40 --font='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1' --title="vim:$ARGS" --execute="vim $ARGS"
