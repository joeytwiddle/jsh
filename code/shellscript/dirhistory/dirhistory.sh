SEARCHDIR="$1"

TMPF=`jgettmp`

grep "$1" $HOME/.dirhistory > $TMPF

(
tail -4 $TMPF
echo "$PWD/  "`cursecyan``cursebold`"<-- You are here"`cursegrey`
head -4 $TMPF
) |
highlight "$1" |
sed "s+/+"`cursegreen`"/"`cursegrey`"+g"
