#!/bin/sh

TOPTMP="$JPATH/tmp"
if test $JTMPLOCAL && test -w .; then
	# Note cos not use $PWD because might break * below
	test -w . && TOPTMP="." || TOPTMP="/tmp"
	echo "jgettmp: Using $TOPTMP as temp dir" >> /dev/stderr
	echo "         because $JPATH/tmp is not writeable." >> /dev/stderr
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
