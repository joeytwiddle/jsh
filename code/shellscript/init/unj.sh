## Should unj deprecate jwhich?
## Note: Both are dangerous because if X calls unj X but unj X return the same X then infinite loop :-(

if test "$1" = "-quiet"
then shift; UNJ_QUIET=true
fi
PROG="$1"
shift
REALPROG=`jwhich "$PROG"`
if test "$REALPROG"
then
	"$REALPROG" "$@"
else
	if test ! "$UNJ_QUIET"
	then
		INJ=`which "$PROG"`
		if test "$INJ"
		then echo "unj: $PROG exists in jsh but not outside it"
		else echo "unj: $PROG does not exist in jsh or in your PATH"
		fi
	fi
	exit 1
fi
