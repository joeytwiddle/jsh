# Displays what needs to be done to remove all symlinks
# in current / specified directory.

if test "x$@" = "x"; then
	LOOK="."
else
	LOOK="$@"
fi

find "$LOOK" -type l | sed 's/^/rm "/;s/$/"/'
