#!/bin/sh
# If you do not yet have a public/private key pair, run: gpg --gen-key

NOTAR=
if [ "$1" = "-notar" ]
then
	NOTAR=true
	shift
fi

DIR="$1"
FILE="$DIR.tgz.encrypted"

[ -f "$FILE" ] && [ -z "$NOBACKUP" ] &&
cp "$FILE" "$FILE.bak"
# For when the above cp was a mv
#touch "$FILE"
#chmod 600 "$FILE"

NEWFILE="$FILE.tmp"
touch "$NEWFILE"
chmod 600 "$NEWFILE"

#[ -n "$WHICHKEY" ] || WHICHKEY=`gpg --list-keys | grep "^pub" | head -n 1 | dropcols 1 2 3`
[ -n "$WHICHKEY" ] || WHICHKEY=`gpg --list-keys --with-colons | grep "^pub:" | head -n 1 | tr : ' ' | takecols 5`

if [ -n "$NOTAR" ]
then cat "$DIR"
else tar cz "$DIR"
fi |
gpg $ENCDIR_GPGOPTS -r "$WHICHKEY" -e > "$NEWFILE"

if [ "$?" = 0 ]
then
	# If the compression succeeded, move the data into the correct place
	cat "$NEWFILE" > "$FILE" && rm -f "$NEWFILE"
else
	#rm -f "$NEWFILE" # Neater; cleans up the file if compression failed (usually means 0 length anyway).
	exit 1
fi
