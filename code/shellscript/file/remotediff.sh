if test "$1" = "" -o "$2" = ""; then
	echo "remotediff <local-dir> <user>@<host>:<remote-dir>"
	exit 1
fi

LOCAL="$1"
REMOTESTRING="$2"

RUSER=`echo "$REMOTESTRING" | sed "s/@.*//"`
RHOST=`echo "$REMOTESTRING" | sed "s/.*@//" | sed "s/:.*//"`
RDIR=`echo "$REMOTESTRING" | sed "s/.*://"`

TMPONE="/tmp/local.cksum"
TMPTWO="/tmp/remote.cksum"

FINDOPTS="-type f"

CKSUMCOM='while read X; do cksum "$X"; done'

REMOTECOM='find "'"$RDIR"'" '"$FINDOPTS"' | '"$CKSUMCOM"

ssh -l "$RUSER" "$RHOST" "$REMOTECOM" > "$TMPTWO"

find "$LOCAL" $FINDOPTS | sh -c "$CKSUMCOM" > "$TMPONE"

# Try to use jfc if available
if jfc -h > /dev/null; then
	DIFFCOM=jfc
else
	DIFFCOM=diff
	# Diff works badly if not sorted
	sort "$TMPONE" > "$TMPONE.sorted"
	sort "$TMPTWO" > "$TMPTWO.sorted"
	TMPONE="$TMPONE.sorted"
	TMPTWO="$TMPTWO.sorted"
fi

# Removing cksum columns for the different diff-ers:
# ( jfc "$TMPONE" "$TMPTWO" | ( takecols 3 || cat ) ) || ( diff "$TMPONE" "$TMPTWO" | ( takecols 1 4 || cat ) )

"$DIFFCOM" "$TMPONE" "$TMPTWO"
