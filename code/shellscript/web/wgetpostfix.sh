#!/bin/sh
# This was needed for wget version 1.8.1
# after mirroring with: wget -o fredart.log -p -m -k "http://www.fredart.com/"

# I also found some absolute links to the same site!
# But this may have been an incompleted download thus -k had not yet taken effect.

if test "$1" = ""; then
	echo "wgetpostfix <directory>"
	echo "  will fix browser problems with \? and &"
	echo "  by renaming files and replacing links in files."
	exit 1
fi

DIR="$1"

NEEDRENAMING=`find "$DIR" -type f | grep "\?"`

echo "$NEEDRENAMING" |
while read FILE; do

	# Take tail of URL (local links do not provide head)
	LINK=`echo "$FILE" | afterlast "/"`

	# Escape \? for search sedstring:
	# SEDLINK=`echo "$LINK" | sed 's|\?|\\\?|g'`
	SEDLINK=`echo "$LINK" | sed 's|?|\\?|g;s|\&|\&amp;|g'`
	GREPLINK=`echo "$LINK" | sed 's|\&|\&amp;|g'`
	# Desired link and filename:
	DESTSTR=`echo "$LINK" | sed 's|?|_q_|g;s|\&|_a_|g'`".html"
	DESTFILE=`echo "$FILE" | sed 's|?|_q_|g;s|\&|_a_|g'`".html"

	echo "file    $FILE"
	echo "renfile $DESTFILE"
	echo "link    $LINK"
	echo "sedstr  $SEDLINK"
	echo "repstr  $DESTSTR"
	echo

	# For all files containing link
	echo greplist -r "$GREPLINK" "$DIR"
	LIST=`greplist -r "$GREPLINK" "$DIR"`
	# echo
	# echo "List:"
	# echo "$LIST"
	# echo "end list."
	echo "$LIST" | countlines
	echo "$LIST" |
	while read FILETOCHANGE; do
		echo "change: >$FILETOCHANGE<"
		# Replace link value
		echo sedreplace -nobackup "$SEDLINK" "$DESTSTR" "$FILETOCHANGE"
		sedreplace -nobackup "$SEDLINK" "$DESTSTR" "$FILETOCHANGE"
	done

	# Then rename the actual file
	echo mv "$FILE" "$DESTFILE"
	mv "$FILE" "$DESTFILE"

	echo

done
