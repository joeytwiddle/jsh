#!/bin/sh
ARGS="$*";
if test "x$ARGS" = "x"; then
  ARGS="vague"
fi
# X=1;
X=$$;
while test -f "$JPATH/tmp/$ARGS.$X.tmp"; do
  # X=$(($X+1));
  X=`eval $X+1`;
done
touch "$JPATH/tmp/$ARGS.$X.tmp"
echo "$JPATH/tmp/$ARGS.$X.tmp"
