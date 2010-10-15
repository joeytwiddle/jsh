#!/bin/sh
for FILE
do

	TMPFILE=`jgettmp "$FILE"`

	cat "$FILE" | sort > "$TMPFILE" &&
	mv -f "$TMPFILE" "$FILE"

	jdeltmp "$TMPFILE"

done
