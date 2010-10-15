#!/bin/sh
# Displays what needs to be done to remove all symlinks
# in current / specified directory.

if test "x$1" = "x"; then
	LOOK="."
else
	LOOK="$@"
fi

find "$LOOK" -type l |
	# I trust it:
	# sed 's/^/rm "/;s/$/"/'
	# But here's an ultra-confidence version:
	while read X; do
		echo "#   "`ls -dF --color "$X"`
		echo "rm '$X'"
	done
