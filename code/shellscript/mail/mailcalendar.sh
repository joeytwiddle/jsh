TOTAL=`
echo "q" | mail -f /tmp/mbox |
(
	read HEADER
	read FOLDER TOTAL messages NUMNEW new NUMUNREAD unread
	cat > /dev/null
	echo "$TOTAL"
)
`

	MONTHLIST="January February March April May June July August September October November December"
	# MONTHLISTRE="("`echo "$MONTHLIST" | tr " " "\n" | sed "p;s/\(...\).*/\1/" | tr "\n" "|"`"[01]?[0-9])"
	MONTHLISTRE="("`echo "$MONTHLIST" | tr " " "\n" | sed "p;s/\(...\).*/\1/" | tr "\n" "|" | sed "s/|$/)/"`
	NUMPOST="((st|nd|rd|th)( of|)|)"
	echo "$MONTHLISTRE"

for X in `seq 1 $TOTAL`; do

	FOUND=`

	echo "$X" | mail -f /tmp/mbox |

	# sed '
		# s+
		# d
	# '
	
	# awk '
		# /[0-3]?[0-9] September/ { print "\1" $0 }
	# '
	
	# awk -v"RS=[0-3]?[0-9] September" '{print RT}'

	fromstring "" |

	perl -n -e "
		/([0-3][0-9])$NUMPOST $MONTHLISTRE( ([0-9]*)|)/ && "'
			print("$_") &&
			print("$1/$5/$7\n\n");
		'

	`

	if test "$FOUND" = ""; then
		echo "No date found in $X"
	else
		echo "$FOUND"
	fi

done
