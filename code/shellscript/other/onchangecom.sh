#!/bin/sh
# Todo: Make it work on multiple files

# This is OK on Linux but not Unix:
# function littletest() {
#   newer "$file" "$COMPFILE"
# }

if test "$1" = "" -o "$2" = ""; then
  echo 'onchangecom "<test-command>" [do] "<command>"'
  echo '  When the stdout on onchangecom changes, command is executed.'
  # NO!  echo '  If you are really cunning, you could use "\$file" in your command!'
  exit 1
fi

TESTCOMMAND="$1"
COMMANDONCHANGE="$2 $3 $4 $5 $6 $7 $8 $9"
if test "$2" = "do"; then
  COMMANDONCHANGE="$3 $4 $5 $6 $7 $8 $9"
fi
COMPFILEA="$JPATH/tmp/onchangecoma.tmp"
COMPFILEB="$JPATH/tmp/onchangecomb.tmp"
$TESTCOMMAND > $COMPFILEA
while [ "true" = "true" ]; do
  sleep 1
  $TESTCOMMAND > $COMPFILEB
  if jfc silent "$COMPFILEA" "$COMPFILEB"; then
    echo "$TESTCOMMAND changed, running: $COMMANDONCHANGE"
    jfc "$COMPFILEA" "$COMPFILEB"
    $COMMANDONCHANGE
  fi
  cp -f $COMPFILEB $COMPFILEA
done
