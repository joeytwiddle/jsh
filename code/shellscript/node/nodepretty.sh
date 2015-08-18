#!/bin/sh

# You will need prettydiff installed: npm install -g prettydiff

[ -z "$PRETTYDIFF_APP" ] && PRETTYDIFF_APP=$HOME/npm/bin/prettydiff

[ -z "$PRETTYDIFF_MODE" ] && PRETTYDIFF_MODE=beautify

if [ "$#" = 0 ]
then
	# This did something weird.  It replaced all `/` with `\` and left everything else unchanged.
	#node "$PRETTYDIFF_APP" source:"`cat`" readmethod:screen     mode:"$PRETTYDIFF_MODE" report:false
	# It rejects /dev/stdin as input because it isn't a file.
	# But reading from a tempfile worked fine:
	tmpfile=/tmp/nodepretty.$USER.$$.js
	cat > "$tmpfile"
	node "$PRETTYDIFF_APP" source:"$tmpfile" readmethod:filescreen mode:"$PRETTYDIFF_MODE" report:false
	rm -f "$tmpfile"
elif [ "$#" = 1 ]
then node "$PRETTYDIFF_APP" source:"$1"    readmethod:filescreen mode:"$PRETTYDIFF_MODE" report:false
elif [ "$#" = 2 ]
then node "$PRETTYDIFF_APP" source:"$1"    readmethod:file       mode:"$PRETTYDIFF_MODE" report:false output:"$2"
fi

