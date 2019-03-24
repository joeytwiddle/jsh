#!/bin/bash

DB="$HOME/.kde/share/apps/amarok/collection.db"

function sql_string_escape () {
	## I escaped ' but it failed!
	## TODO: I haven't tested whether " escaping works - we don't have any in the database!
	echo -n "$1" |
	# sed "s+'+\\\\'+g"
	sed 's+"+\\\\"+g'
}

if [ -z "$1" ]
then FILE=$(SKIP_OSD=1 whatsplaying)
else FILE=
fi

for FILE in "$@" "$FILE"
do
	[ "$FILE" ] || continue

	## Strip off various leading folders to get the folder that amarok recognises

	# FILE=$(realpath "$FILE" 2>/dev/null)
	NFILE=$(realpath "$FILE" | sed 's+^/mnt/[^/]*/stuff/+/stuff/+' | sed 's+.*/share/torrents/+/stuff/share/torrents/+')
	[ "$NFILE" ] && FILE="$NFILE"
	# if [ ! -f "$FILE" ]
	# then
		# jshwarn "Skipping non-file: $FILE"
		# continue
	# fi

	SHORTFILE=$(echo "$FILE" | sed 's+^/mnt/[^/]*++')
	if [ -f "$SHORTFILE" ]
	then
		REALSHORTFILE=$(realpath "$SHORTFILE")
		if [ "$REALSHORTFILE" = "$FILE" ] && [ ! -d "$REALSHORTFILE" ]
		then FILE="$SHORTFILE"
		fi
	fi

	# URL=".$FILE" ## This is the key in the sqlite db
	# RATING=$(sqlite3 "$DB" "SELECT statistics.rating FROM statistics WHERE statistics.url=\"$(sql_string_escape "$URL")\"" | tr '\n' ',' | sed 's+,$++')
	# TAGS=$(sqlite3 "$DB" "SELECT labels.name FROM labels,tags_labels WHERE labels.id=tags_labels.labelid AND tags_labels.url=\"$(sql_string_escape "$URL")\"" | tr '\n' ' ')
	FNAME=$(basename "$FILE")
	escapedFNAME=$(sql_string_escape "$FNAME")
	RATING=$(sqlite3 "$DB" "SELECT AVG(statistics.rating) FROM statistics WHERE statistics.url LIKE \"%/${escapedFNAME}\" AND statistics.rating<>0" | tr '\n' ',' | sed 's+,$++')
	TAGS=$(sqlite3 "$DB" "SELECT DISTINCT labels.name FROM labels,tags_labels WHERE labels.id=tags_labels.labelid AND tags_labels.url LIKE \"%/${escapedFNAME}\"" | tr '\n' ' ')

	echo "$FILE"
	[ "$RATING" ] && echo "Rating: $RATING"
	[ "$TAGS" ] && echo "Tags: $TAGS"

done

