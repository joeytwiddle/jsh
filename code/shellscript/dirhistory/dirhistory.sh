SEARCHDIR="$1"

TMPF=`jgettmp`

awkdrop 1 $HOME/.dirhistory | grep "$1" > $TMPF

(
tail -4 $TMPF
echo `cursecyan``cursebold`"You are here:"`cursegrey`" $PWD"
head -4 $TMPF
) |
if test "$1" = ""; then cat; else highlight "$1"; fi |
sed "s+/+"`cursegrey`"/"`cursegreen`"+g"

jdeltmp $TMPF
