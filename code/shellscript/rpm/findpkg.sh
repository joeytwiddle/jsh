if test "$1" = ""; then
  echo "findpkg [-all] <part-of-package-name>"
  exit 1
fi

if test "$1" = "-all"; then
  SEARCH="$2"
else
  SEARCH="$1" # Could | grep -v "no description available"
fi

# browse "http://packages.debian.org/cgi-bin/search_packages.pl?keywords=$SEARCH&version=all&searchon=all&subword=1&release=all" &
newwin lynx "http://packages.debian.org/cgi-bin/search_packages.pl?keywords=$SEARCH&version=all&searchon=all&subword=1&release=all" &

# use dlocate if it's available
BIN=`jwhich dlocate`
SEARCHEXP="$SEARCH"
if test ! -x "$BIN"; then
  BIN=`jwhich dpkg`
  SEARCHEXP="*$SEARCH*"
fi

# extend columns in order to show full package name and description
env COLUMNS=184 $BIN -l "$SEARCHEXP" |
if test "$1" = "-all"; then
  cat
else
  grep -v "no description available"
fi | highlight "$SEARCH"

# dpkg -l "*$**" | egrep -v "^?n"
# dpkg -l "*$**" | grep "^[hi]"
