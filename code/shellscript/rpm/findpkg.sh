if test "$1" = ""; then
  echo "findpkg [ -all | -web ] <part-of-package-name>"
  exit 1
fi

SHOWALL=
WEBSRCH=
while test ! "$2" = ""; do
	case "$1" in
		-all)
			shift
			SHOWALL=true
			;;
		-web)
			shift
			WEBSRCH=true
			;;
		*)
			echo "$1: invalid argument"
			shift
			exit 1
	esac
done
SEARCH="$1"

if test $WEBSRCH; then
	# browse "http://packages.debian.org/cgi-bin/search_packages.pl?keywords=$SEARCH&version=all&searchon=all&subword=1&release=all" &
	newwin lynx "http://packages.debian.org/cgi-bin/search_packages.pl?keywords=$SEARCH&version=all&searchon=all&subword=1&release=all" &
fi

# use dlocate if it's available
BIN=`jwhich dlocate`
SEARCHEXP="$SEARCH"
if test ! -x "$BIN"; then
  BIN=`jwhich dpkg`
  SEARCHEXP="*$SEARCH*"
fi

# extend columns in order to show full package name and description
env COLUMNS=184 $BIN -l "$SEARCHEXP" |
if test $SHOWALL; then
  cat
else
  grep -v "no description available"
fi | highlight "$SEARCH"

# dpkg -l "*$**" | egrep -v "^?n"
# dpkg -l "*$**" | grep "^[hi]"
