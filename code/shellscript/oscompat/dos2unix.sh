if [ "$*" ]
then

	for FILE
	do

		cat "$FILE" | dos2unix | pipebackto "$FILE"

	done

else

	tr -d '\r'

fi

## Doesn't seem to work
# for FILE
# do
	# TMPFILE=`jgettmp "$FILE"`
	# cat "$FILE" |
	# sed 's+\r$++' |
	# cat > $TMPFILE &&
	# cp -f $TMPFILE "$FILE"
	# jdeltmp $TMPFILE
# done
