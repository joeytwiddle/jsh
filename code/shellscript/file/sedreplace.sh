if test "$3" = ""; then
	echo "sedreplace <from_string> <to_string> <files>"
	exit 1
fi

FROM="$1"
TO="$2"
shift
shift

TMPFILE=`jgettmp $$`

for FILE do
	cat "$FILE" | sed "s|$FROM|$TO|g" > "$TMPFILE"
	cp "$FILE" "$FILE.b4sr"
	mv "$TMPFILE" "$FILE"
done
