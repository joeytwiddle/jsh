#!/bin/sh

TOPTMP="$JPATH/tmp"
if test $JTMPLOCAL && test -w .; then
	# Note cos not use $PWD because might break * below
	TOPTMP="."
fi

# Neaten arguments (to string not needings ""s *)
# printf "$@" causes error if no args!
ARGS=`printf "$*" | tr -d "\n" | tr " /" "_-"`
if test "x$ARGS" = "x"; then
  ARGS="$$"
fi

# If already exists, choose a larger ver number!
X=0;
while test -f "$TOPTMP/$ARGS.$X.tmp"; do
  # X=$(($X+1));
  X=`expr "$X" + 1`;
done

touch "$TOPTMP/$ARGS.$X.tmp"
echo "$TOPTMP/$ARGS.$X.tmp"
