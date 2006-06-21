[ "$1" = -l ] && INPUT_LONG=true && shift

if [ "$INPUT_LONG" ]
then . importshfn tocol fromcol
fi

cat |
while read DIR
do
	DIR=`echo "$DIR" | sed 's+:$++'`
	while true
	do
		read LINE
		if [ ! "$LINE" ]
		then break
		fi
		if [ "$INPUT_LONG" ]
		then
			DATA=`echo "$LINE" | tocol 9`
			FILENAME=`echo "$LINE" | fromcol 9`
			echo "$DATA $DIR/$FILENAME"
		else
			FILE="$LINE"
			echo "$DIR/$FILE"
		fi
	done
done
