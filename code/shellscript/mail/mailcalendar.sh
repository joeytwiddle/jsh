## TODO: doesn't recognise:
## 1:00pm Friday Feb. 15th, 2002. Room 4.01 Merchant Venturers Building
## (Wed 9th / 8pm / =A33/2

# cp "$HOME/evolution/local/A/subfolders/Calendar/mbox" /tmp/mbox
MBOX="/tmp/mbox"
MBOXOUT="$MBOX-done"

## Interface to /usr/bin/mail =)
maildo() {
	echo "$1" | /usr/bin/mail -N -f "$MBOX"
}

TOTAL=`
maildo "q" |
(
	read HEADER
	read FOLDER TOTAL messages NUMNEW new NUMUNREAD unread
	cat > /dev/null
	echo "$TOTAL"
)
`

WEEKLIST="Monday Tuesday Wednesday Thursday Friday Saturday"
MONTHLIST="January February March April May June July August September October November December"
# MONTHLISTRE="("`echo "$MONTHLIST" | tr " " "\n" | sed "p;s/\(...\).*/\1/" | tr "\n" "|"`"[01]?[0-9])"
MONTHLISTRE="("`echo "$MONTHLIST" | tr " " "\n" | sed "p;s/\(...\).*/\1/" | while read X; do caseinsensitiveregex "$X"; done | tr "\n" "|" | sed "s/|$/)/"`
WEEKLISTRE="("`echo "$WEEKLIST" | tr " " "\n" | sed "p;s/\(...\).*/\1/" | while read X; do caseinsensitiveregex "$X"; done | tr "\n" "|" | sed "s/|$/)/"`
echo ">>$MONTHLISTRE<<"
echo ">>$WEEKLISTRE<<"
NUMPOST="(st|nd|rd|th)"
echo "$MONTHLISTRE"

for X in `seq 1 $TOTAL`; do

	# maildo "$X"

	FOUND=`

		maildo "$X" |

		fromstring "" | ## drops headers

		perl -n -e "
			/([0-3]?[0-9])($NUMPOST( of|)|) $MONTHLISTRE( ([0-9]*)|)/ && "'
				# print("$_") &&
				print("$1/$5/$7\n");
			'"
			/$MONTHLISTRE ([0-3]?[0-9])($NUMPOST|[^0-9][^0-9])/ && "'
				# print("$_") &&
				print("$2/$1/\n");
			'"
			/this $WEEKLISTRE/ && "'
				printf("WEEKDAY: THIS $1");
			'"
			# /$MONTHLISTRE/ && "'
				# # print("$_") &&
				# print("$2/$1/\n");
			# '"
		"

	`

	if test "$FOUND" = ""; then
		echo "No dates found in $X!"
		maildo "$X"
	else
		echo "Dates found in $X:"
		echo "$FOUND"
		### ## Move out of todo box
		### maildo "s $X $MBOXOUR" > /dev/null
		### maildo "d $X" > /dev/null
		### X=`expr "$X" - 1` ## Doesn't work of course!
	fi

done
