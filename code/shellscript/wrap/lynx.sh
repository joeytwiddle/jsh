ARGS="$@";
if test "x$ARGS" = "x"; then
  # ARGS="file://$JPATH/org/jumpgate.html";
  ARGS="http://hwi.ath.cx/jumpgate.html";
fi
`jwhich lynx` $ARGS
