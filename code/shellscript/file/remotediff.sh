LOCAL="$1"
REMOTESTRING="$2"

RUSER=`echo "$REMOTESTRING" | sed "s/@.*//"`
RHOST=`echo "$REMOTESTRING" | sed "s/.*@//" | sed "s/:.*//"`
RDIR=`echo "$REMOTESTRING" | sed "s/.*://"`

TMPONE="/tmp/1.cksum"
TMPTWO="/tmp/2.cksum"

FINDOPTS="-type f"

DOCKSUM='while read X; do cksum "$X"; done'

COM='find "'"$RDIR"'" '"$FINDOPTS"' | '"$DOCKSUM"

ssh -l "$RUSER" "$RHOST" "$COM" > "$TMPTWO"

find "$LOCAL" $FINDOPTS | sh -c "$DOCKSUM" > "$TMPONE"

diff "$TMPONE" "$TMPTWO"
