NOTAR=
if test "$1" = "-notar"
then
	NOTAR=true
	shift
fi

if test "$1" = "-test"
then
	TARCOM="tz"
	shift
else
	TARCOM="xz"
fi

DIR="$1"
FILE="$DIR.tgz.encrypted"

test ! -f "$FILE" &&
	echo "decryptdir: $FILE does not exist!" &&
	exit 1

gpg --decrypt "$FILE" |
if test "$NOTAR"
then
	cat > "$FILE.decrypted"
else
	tar $TARCOM
fi &&

mv "$FILE" "$FILE.prev"
