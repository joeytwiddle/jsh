if test "x$@" = "x"; then
  echo "check4duplicates [remove] <other-dir>"
  exit 1
fi

OTHER="$1";
REMOVE="false";
if test "$OTHER" = "remove"; then
  REMOVE="true";
  OTHER="$2";
fi

TOCHECK=`find . -type f`;

for X in $TOCHECK; do
  echo "$X"
  A=`filesize "$X"`
  B=`filesize "$OTHER/$X"`
  if test "x$A" = "x$B"; then
    if test ! "x" = "$Ax"; then
      echo "$A = $B .'. Files are the same!"
      if test "x$REMOVE" = "xtrue"; then
        'rm' -f "$X"
      fi
    fi
  fi
done
