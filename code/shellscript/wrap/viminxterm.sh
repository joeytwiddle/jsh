#!/bin/sh
## BUGS: Works badly on .gzipped files.  Either skip sizing or gunzip them!

# jwhich inj vim > /dev/null
jwhich vim > /dev/null

if [ ! "$?" = "0" ]
then
	echo "viminxterm failing: vim not present"
	exit 1
fi

FILE="$1"

## TODO: this algorithm should be refactored out.  But how should it return /two/ values?  Source it or use it as a fn?  But it uses so many variables, we should ensure they are kept local.  Fn then, not direct sourcing.
## If the file exists, this cunning algorithm is used to determine the optimal dimensions for the editor window
## If the file needs more space than the maximum volume allowed, the algorithm prioritises height over width, but within limits.
if [ -f "$FILE" ] && [ ! `filesize "$FILE"` = "0" ]
then

	MAXVOL=`expr 140 "*" 50`
	MAXCOLS=180
	MAXROWS=50
	MINCOLS=20
	MINROWS=10

	## In some ways, this only applies to vim, because most editors won't unzip .gzipped files when reading them.
	if endswith "$FILE" "\.gz"
	then
		FILETOREAD=`jgettmp viminxterm_"$FILE".unzipped`
		gunzip -c "$FILE" > "$FILETOREAD"
	else
		FILETOREAD="$FILE"
	fi

	ROWSINFILE=`countlines "$FILETOREAD"`
	COLSINFILE=`longestline "$FILETOREAD"`
	# echo "ROWSINFILE = $ROWSINFILE"
	# echo "COLSINFILE = $COLSINFILE"

	if [ ! "$FILETOREAD" = "$FILE" ]
	then jdeltmp $FILETOREAD
	fi

	## Expand the perceived dimensions of the file, so that the editor will show a little gap at the sides
	ROWSINFILE=`expr '(' $ROWSINFILE '+' 2 ')' '*' 11 '/' 10`;
	COLSINFILE=`expr '(' $COLSINFILE '+' 2 ')' '*' 11 '/' 10`

	## Determine desired height, without exceeding needed height, or maximum allowed height
	if [ $ROWSINFILE -lt $MAXROWS ]
	then ROWS=$ROWSINFILE
	else ROWS=$MAXROWS
	fi

	## Determine largest possible width without exceeding maximum allowed volume
	COLS=`expr $MAXVOL / $ROWS`
	## Also, do not exceed needed width
	if [ $COLSINFILE -lt $COLS ]
	then COLS=$COLSINFILE
	fi
	## Also, do not exceed maximum allowed width
	if [ $COLS -gt $MAXCOLS ]
	then COLS=$MAXCOLS
	fi

	## And do not fall below minimum allowed width and height
	if [ $COLS -lt $MINCOLS ]
	then COLS=$MINCOLS
	fi
	if [ $ROWS -lt $MINROWS ]
	then ROWS=$MINROWS
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
