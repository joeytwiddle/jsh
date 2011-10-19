#!/bin/sh
# This addition not documented,
# and not really needed since we have imageinfo
MULTIPLE=
if test "$1" = "-:"; then
	MULTIPLE=true
	shift
fi
if test ! "$2" = ""; then
	MULTIPLE=true
fi

for X
do
  if test $MULTIPLE; then
    printf "$X:	"
  fi
  # imageinfo "$X" | head -n 1 | after "$X " | beforefirst ' ' | beforefirst "+"
  # | tail -n 1 | beforefirst ' '
  # | takecols 2
  ## Not for tiff's :-(
  # imageinfo "$X" 2>&1 | grep -v "^$X=>" | head -n 1 | sed 's+.* \([1234567890]*x[1234567890]*\) .*+\1+'
  # imageinfo "$X" 2>&1 | grep "^$X=>" |
  imageinfo "$X" 2>&1 | # grep -o "[0-9]*x[0-9]*" | head -n 1 |
  sed 's|.* \([[:digit:]]*x[[:digit:]]*\)[+ ].*|\1|'
done
