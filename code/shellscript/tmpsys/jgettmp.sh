#!/bin/sh
## Gives you a temporary file you can use without quotes, eg. $TMPFILE
## Actually JPATH does not guarantee that (maybe should!)

TOPTMP="$JPATH/tmp"
if test $JTMPLOCAL && test -w .; then
	# Note we don't use $PWD because might break * below
	TOPTMP="/tmp"
fi

# Neaten arguments (to string not needings ""s *)
# printf "$@" causes error if no args!
ARGS=`printf "$*" | tr -d "\n" | tr " /" "_-"`
if test "x$ARGS" = "x"; then
  ARGS="$$"
fi

# If already exists, choose a larger ver number!
X=0;
TMPFILE="$TOPTMP/$ARGS.tmp"
while test -f "$TMPFILE"; do
  # X=$(($X+1));
  X=`expr "$X" + 1`;
  TMPFILE="$TOPTMP/$ARGS.$X.tmp"
done

touch "$TMPFILE" &&
chmod go-rwx "$TMPFILE" || exit 1
echo "$TMPFILE"
