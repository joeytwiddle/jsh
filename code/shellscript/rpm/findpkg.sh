if test "$1" = ""; then
  echo "findpkg [-all] <part-of-package-name>"
  exit 1
fi

if test "$1" = "-all"; then
  ARGS="$2"
else
  ARGS="$1" # Could | grep -v "no description available"
fi

# use dlocate if it's available
BIN=`jwhich dlocate`
if test ! -x "$BIN"; then
  BIN=`jwhich dpkg`
  ARGS="*$ARGS*"
fi

# extend columns in order to show full package name and description
COM="env COLUMNS=184 $BIN -l $ARGS"

# echo "$COM"

$COM | if test ! "$1" = "-all"; then
  grep -v "no description available"
fi

# dpkg -l "*$**" | egrep -v "^?n"
# dpkg -l "*$**" | grep "^[hi]"
