cd /var/db/pkg

'ls' -d */* |

while read GROUPNAMEVER
do

	cat $GROUPNAMEVER/CONTENTS |
	grep -v "^dir " |

	grep "[^ ]* /etc/" |

	while read TYPE FILE MD5SUM SIZE
	do
		[ -f "$FILE" ] || continue
		EXPECTEDSUM="$MD5SUM  $FILE"
		GOTSUM=`md5sum "$FILE"`
		if [ "$EXPECTEDSUM" = "$GOTSUM" ]
		then
			echo "$FILE matches $GROUPNAMEVER"
		else
			echo "$FILE mismatches $GROUPNAMEVER"
		fi
	done

done
