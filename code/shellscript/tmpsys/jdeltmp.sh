#!/bin/bash

# jsh-depends: startswith jshwarn jgettmpdir

# TOPTMP="$JPATH/tmp"
# 
# # if test $JTMPLOCAL && test -w .; then
	# # TOPTMP="."
# # fi
# 
# if test ! -w "$TOPTMP"
# then
	# TOPTMP="/tmp/jsh-tempdir-for-$USER"
	# mkdir -p $TOPTMP
	# chmod go-rwx $TOPTMP
# fi

. jgettmpdir -top

for TMPFILE
do
  if startswith "$TMPFILE" "$TOPTMP" || startswith "$TMPFILE" "/tmp/" ||
     ( test "$TMPDIR" && startswith "$TMPFILE" "$TMPDIR" )
  then
    rm -rf "$TMPFILE"
    # mkdir -p $JPATH/trash/$TOPTMP
    # mv "$TMPFILE" $JPATH/trash/$TMPFILE
    # del "$TMPFILE" > /dev/null
  else
    jshwarn "jdeltmp: Since $TMPFILE does not start with $TOPTMP"
    jshwarn "jdeltmp:       $TMPFILE has not been deleted."
    exit 1
  fi
done
