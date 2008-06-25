if [ "$1" = --help ]
then
	echo "ls-Rtofilelist takes the output of ls -R (also ftp's ls -R) and converts it so that formatting and folders are hidden, and each line now holds a file with its full path."
	echo "The option -l will process ls -lR input."
	echo "I usually do grep "^-" on the output, to select files only and drop symlinks."
	exit 0
fi

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
