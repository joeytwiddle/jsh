#!/bin/sh
SEARCHDIR="$1"

(
#cursegrey
fgrep "$SEARCHDIR" ~/.dirhistory | tail -n 5
curseyellow ; cursebold ; echo "$PWD" ; cursenorm
#cursegrey
fgrep "$SEARCHDIR" ~/.dirhistory | head -n 3
) | sed 's+$+/+'
exit



TMPF=`jgettmp`

awkdrop 1 $HOME/.dirhistory | fgrep "$SEARCHDIR" > $TMPF

(
seq 4 -1 1 | tr " " "\n" | sed "s/\(.*\)/"`cursegreen`"\b\1 /" | splicewith tail -4 $TMPF
echo `cursecyan``cursebold`"You are here:"`cursegreen`" $PWD"
seq 1 4 | tr " " "\n" | sed "s/\(.*\)/"`cursegreen`"\f\1 /" | splicewith head -4 $TMPF
) |
if test "$1" = ""; then cat; else highlight "$1"; fi |
sed "s+/+"`cursegreen`"/"`cursenorm`"+g"

jdeltmp $TMPF
