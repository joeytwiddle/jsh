#!/bin/sh
## Gives you a temporary file you can use in your scripts.
# eg: TMPFILE=`jgettmp`
#     LOGFILE=`jgettmp my_log`
## Can be used without quotes, eg. $TMPFILE (ie. guaranteed not to contain spaces.)
## Actually JPATH does not guarantee that (maybe should!)
## NOTE: You should clear your temp files after use with: jdeltmp $TMPFILE
## Automatic clearing has not yet been implemented.

### TODO: Policy questions:
## Should we put a default timeout on each file?
## Should we delete all files at jsh boot (what if another jsh is using same fs?)
## Should jsh boot clear all tmp files older than 1 day?  <-- my favourite
## What if the computer's date is wrong?!

TOPTMP="$JPATH/tmp"

# if test ! -w $TOPTMP || ( test "$JTMPLOCAL" && test -w . )
# then
	# # Note we don't use $PWD because might break * below
	# TOPTMP="/tmp"
# fi

if test ! -w "$TOPTMP"
then
	TOPTMP="/tmp/jsh-tempdir-for-$USER"
	## Mega-secure, if it exists but isn't writeable:
	while test -e $TOPTMP && test ! -w $TOPTMP
	do TOPTMP="$TOPTMP"_
	done
	if test ! -e $TOPTMP
	then mkdir -p $TOPTMP
	     echo "Created a temporary directory for you: $TOPTMP"
	fi
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
