#!/bin/sh
TMPFILE=`jgettmp "$1"`

cat > $TMPFILE



## New faster method:

COUNT=1
LASTLINE="an impossible string which never occurs anywhere (or at least not as the first line in a file)"
cat "$TMPFILE" |
sort |
while IFS="" read LINE
do
	if [ "$LINE" = "$LASTLINE" ]
	then COUNT=$((COUNT+1))
	else
		echo "$COUNT	$LINE"
		COUNT=1
	fi
	LASTLINE="$LINE"
done

exit



## Old method:

cat $TMPFILE |

removeduplicatelines |

toregexp |

while IFS="" read LINE
do

	grep -c "^$LINE$" $TMPFILE | tr -d '\n'

	echo "	$LINE"

done |

sort -n -k 1

jdeltmp $TMPFILE
