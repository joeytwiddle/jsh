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
	mv "$TMPFILE" "$FILE"
done
