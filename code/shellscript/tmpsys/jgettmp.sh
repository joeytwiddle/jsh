#!/bin/sh
ARGS=`printf "$*" | tr -d "\n" | tr " /" "_-"`
if test "x$ARGS" = "x"; then
  ARGS="$$"
fi
# X=1;
X=0;
while test -f "$JPATH/tmp/$ARGS.$X.tmp"; do
  # X=$(($X+1));
  X=`expr "$X" + 1`;
done
touch "$JPATH/tmp/$ARGS.$X.tmp"
echo "$JPATH/tmp/$ARGS.$X.tmp"
