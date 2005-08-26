NOTAR=
if test "$1" = "-notar"
then
	NOTAR=true
	shift
fi

DIR="$1"
FILE="$DIR.tgz.encrypted"

test -f "$FILE" &&
mv "$FILE" "$FILE.bak"

touch "$FILE"
chmod 600 "$FILE"

[ "$WHICHKEY" ] || WHICHKEY=`gpg --list-keys | grep "^pub" | head -n 1 | dropcols 1 2 3`

if test "$NOTAR"
then
	cat "$DIR"
else
	tar cz "$DIR"
fi |

gpg -r "$WHICHKEY" -e > "$FILE"

if test ! "$?" = 0
then
	rm -f "$FILE" ## Neater; cleans up the file if compression failed (usually means 0 length anyway).
	exit 1
fi
