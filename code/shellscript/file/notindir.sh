# Intended as supplement to find:
# eg. find . <-condition>.. | notindir <dir>..

. importshfn notindir

if test ! "$*" = ""; then
	X="$1"
	shift
	grep -v "/$X/" | notindir "$@"
else
	cat
fi
