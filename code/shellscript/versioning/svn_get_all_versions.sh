DIR="$1"

DESTDIR=temp

SVNURL=`cat "$DIR/.svn/entries" | grep "^[ ]*url=" | head -1 | sed 's+[^"]*"++;s+".*++'`

[ "$DIR" ] || exit 123
[ "$SVNURL" ] || exit 123
mkdir -p "$DESTDIR" || exit 124

memo svn log "$DIR" |
grep -A1 "^------------------------------------------------------------------------" |
grep -v "^-" | grep "^r" |

while read REVISION bar USER bar DATE TIME ZONE dateDayOW dateDayOM dateMon dateYear bar NUMLINES
do

	verbosely svn co -"$REVISION" "$SVNURL" "$DESTDIR" || exit 125
	mv "$DESTDIR" "old.$REVISION" || exit 126

done

