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

# Diff works badly if not sorted
preparefordiff () {
	sort -k 3 "$TMPONE" > "$TMPONE.sorted"
	sort -k 3 "$TMPTWO" > "$TMPTWO.sorted"
	TMPONE="$TMPONE.sorted"
	TMPTWO="$TMPTWO.sorted";
}

ssh -l "$RUSER" "$RHOST" "$REMOTECOM" > "$TMPTWO"

find "$LOCAL" $FINDOPTS | sh -c "$CKSUMCOM" > "$TMPONE"

# Try to use (g)vimdiff or jfc if available
if which gvimdiff > /dev/null; then
	DIFFCOM=gvimdiff
	preparefordiff
elif which vimdiff > /dev/null; then
	DIFFCOM=vimdiff
	preparefordiff
elif which jfc > /dev/null; then
	DIFFCOM=jfc
elif which diff > /dev/null; then
	DIFFCOM=diff
	preparefordiff
else
	echo "Couldn't find vimdiff, jfc or diff!"
	echo "Files are in $TMPONE and $TMPTWO."
	exit 1
fi

# Removing cksum columns for the different diff-ers:
# ( jfc "$TMPONE" "$TMPTWO" | ( takecols 5 || cat ) ) || ( diff "$TMPONE" "$TMPTWO" | ( takecols 1 4 || cat ) )

"$DIFFCOM" "$TMPONE" "$TMPTWO"
