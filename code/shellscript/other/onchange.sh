#!/bin/sh
# Todo: Make it work on multiple files
# er does work on multiple files but must be in quotes - fix?

## This is OK on Linux but not Unix (Why? ...)
# littletest() {
#   newer "$file" "$COMPFILE"
# }

# Not sure what ignore does.
# Difference appears to be all files in dir
# as opposed to files provided in list

if test "$1" = "--help" -o "$1" = "" -o "$2" = ""; then
	echo
	echo 'onchange [-fg] [-d] [ -ignore do | "<files>.." [do] ] <command>'
	echo
	echo '  Multiple files must be contained in "quotes".'
	echo
	echo '  -ignore means you need not provide a file list, the current folder will be scanned'
	echo
	echo '  -d is "desensitize" - we will not re-trigger on any files changed during the build process (command)'
	echo
	echo '  -fg runs in the current shell instead of popping up a new terminal.  It is also used internally.'
	echo
	echo '  There is currently no support for the command to know which file changed, but there could be...'
	# NO!  echo '  If you are really cunning, you could use "\$file" in your command!'
	echo
	exit 1
fi

if test "$1" = "-fg"; then
	shift
else
	if xisrunning; then
		xterm -e onchange -fg "$@" &
	else
		onchange -fg "$@" &
	fi
	exit
fi

if test "$1" = "-d"; then
	DESENSITIZE=true
	shift
fi

if test "$1" = "-ignore"; then
	IGNORE=true
	shift
fi

if test "$COLUMNS" = ""; then export COLUMNS=80; fi
FILES="$1"
shift
if [ "$1" = "do" ]
then shift
fi
COMMANDONCHANGE="eval $*"
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
				echo
				cursecyan
				for X in `seq 1 $COLUMNS`; do printf "-"; done; echo
				echo "$file changed, running: $COMMANDONCHANGE"
				cursenorm
				echo
				xttitle "> onchange running $COMMANDONCHANGE ($file changed)"
				$COMMANDONCHANGE
				cursecyan
				echo "Done."
				cursenorm
				[ "$DESENSITIZE" ] && sleep 2 && touch "$COMPFILE"
				xttitle "# onchange watching $FILES ($file changed last)"
				# break
			fi
		done
	fi
done
jdeltmp "$COMPFILE"
