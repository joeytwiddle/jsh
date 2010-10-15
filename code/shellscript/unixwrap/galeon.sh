#!/bin/sh
## Even without the crashfile removal, Galeon sometimes starts a new session instead of joining an existing one (notably when run from Evolution, different env because started from panel?)
CRASHFILE="$HOME/.galeon/session_crashed.xml"
if test -f "$CRASHFILE"; then
	echo "Galeon crash file present."
	CRASHLINES=`grep "url=" "$CRASHFILE" | countlines`
	if test "$CRASHLINES" -lt 2; then
		echo "Deleting because only 1 url."
		del "$CRASHFILE"
	fi
fi
`jwhich galeon` "$@"
