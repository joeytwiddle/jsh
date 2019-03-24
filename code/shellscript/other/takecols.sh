#!/bin/sh

## See also: cut
#
# Instead of 'takecols 1 2 3' we could do 'cut -f 1,2,3'.
#
# (Maybe after a: sed 's+ +\t+g' | tr -s '\t'  This is needed for example
# after 'diffgraph $xs' because it has a mix of tabs and spaces, but cut only
# accepts one delimiter).

## No arguments => show all
## TODO: sometimes the tr -s ' ' effect is undesirable.
# jsh-depends: 
if test "$1" = ""; then
  cat
else
  ## Untested alternative:
  # CUTSTR=`echo "$@" | tr " " ","`
  # cut -d ' ' -f "$CUTSTR"
  FS=" "
  THECOLS=""
  FIRST="$1"
  for x in "$@"; do
    if test ! "$x" = "$FIRST"; then
      THECOLS="$THECOLS\" \""
    fi
    THECOLS="$THECOLS\$$x"
  done
  awk ' { print '"$THECOLS"' ; fflush() } '
fi
