if test "$3" = ""; then
	echo "sedreplace [-nobackup] [-changes] <from_string> <to_string> <files>"
	exit 1
fi

DOBACKUP=true
if test "$1" = "-nobackup"; then
	shift
	DOBACKUP=
fi
SHOWCHANGES=true
if test "$1" = "-changes"; then
	shift
	SHOWCHANGES=
fi
FROM="$1"
TO="$2"
shift
shift

TMPFILE=`jgettmp sedreplace$$`

for FILE do
	if test ! -w "$FILE"; then
		echo "sedreplace: $FILE not writeable" >> /dev/stderr
		break
	fi
	cat "$FILE" | sed "s|$FROM|$TO|g" > "$TMPFILE"
	chmod --reference="$FILE" "$TMPFILE"
	if test $DOBACKUP; then
		mv "$FILE" "$FILE.b4sr"
	fi
	mv "$TMPFILE" "$FILE" ||
		echo "sedreplace: error moving \"$TMPFILE\" over \"$FILE\"" >> /dev/stderr
	if test $SHOWCHANGES && cmp "$FILE" "$FILE.b4sr" > /dev/null; then
		echo "sedreplace: no changes made to $FILE" >> /dev/stderr
	fi
done
