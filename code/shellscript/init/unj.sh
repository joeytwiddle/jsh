if test "$1" = "-quiet"
then shift; UNJ_QUIET=true
fi
PROG="$1"
shift
REALPROG=`jwhich -quiet "$PROG"`
if test "$REALPROG"
then
	"$REALPROG" "$@"
else
	if test ! "$UNJ_QUIET"
	then
		INJ=`which "$PROG"`
		if test "$INJ"
		then echo "unj: $PROG does not exist outside jsh"
		else echo "unj: $PROG does not exist in or out of jsh"
		fi
	fi
	exit 1
fi
