#!/bin/sh
## TODO: doesn't recognise:
## 1:00pm Friday Feb. 15th, 2002. Room 4.01 Merchant Venturers Building
## (Wed 9th / 8pm / =A33/2

test ! -e /tmp/mbox && cp "$HOME/evolution/local/A/subfolders/Calendar/mbox" /tmp/mbox
MBOX="/tmp/mbox"
MBOXOUT="$MBOX-done"

. mailtools.shlib

TOTAL=`mailcount`

WEEKLIST="Monday Tuesday Wednesday Thursday Friday Saturday"
MONTHLIST="January February March April May June July August September October November December"
# MONTHLISTRE="("`echo "$MONTHLIST" | tr " " "\n" | sed "p;s/\(...\).*/\1/" | tr "\n" "|"`"[01]?[0-9])"
MONTHLISTRE="("`echo "$MONTHLIST" | tr " " "\n" | sed "p;s/\(...\).*/\1/" | while read X; do caseinsensitiveregex "$X"; done | tr "\n" "|" | sed "s/|$/)/"`
WEEKLISTRE="("`echo "$WEEKLIST" | tr " " "\n" | sed "p;s/\(...\).*/\1/" | while read X; do caseinsensitiveregex "$X"; done | tr "\n" "|" | sed "s/|$/)/"`
echo ">>$MONTHLISTRE<<"
echo ">>$WEEKLISTRE<<"
NUMPOST="(st|nd|rd|th)"
echo "$MONTHLISTRE"

for N in `seq 1 $TOTAL`; do

	FOUND=`

		getmail "$N" |

		fromstring "" | ## drops headers

		perl -n -e "
			# /([0-3]?[0-9])($NUMPOST( of|)|) $MONTHLISTRE( ([0-9]*)|)/
			/([0-3]?[0-9])($NUMPOST|)( of|) $MONTHLISTRE[,]?( ([0-9]*)|)/
			&& "'
				# print("$_") &&
				print("$1/$5/$7 [A]\n");
			'"
			/$MONTHLISTRE ([0-3]?[0-9])($NUMPOST|[^0-9][^0-9])/ && "'
				# print("$_") &&
				print("$2/$1/ [B]\n");
			'"
			/this $WEEKLISTRE/ && "'
				printf("WEEKDAY: THIS $1 [C]");
			'"
			# /$MONTHLISTRE/ && "'
				# # print("$_") &&
				# print("$2/$1/\n");
			# '"
		"

	`

	if test "$FOUND" = ""; then
		cursered
		echo "No dates found in $N!"
		curseblue
		getmail "$N"
		cursenorm
	else
		echo "Dates found in $N:"
		echo "$FOUND"
		### ## Move out of todo box
		### maildo "s $N $MBOXOUT" > /dev/null
		### maildo "d $N" > /dev/null
		### N=`expr "$N" - 1` ## Doesn't work of course!
	fi

done
