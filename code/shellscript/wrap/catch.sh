#!/bin/sh
export TMPFILE=`jgettmp caught-err`

(
	# "$@" 2>&1
	# eval "$@" 2>&1
	highlightstderr "$@" 2>&1
	echo "$?" > "$TMPFILE"
) | more

CAUGHTERR=`cat "$TMPFILE"`
jdeltmp "$TMPFILE"

if test "$CAUGHTERR" != "" && test "$CAUGHTERR" != "0"; then
	cursered
	cursebold
	echo "Exited with error $CAUGHTERR" >&2
	cursenorm
fi

exit $CAUGHTERR
