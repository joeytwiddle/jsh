#!/bin/sh
if test "$1" = ""; then
  echo "findpkg [-all] [-web] [-big] <part-of-package-name>"
  exit 1
fi

## Somehow the values set in the while loop get preserved by the variables, even with /bin/sh above.
## So what's the problem with variables in while loops?  Mabe its only when piping?!
SHOWALL=
WEBSRCH=
HEAD=
while test ! "$2" = ""; do
	case "$1" in
		-all)
			SHOWALL=true
		;;
		-web)
			WEBSRCH=true
		;;
		-big)
			HEAD="env COLUMNS=184"
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
	# browse "http://packages.debian.org/cgi-bin/search_packages.pl?keywords=$SEARCH&version=all&searchon=all&subword=1&release=all" &
	if xisrunning; then
	newwin lynx "http://packages.debian.org/cgi-bin/search_packages.pl?keywords=$SEARCH&version=all&searchon=all&subword=1&release=all" &
	else
	lynx "http://packages.debian.org/cgi-bin/search_packages.pl?keywords=$SEARCH&version=all&searchon=all&subword=1&release=all" &
	fi
fi

# use dlocate if it's available
BIN=`jwhich dlocate`
SEARCHEXP="$SEARCH"
if test ! -x "$BIN"; then
  BIN=`jwhich dpkg`
  SEARCHEXP="*$SEARCH*"
fi

# extend columns in order to show full package name and description
$HEAD $BIN -l "$SEARCHEXP" |
if test $SHOWALL; then
  cat
else
  grep -v "no description available"
fi | highlight "$SEARCH"

# dpkg -l "*$@*" | egrep -v "^?n"
# dpkg -l "*$@*" | grep "^[hi]"
