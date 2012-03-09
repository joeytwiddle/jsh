#!/bin/sh

QUERY="$*"

RESPONSE="`
	dig +short txt "$QUERY".wp.dg.cx |
	# host -t txt "$QUERY".wp.dg.cx |
	# grep " descriptive text " |
	# afterfirst " descriptive text " |
	sed 's+" "++g' |   ## Trim the ..." "... breaks
	sed 's+^"++ ; s+"$++'   ## Trim the leading and trailing "
`"

if [ "$RESPONSE" ]
then
	COLBROWN=`cursered`
	COLNORM=`cursenorm`
	COLROYAL=`curseblue;cursebold`
	echo "$RESPONSE" |
	# sed 's+\\194\\160\([0-9A-Za-z.]*\)'+"$COLBROWN\1$COLNORM+g" |
	sed 's+\\194\\160'+" +g" |
	sed 's+\\194\\178'+"^2+g" |
	sed "s+http://[^ ]*+$COLROYAL\0$COLNORM+g" |
	cat
else
	echo "No Wikipedia results for \"$QUERY\""
fi

