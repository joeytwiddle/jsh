PROG="$1"
shift
REALPROG=`jwhich "$PROG"`
if test "$REALPROG"
then
	"$REALPROG" "$@"
else
	INJ=`which "$PROG"`
	if test "$INJ"
	then
		echo "unj: $PROG does not exist outside jsh"
	else
		echo "unj: $PROG does not exist in or out of jsh"
	fi
	exit 1
fi
