#!/bin/sh
## This script checks folder size/date before and after running mutt.
## If there was a change, it prompts you to remove mbox.* files,
## which (for Evolution at least) are (now out of date) index files
## which should be regenerated.

## TODO: Would be quicker to touch a file beforehand, and do a find -newer afterwards.

export FINDDIR="$HOME/evolution/local/"

TMPFILE=`jgettmp "evolution-b4-mutt"`
touch "$TMPFILE" # probably already happened anyway

if test "$*" || test ! -f "$HOME/Mail/incoming"
then unj mutt "$@"
else unj mutt -f "$HOME/Mail/incoming"
fi

if test -d "$FINDDIR"
then
	MBSCHANGED=` find "$FINDDIR" -newer "$TMPFILE" `
fi

jdeltmp $TMPFILE

if test ! "$MBSCHANGED" = ""; then
	echo "The following mailboxes were changed:"
	cursegreen
	echo "$MBSCHANGED" |
	sed "s=$FINDDIR==" |
	sed "s=/subfolders==g"
	cursenorm
	echo "<Enter> to delete index files, or Ctrl+C to abort."
	read ANYKEY
	echo "$MBSCHANGED" |
	while read X; do
		ls -d $X.* 2>/dev/null |
		while read Y; do del "$Y"; done
		# sed 's+^+rm \"+;s=$=\"='
	done
fi
