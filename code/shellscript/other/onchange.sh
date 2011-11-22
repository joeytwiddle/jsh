#!/bin/bash
# Todo: Make it work on multiple files
# er does work on multiple files but must be in quotes - fix?

## This is OK on Linux but not Unix (Why? ...)
# littletest() {
#   newer "$file" "$COMPFILE"
# }

# Not sure what ignore does.
# Difference appears to be all files in dir
# as opposed to files provided in list

# Halves the forking
. importshfn newer

if test "$1" = "--help" -o "$1" = "" -o "$2" = ""; then
	cat << !

onchange [-fg] [-d] [ -ignore do | "<files>.." [do] ] <command>

  Multiple files must be contained in "quotes".

  -ignore means you need not provide a file list, the current folder will be
          scanned.

  -d is "desensitize" - we will not re-trigger on any files changed during the
     build process (command).

  -fg runs in the current shell instead of popping up a new terminal.  It is
      also used internally.

  There is currently no support for the command to know which file changed, but
  there could be...

  Checking is done once per second - I don't want to hang around waiting for a
  build to start!  Ideally we would make it even driven!

!
	# NO!    If you are really cunning, you could use "\$file" in your command!
	exit 1
fi

if test "$1" = "-fg"; then
	shift
else
	if xisrunning; then
		xterm -e nice -n 2 onchange -fg "$@" &
	else
		nice -n 2 onchange -fg "$@" &
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
xttitle "## onchange watching $FILES"
COMMANDONCHANGE="eval $*"
COMPFILE=`jgettmp onchange`
# COMPFILE="$JPATH/tmp/onchange.tmp"
touch "$COMPFILE"
while true; do
	sleep 1
	# breakonctrlc
	# echo "."
	if test $IGNORE; then
		NL=`find . -newer "$COMPFILE" | grep -v "/\." | countlines`
		if test "$NL" -gt "0"; then
			echo "something changed, running: $COMMANDONCHANGE"
			xttitle ">> onchange running $COMMANDONCHANGE"
			$COMMANDONCHANGE
			echo "Done."
			xttitle "## onchange watching $FILES"
			sleep 1
			touch "$COMPFILE"
		fi
	else
		for file in $FILES; do
			if newer "$file" "$COMPFILE"; then
				touch "$COMPFILE"
				echo
				cursecyan
				for X in `seq 1 $COLUMNS`; do printf "-"; done; echo
				echo "$file changed, running: $COMMANDONCHANGE"
				cursenorm
				echo
				xttitle ">> onchange running $COMMANDONCHANGE ($file changed)"
				highlightstderr $COMMANDONCHANGE
				cursecyan
				echo "Done."
				cursenorm
				[ "$DESENSITIZE" ] && sleep 2 && touch "$COMPFILE"
				xttitle "## onchange watching $FILES ($file changed last)"
				# break
			fi
		done
	fi
done
jdeltmp "$COMPFILE"
