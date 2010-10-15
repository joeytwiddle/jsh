#!/bin/sh
INFG=""
if test "$1" = -fg
then INFG=true; shift
fi

(
  echo 'echo "Enter root passwd to perform:"'
  echo 'echo "'"$@"'"'
  echo 'su root -c $JPATH/tmp/sudo2.tmp'
  echo 'sleep 2'
) > $JPATH/tmp/sudo.tmp &&

echo "$@" > $JPATH/tmp/sudo2.tmp &&
chmod u+x $JPATH/tmp/sudo.tmp $JPATH/tmp/sudo2.tmp &&
if xisrunning && test ! "$INFG"
then newwin $JPATH/tmp/sudo.tmp
else $JPATH/tmp/sudo.tmp
fi
'rm' $JPATH/tmp/sudo.tmp
