FILE="$1"

DESTDIR=temp

SVNURL=`cat "\`dirname \"$FILE\"\`"/.svn/entries | grep "^[ ]*url=" | head -1 | sed 's+[^"]*"++;s+".*++'`
SVNURL="$SVNURL/`filename \"$FILE\"`"

[ "$FILE" ] || exit 123
[ "$SVNURL" ] || exit 123
mkdir -p "$DESTDIR" || exit 124

memo svn log "$FILE" |
grep -A1 "^------------------------------------------------------------------------" |
grep -v "^-" | grep "^r" |

while read REVISION bar USER bar DATE TIME ZONE dateDayOW dateDayOM dateMon dateYear bar NUMLINES
do

	verbosely svn co -"$REVISION" "$SVNURL" "$DESTDIR"
	mv "$DESTDIR/`filename \"$FILE\"`" "$DESTDIR/`filename \"$FILE\"`.$REVISION"
	ls -l "$DESTDIR"

done

