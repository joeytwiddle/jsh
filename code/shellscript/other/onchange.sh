# Todo: Make it work on multiple files

# This is OK on Linux but not Unix:
# function littletest() {
#   newer "$file" "$COMPFILE"
# }

if test ! "$1" = "-nowinxterm" && xisrunning; then
	xterm -e onchange -nowinxterm "$@" &
	exit
fi
shift

if test "$1" = "" -o "$2" = ""; then
	echo 'onchange [-ignore] <files> [do] <command>'
	echo '  Multiple files must be contained in "quotes".'
	echo '  There is currently no support for the command to know which file changed, but there could be...'
	# NO!  echo '  If you are really cunning, you could use "\$file" in your command!'
	exit 1
fi

if test "$1" = "-ignore"; then
	IGNORE=true
	shift
fi

FILES="$1"
COMMANDONCHANGE="$2" # $3 $4 $5 $6 $7 $8 $9"
if test "$2" = "do"; then
	COMMANDONCHANGE="$3" # $4 $5 $6 $7 $8 $9"
fi
COMPFILE=`jgettmp onchange`
# COMPFILE="$JPATH/tmp/onchange.tmp"
touch "$COMPFILE"
while true; do
	sleep 1
	breakonctrlc
	# echo "."
	if test $IGNORE; then
		NL=`find . -newer "$COMPFILE" | grep -v "/\." | countlines`
		if test "$NL" -gt "0"; then
			echo "something changed, running: $COMMANDONCHANGE"
			xttitle "> onchange running $COMMANDONCHANGE"
			$COMMANDONCHANGE
			echo "Done."
			xttitle "# onchange watching $FILES"
			sleep 1
			touch "$COMPFILE"
		fi
	else
		for file in $FILES; do
			if mynewer "$file" "$COMPFILE"; then
				touch "$COMPFILE"
				echo "$file changed, running: $COMMANDONCHANGE"
				xttitle "> onchange running $COMMANDONCHANGE ($file changed)"
				$COMMANDONCHANGE
				echo "Done."
				xttitle "# onchange watching $FILES ($file changed last)"
				# break
			fi
		done
	fi
done
jdeltmp "$COMPFILE"
