if [ "$1" = -mark-lines ]
then
	shift
	MARK_LINES=true
fi

for FILE
do
	if file "$FILE" | grep "gzip compressed data" >/dev/null
	then zcat "$FILE"
	elif file "$FILE" | grep "bzip2 compressed data" >/dev/null
	then bzcat "$FILE"
	else cat "$FILE"
	fi |
	
	if [ "$MARK_LINES" ]
	# then sed "s!^!$FILE:	!"
	then sed "s!^!$FILE: !"
	else cat
	fi
done
