HASHFILE=`jgettmp $0-$$-hash`
SEDFILE=`jgettmp $0-$$-sed`


find . -name "*.java" |

withalldo grep "[ 	]extends[ 	]" | # maybe not needed but faster with

extractregex "[^ 	]*[ 	]*extends[ 	]*[^ 	]*" |

while read CHILD EXTENDS PARENT
do

	# echo "$PARENT->$CHILD" >> $HASHFILE
	echo "$CHILD" >> $HASHFILE
	echo "s+\<$CHILD\>+$PARENT->$CHILD+" >> "$SEDFILE"

done

cat "$HASHFILE" |
removeduplicatelines |
dog "$HASHFILE"


more "$HASHFILE"


cat "$SEDFILE" |
removeduplicatelines | sed 's+<+\\\\<+;s+>+\\\\>+' |
pipeboth |
dog "$SEDFILE"


cat "$HASHFILE" |
sed --file=$SEDFILE |

sort |
# tree
cat
