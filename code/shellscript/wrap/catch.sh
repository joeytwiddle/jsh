## TODO: Pass "$?" out in a way that works!  (Eg. tmp file.)
(
	"$@" 2>&1
	export CAUGHTERR="$?"
) | more
exit $CAUGHTERR
