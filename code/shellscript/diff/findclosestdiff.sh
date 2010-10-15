#!/bin/sh
if test "$1" = ""; then
	echo "findclosestdiff <file> [<files_to_diff_against>]"
	exit 1
fi

FILE="$1"
shift

if test "$2" = ""; then
	TESTFILES=*
else
	TESTFILES="$@"
fi

BESTCOUNT=999999999
BESTFILE=ERROR

for TESTFILE in $TESTFILES; do
	if test ! "$TESTFILE" = "$FILE"; then
		COUNT=`jfcsh -bothways "$FILE" "$TESTFILE" | countlines`
		echo "$COUNT	$TESTFILE"
		if test "$COUNT" -lt "$BESTCOUNT"; then
			BESTCOUNT=$COUNT
			BESTFILE="$TESTFILE"
		fi
	fi
done

echo

echo "$BESTFILE differs by $BESTCOUNT lines:"
jfcsh -bothways "$FILE" "$BESTFILE" | more
