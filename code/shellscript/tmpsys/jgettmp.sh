#!/bin/sh
## Gives you a temporary file you can use without quotes, eg. $TMPFILE
## Actually JPATH does not guarantee that (maybe should!)
### TODO: Policy questions:
## Should we put a default timeout on each file?
## Should we delete all files at jsh boot (what if another jsh is using same fs?)
## Should jsh boot clear all tmp files older than 1 day?  <-- my favourite
## What if the computer's date is wrong?!

TOPTMP="$JPATH/tmp"

if test ! -w $TOPTMP || ( test "$JTMPLOCAL" && test -w . )
then
	# Note we don't use $PWD because might break * below
	TOPTMP="/tmp"
fi

if test ! -w "$TOPTMP"
then
	TOPTMP=/tmp/$USER
	mkdir -p $TOPTMP
	chmod go-rwx $TOPTMP
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
while test -f "$TMPFILE" || test -d "$TMPFILE"; do
  # X=$(($X+1));
  X=`expr "$X" + 1`;
  TMPFILE="$TOPTMP/$ARGS.$X.tmp"
done

touch "$TMPFILE" &&
chmod go-rwx "$TMPFILE" || exit 1
echo "$TMPFILE"
