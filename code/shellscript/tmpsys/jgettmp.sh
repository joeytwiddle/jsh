#!/bin/sh
## Gives you a temporary file you can use in your scripts.
# eg: TMPFILE=`jgettmp`
#     LOGFILE=`jgettmp my_log`
## Can be used without quotes, eg. $TMPFILE (ie. guaranteed not to contain spaces.)
## Actually JPATH does not guarantee that (maybe should!)
## NOTE: You should clear your temp files after use with: jdeltmp $TMPFILE
## Automatic clearing has not yet been implemented.

## debianutils >= 1.6 provides tempfile

### TODO: Policy questions:
## Should we put a default timeout on each file?
## Should we delete all files at jsh boot (what if another jsh is using same fs?)
## Should jsh boot clear all tmp files older than 1 day?  <-- my favourite
## What if the computer's date is wrong?!

## Choosing suitable top tmp directory has been abstracted out (at cost!) for memoing (boris)
. jgettmpdir -top

if test ! "$TOPTMP"
then error "$0: no TOPTMP"; exit 1
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
