# use dlocate if it's available
BIN=`jwhich dlocate`
if test ! -x "$BIN"; then
  BIN=`jwhich dpkg`
fi

$BIN -S "$@" | sed "s/^/"`cursecyan`"/;s/:/"`cursenorm`":/"
