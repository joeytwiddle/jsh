if test -e "$1" && test ! ""`justlinks "$1"` = ""; then
	exit 0
else
	exit 1
fi
