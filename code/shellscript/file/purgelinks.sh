if test "x$@" = "x"; then
	LOOK="."
else
	LOOK="$@"
fi

find "$LOOK" -type l | sed "s/^/rm /"
