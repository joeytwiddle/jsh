CLASSES=`jgettmp $0-$$-classes`
ANCESTORS=`jgettmp $0-$$-ancestors`


find . -name "*.java" |

withalldo grep "[ 	]extends[ 	]" | # maybe not needed but faster with

extractregex "[^ 	]*[ 	]*extends[ 	]*[^ 	]*" |

while read CHILD EXTENDS PARENT
do

	echo "$CHILD" >> $CLASSES
	echo "$CHILD $PARENT" >> "$ANCESTORS"

done


cat "$CLASSES" |
removeduplicatelines |

while read NAME
do

	CHECK="$NAME"
	while true
	do

		PARENT=`grep "^$CHECK" $ANCESTORS | head -1 | takecols 2`
		if [ "$PARENT" ]
		then
			NAME="$PARENT -> $NAME"
			CHECK="$PARENT"
		else
			break
		fi

	done

	echo "$NAME"

done |

if [ "$1" =  -tree ]
then sort | treesh -onlyat ">"
else sort
fi

