ARGS="$@";
if test "x$ARGS" = "x"; then
  ARGS="file://$JPATH/org/jumpgate.html";
fi
`jwhich lynx` $ARGS
