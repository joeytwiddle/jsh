cat |
while read DIR
do
	DIR=`echo "$DIR" | sed 's+:$++'`
	while true
	do
		read FILE
		if test "$FILE" = ""
		then break
		fi
		echo "$DIR/$FILE"
	done
done
