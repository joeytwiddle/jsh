## This script checks folder size/date before and after running mutt.
## If there was a change, it prompts you to remove mbox.* files,
## which (for Evolution at least) are (now out of date) index files
## which should be regenerated.

## TODO: Would be quicker to touch a file beforehand, and do a find -newer afterwards.

export FINDDIR="$HOME/evolution/local/"

dofind() {
	find "$FINDDIR" -name mbox |
	while read X; do
		ls -ld "$X"
	done
}

TMPFILE=`jgettmp "evolution-b4-mutt"`
dofind > "$TMPFILE" &

`jwhich mutt` "$@"

TMPFILE2=`jgettmp "evolution-b4-mutt"`

dofind > "$TMPFILE2"
MBSCHANGED=`
jfcsh "$TMPFILE" "$TMPFILE2" |
sed "s+^[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*++"
`

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
