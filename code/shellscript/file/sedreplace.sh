if test "$3" = ""; then
	echo "sedreplace [-nobackup] <from_string> <to_string> <files>"
	exit 1
fi

DOBACKUP=true
if test "$1" = "-nobackup"; then
	shift
	DOBACKUP=
fi
FROM="$1"
TO="$2"
shift
shift

TMPFILE=`jgettmp sedreplace$$`

for FILE do
	cat "$FILE" | sed "s|$FROM|$TO|g" > "$TMPFILE"
	if test $DOBACKUP; then
		cp "$FILE" "$FILE.b4sr"
	fi
	mv "$TMPFILE" "$FILE" ||
		echo "sedreplace: error moving \"$TMPFILE\" over \"$FILE\"" >> /dev/stderr
	if cmp "$FILE" "$FILE.b4sr" > /dev/null; then
		echo "sedreplace: no changes made to $FILE" >> /dev/stderr
	fi
done
