WEBSRCH=
while test ! "$2" = ""; do
	case "$1" in
		-web)
			WEBSRCH=true
		;;
		*)
			echo "$1: invalid argument"
			exit 1
		;;
	esac
	shift
done
SEARCH="$1"

if test $WEBSRCH; then
	PAGE="http://packages.debian.org/cgi-bin/search_contents.pl?word=$SEARCH&case=insensitive&version=testing&directories=yes"
	if xisrunning; then
		browse "$PAGE"
		# newwin lynx "$PAGE"
	else
		lynx "$PAGE" &
	fi
fi

# use dlocate if it's available
BIN=`jwhich dlocate`
if test ! -x "$BIN"; then
  BIN=`jwhich dpkg`
fi

$BIN -S "$SEARCH" | sed "s/^/"`cursecyan`"/;s/:/"`cursenorm`":/"
