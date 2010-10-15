#!/bin/sh
USEDICT="$1"
TITLE="$2"

xttitle "$TITLE"

echo "1 _"
echo "2 /"
echo "3 v"
echo "4 \\"

( echo "$USEDICT" ; cat ) |
	( /usr/bin/cedictlookup -vd /usr/share/cedict ; kill $$ )

