DIR="$1"
FILE="$DIR.tgz.encrypted"

test ! -f "$FILE" &&
	echo "decryptdir: $FILE does not exist!" &&
	exit 1

test "$2" = "-test" &&
	TARCOM="tz" ||
	TARCOM="xz"

gpg --decrypt "$FILE" |
tar $TARCOM

mv "$FILE" "$FILE.old"
