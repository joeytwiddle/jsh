if test -e "$@" && test ! ""`justlinks "$@"` = ""; then
	exit 0
else
	exit 1
fi
