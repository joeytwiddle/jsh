#!/bin/sh
# Wrapper for prettydiff that works as expected (Unix-like) for 0, 1 or 2 arguments.
# You will need prettydiff installed: npm install -g prettydiff

[ -z "$PRETTYDIFF_APP" ] && PRETTYDIFF_APP=$HOME/npm/bin/prettydiff

if [ "$1" = "--help" ] || [ "$1" = "-help" ] || [ "$1" = "-h" ]
then
	(
		echo "A unix-like wrapper for prettydiff"
		echo
		echo "Usage:"
		echo
		echo "    nodepretty [<option>s] [ <input_file> [ <output_file> ] ]"
		echo
		echo "where <option>s are in the form:"
		echo
		echo "    -<name>=<value>"
		echo
		echo "      or"
		echo
		echo "    -<name> <value>"
		echo
		echo "The prefix -- may also be used."
		echo
		echo "Now here is the help for prettydiff itself:"
		echo
		"$PRETTYDIFF_APP"
		echo
	) | less -REX
	exit 0
fi

[ -z "$PRETTYDIFF_MODE" ] && PRETTYDIFF_MODE=beautify

prettydiff_opts=""

# Parse options
while echo "$1" | grep '^--*' >/dev/null
do
	if echo "$1" | grep "=" >/dev/null
	then
		optname=$(echo "$1" | sed 's+=.*++' | sed 's+^--*++')
		optval=$(echo "$1" | sed 's+.*=++')
		shift
	else
		optname=$(echo "$1" | sed 's+^--*++')
		optval="$2"
		shift
		shift
	fi
	prettydiff_opts="$prettydiff_opts $optname:$optval"
done

if [ "$#" = 0 ]
then
	# Read from stdin, write to stdout
	# This did something weird.  It replaced all `/` with `\` and left everything else unchanged.
	#node "$PRETTYDIFF_APP" source:"`cat`" readmethod:screen mode:"$PRETTYDIFF_MODE" report:false
	# It also rejects /dev/stdin as input because it isn't a file.
	# But reading from a tempfile worked fine:
	tmpfile=/tmp/nodepretty.$USER.$$.js
	cat > "$tmpfile"
	node "$PRETTYDIFF_APP" $prettydiff_opts source:"$tmpfile" readmethod:filescreen mode:"$PRETTYDIFF_MODE" report:false
	rm -f "$tmpfile"
elif [ "$#" = 1 ]
then
	# Read from file $1, write to stdout
	node "$PRETTYDIFF_APP" $prettydiff_opts source:"$1" readmethod:filescreen mode:"$PRETTYDIFF_MODE" report:false
	# This should also do the same, but it uses a tmpfile:
	#cat "$1" | nodepretty
elif [ "$#" = 2 ]
then
	# Read from file $1, write to file $2
	# This doesn't do what I expected: it creates a folder $2 containing the result and a "report" (which for me was just the result again!)
	#node "$PRETTYDIFF_APP" source:"$1" readmethod:file mode:"$PRETTYDIFF_MODE" report:false output:"$2"
	# But this will work:
	#nodepretty "$1" > "$2"
	sh "$0" "$1" > "$2"
fi
