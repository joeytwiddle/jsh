#!/bin/sh
# jsh-depends: jgettmpdir

## Gives you a temporary file you can use in your scripts.
# eg: TMPFILE=`jgettmp`
#     LOGFILE=`jgettmp my_log`
## The filename returned can be used without quotes, eg. $TMPFILE (ie. it's guaranteed not to contain spaces.)
## Actually JPATH does not guarantee that (but maybe it should)
## NOTE: You should clear your temp files after use with: jdeltmp $TMPFILE
## Automatic clearing has not yet been implemented.

## RECOMMEND:
## debianutils >= 1.6 provides tempfile
## We could use this.

### TODO: Policy questions:
## Should we put a default timeout on each file?
## Should we delete all files at jsh boot (what if another jsh is using same fs?)
## Should jsh boot clear all tmp files older than 1 day?  <-- my favourite
## What if the computer's date is wrong?!

## Choosing suitable top tmp directory has been abstracted out (at cost!) for memoing (boris)

test -w "$TOPTMP" || . jgettmpdir -top || exit 1

# Neaten arguments (to string not needings ""s *)
ARGS=`printf "%s" "$*" | tr -d "\n" | tr " /" "_-"`
if test "x$ARGS" = "x"; then
  ARGS="$$"
fi

## Because we don't do any locking, I start tmpfile on $$ to avoid collision.
X=$$;
TMPFILE="$TOPTMP/$ARGS.$X.tmp"
while test -f "$TMPFILE" || test -d "$TMPFILE"; do
  # X=$(($X+1));
  # If already exists, choose a larger ver number!
  X=`expr "$X" + $$`; ## Much better at avoiding buildups.
  TMPFILE="$TOPTMP/$ARGS.$X.tmp"
done

touch "$TMPFILE" &&
chmod go-rwx "$TMPFILE" || exit 1
echo "$TMPFILE"
