SEARCHDIR="$1"

TMPF=`jgettmp`

awkdrop 1 $HOME/.dirhistory | grep "$1" > $TMPF

(
seq 4 1 | tr " " "\n" | sed "s/\(.*\)/"`cursegrey`"\b\1 /" | splicewith tail -4 $TMPF
echo `cursecyan``cursebold`"You are here:"`cursegrey`" $PWD"
seq 1 4 | tr " " "\n" | sed "s/\(.*\)/"`cursegrey`"\f\1 /" | splicewith head -4 $TMPF
) |
if test "$1" = ""; then cat; else highlight "$1"; fi |
sed "s+/+"`cursegrey`"/"`cursegreen`"+g"

jdeltmp $TMPF
