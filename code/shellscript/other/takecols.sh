#!/bin/sh
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
  awk ' { print '"$THECOLS"' ; } '
fi
