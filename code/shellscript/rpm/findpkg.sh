if test "$1" = ""; then
  echo "findpkg [-all] <part-of-package-name>"
  exit 1
fi

# use dlocate if it's available
BIN=`jwhich dlocate`
if test ! -x "$BIN"; then
  BIN=`jwhich dpkg`
fi

# extend columns in order to show full package name and description
COM="env COLUMNS=184 $BIN -l"

if test "$1" = "-all"; then
  $COM "*$2*"
else
  $COM "*$1*" # | grep -v "no description available"
fi
# dpkg -l "*$**" | egrep -v "^?n"
# dpkg -l "*$**" | grep "^[hi]"

