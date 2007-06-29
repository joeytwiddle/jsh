for FILE
do

	REALFILE=`realpath "$FILE"`
	FILENAME=`filename "$FILE"`

	cd "$HOME"/.loki/ut/System/
	COMPRESSED_FILE="$PWD"/"$FILENAME".uz

	cp -a "$REALFILE" "$PWD"/
	FILE="$PWD"/"$FILENAME"

	/home/oddjob2/ut_server/ut-server/ucc compress "$FILE"
	if [ -f "$COMPRESSED_FILE" ]
	then
		OLDSIZE=`filesize "$FILE"`
		NEWSIZE=`filesize "$COMPRESSED_FILE"`
		PERCENT=`expr "$NEWSIZE" '*' 100 / "$OLDSIZE"`
		echo "Compressed to $PERCENT%"
	fi

done
