GROUPNAMEVER="$1"

cat /var/db/pkg/$GROUPNAMEVER/CONTENTS |
grep -v "^dir " |

while read TYPE FILE CKSUM LENGTH
do
	md5sum "$FILE"
	echo "$CKSUM  $FILE ($LENGTH)"
	echo
done
