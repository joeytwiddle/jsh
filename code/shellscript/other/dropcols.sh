#!/bin/sh
## dropcols takes a list of columns numbers to drop, eg. df | dropcols 2 3 5 6
## Could have generated arguments for takecols but instead generates a sedscript (no trailing spaces =)

## TODO:
## Sometimes fields are delimited by single tabs, single spaces, or multiple spaces.  What's yours?

## Currently matches adjacent spaces/tabs as one delimeter
SEDSTRINGBITA='\([^ 	]*\)[ 	]*'

## For matching a single tab as one delimeter:
# SEDSTRINGBITA='\([^ 	]*\)\([ ]*\|	\)'
## Or a single space or single tab as one delimeter:
# SEDSTRINGBITA='\([^ 	]*\)\( \|	\)'
## But since | requires a second \(...\) in above, we pick up twice as many arguments, and would need to use COLN*2-1 in the sed string...

SEDSTRINGPARTA=
SEDSTRINGPARTB=

COLN=1

while true
do

	## Check to see if current column is in list of those to drop.
	## Also check if it is < any of the columns to drop.
	KEEPCOL=true
	LASTCOL=true
	for COLTODROP
	do
		if test "$COLN" = "$COLTODROP"
		then KEEPCOL=
		fi
		if test "$COLN" -lt "$COLTODROP"
		then LASTCOL=
		fi
	done

	## Sed always picks up a column:
	SEDSTRINGPARTA="$SEDSTRINGPARTA$SEDSTRINGBITA"
	## But only sometimes prints it back out:
	if test "$KEEPCOL"
	then SEDSTRINGPARTB="$SEDSTRINGPARTB\\$COLN "
	else SEDSTRINGPARTB="$SEDSTRINGPARTB"
	fi

	COLN=`expr "$COLN" + 1`

	## This loop has gotta end somewhere, when there are no more columns to drop!
	## (Our sed string leaves the rest of the line intact.)
	if test "$LASTCOL"
	then break
	fi

done

SEDSTRING="s+^$SEDSTRINGPARTA+$SEDSTRINGPARTB+"

# echo "$SEDSTRING"

sed "$SEDSTRING"
