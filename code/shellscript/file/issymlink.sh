RES=`find "$1" -type l`
test "$RES" = "$1"
exit

## Another method:
if test -e "$1" && test ! ""`justlinks "$1"` = ""; then
	exit 0
else
	exit 1
fi
