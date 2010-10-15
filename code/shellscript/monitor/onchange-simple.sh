#!/bin/sh
# Still depends on Unix diff!

TMPFILE=/tmp/onchange.tmp

"$@" > $TMPFILE

while true; do

	mv $TMPFILE $TMPFILE.old
	sleep 1

	"$@" > $TMPFILE

	cmp $TMPFILE.old $TMPFILE > /dev/null ||
	diff $TMPFILE.old $TMPFILE |
	grep "^\(<\|>\)"

done
