if test "x$JWHICHOS" = "xunix"; then
  if test -e "$*"; then
    exit 0
  else
    exit 1
  fi
elif test "x$JWHICHOS" = "xlinux";
  
