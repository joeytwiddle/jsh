#!/bin/sh

## For bash: hmmm still working on it
## For zsh: requires setopt FUNCTION_ARGZERO
## (turns out we were just luck with startj)
echo "jshstub: $SCRIPTNAME (" "$0" "|" "$@" "|" "$_" ")" >&2
set > /tmp/set.out
env > /tmp/env.out
history > /tmp/history.out
SCRIPTFILE="$0"
## note not yet absolute path
SCRIPTNAME=`basename "$SCRIPTFILE"`

## Goddammit I have that classic problem when bash source something!

## TODO: need a better check than this! (would need absolute path at least)
# TOOLDIR="$JPATH/tools"
# if test ! "`dirname "$SCRIPTFILE"`" = "$TOOLDIR"
# then
	# echo "jshstub: Aborting because $SCRIPTFILE is not in \$JPATH/tools" >&2
	# exit 1
# fi

if test "$SCRIPTNAME" = jshstub
then
	echo "jshstub: Refusing to retrieve another copy of jshstub!" >&2
	exit 1
fi

if test ! -L "$SCRIPTFILE"
then
	## If this script was sourced then $0 has filename but no path.  Try this path:
	if test -L "$JPATH/tools/$SCRIPTFILE"
	then
		SCRIPTFILE="$JPATH/tools/$SCRIPTFILE"
	else
		echo "jshstub: Aborting because $SCRIPTFILE is not a symlink!" >&2
		exit 1
	fi
fi

rm -f "$SCRIPTFILE"

wget "http://hwi.ath.cx/jshstubtools/$SCRIPTNAME" -O "$SCRIPTFILE" > /tmp/jshstub_wget.log

if test ! "$?" = 0
then
	echo "jshstub: Error: failed to retrieve http://hwi.ath.cx/jshstubtools/$SCRIPTNAME" >&2
	ln -s "$JPATH/tools/jshstub" "$SCRIPTFILE"
	exit 1
fi

chmod a+x "$SCRIPTFILE"

echo "jshstub: got script \"$SCRIPTNAME\" ok, now running $SCRIPTNAME $* ..." >&2

"$SCRIPTFILE" "$@"
