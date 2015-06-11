#!/bin/bash
SEARCHDIR="$1"

(
paste -d ' ' <(seq 9 -1 1) <(grep "$SEARCHDIR" ~/.dirhistory | tail -n 9) | sed "s+^+`cursebold`+ ; s+ .*+`cursegreen`&/`cursenorm`+"
echo "0 `curseyellow;cursebold`$PWD`cursenorm`"
paste -d ' ' <(seq 1 3) <(grep "$SEARCHDIR" ~/.dirhistory | head -n 3) | sed "s+^+`cursebold`+ ; s+ .*+`cursegreen`&/`cursenorm`+"
)
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
