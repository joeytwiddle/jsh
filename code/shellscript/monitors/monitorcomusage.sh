#!/bin/sh
if test "$1" = ""; then
	echo
fi

MONPATH=`jgettmpdir monpath`

echo "$PATH" | tr ":" "\n" |
while read D
do
	cd "$D"
	'ls'
done |
while read F
do
	ln -s "$JPATH/tools/monitorcomusage" "$MONPATH/$F"
done

echo "export PATH=\"$MONPATH:\$PATH\""
