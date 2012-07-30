## indirdo <dir> <cmd>..
##   goes to dir and runs cmd, but does not change cwd after it exits.
##   Also makes the operation atomic, so no need for a ;
(
	cd "$1" || exit 7
	shift
	"$@"
)
