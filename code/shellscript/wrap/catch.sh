#!/bin/sh
export TMPFILE=`jgettmp caught-err`

(
	# "$@" 2>&1
	# eval "$@" 2>&1

	# When using catch, try to preserve pretty colors
	export COLOR=always
	export FORCE_COLOR=1
	export NPM_CONFIG_COLOR=always

	highlightstderr "$@" 2>&1
	echo "$?" > "$TMPFILE"
) | less -RX

#script -q /dev/null "$@" 2>&1 | less -RX

CAUGHTERR=`cat "$TMPFILE"`
jdeltmp "$TMPFILE"

if test "$CAUGHTERR" != "" && test "$CAUGHTERR" != "0"; then
	cursered
	cursebold
	echo "Exited with error $CAUGHTERR" >&2
	cursenorm
fi

exit $CAUGHTERR
