#!/bin/sh
SEARCHDIR="$1"

grep "$SEARCHDIR" ~/.dirhistory | tail -n 4
cursegreen ; echo "$PWD" ; cursenorm
grep "$SEARCHDIR" ~/.dirhistory | head -n 3
exit



TMPF=`jgettmp`

awkdrop 1 $HOME/.dirhistory | grep "$1" > $TMPF

(
seq 4 -1 1 | tr " " "\n" | sed "s/\(.*\)/"`cursegreen`"\b\1 /" | splicewith tail -4 $TMPF
echo `cursecyan``cursebold`"You are here:"`cursegreen`" $PWD"
seq 1 4 | tr " " "\n" | sed "s/\(.*\)/"`cursegreen`"\f\1 /" | splicewith head -4 $TMPF
) |
if test "$1" = ""; then cat; else highlight "$1"; fi |
sed "s+/+"`cursegreen`"/"`cursenorm`"+g"

jdeltmp $TMPF
