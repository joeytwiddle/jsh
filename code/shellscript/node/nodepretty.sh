#!/bin/sh

# You will need prettydiff installed: npm install -g prettydiff

[ -z "$PRETTYDIFF_APP" ] && PRETTYDIFF_APP=$HOME/npm/bin/prettydiff

[ -z "$PRETTYDIFF_MODE" ] && PRETTYDIFF_MODE=beautify

if [ "$#" = 0 ]
then
	# Read from stdin, write to stdout
	# This did something weird.  It replaced all `/` with `\` and left everything else unchanged.
	#node "$PRETTYDIFF_APP" source:"`cat`" readmethod:screen     mode:"$PRETTYDIFF_MODE" report:false
	# It rejects /dev/stdin as input because it isn't a file.
	# But reading from a tempfile worked fine:
	tmpfile=/tmp/nodepretty.$USER.$$.js
	cat > "$tmpfile"
	node "$PRETTYDIFF_APP" source:"$tmpfile" readmethod:filescreen mode:"$PRETTYDIFF_MODE" report:false
	rm -f "$tmpfile"
elif [ "$#" = 1 ]
then
	# Read from file $1, write to stdout
	node "$PRETTYDIFF_APP" source:"$1" readmethod:filescreen mode:"$PRETTYDIFF_MODE" report:false
	# This should also do the same, but it uses a printfile:
	#cat "$1" | nodepretty
elif [ "$#" = 2 ]
then
	# Read from file $1, write to file $2
	# This doesn't do what I expected: it creates a folder $2 containing the result and a "report" (which for me was just the result again!)
	#node "$PRETTYDIFF_APP" source:"$1" readmethod:file mode:"$PRETTYDIFF_MODE" report:false output:"$2"
	# But this will work:
	nodepretty "$1" > "$2"
fi

