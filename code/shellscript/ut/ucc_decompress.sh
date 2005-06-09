# for FILE in *.uz
for FILE
do

	PARENTDIR=`dirname "$FILE"`
	UNZIPPEDNAME=`filename "$FILE" | sed 's+.uz$++'`
	UNZIPPEDFILE="$HOME"/.loki/ut/System/"$UNZIPPEDNAME"
	DESTFILE="$PARENTDIR/$UNZIPPEDNAME"

	jshinfo "Doing $FILE -> $UNZIPPEDNAME"

	SIZEBEFORE=`filesize "$FILE"`

	if /home/oddjob2/ut_server/ut-server/ucc decompress `realpath "$FILE"`
	then
		SIZEAFTER=`filesize "$UNZIPPEDFILE"`
		SIZEPROP=`expr "$SIZEAFTER" '*' 100 / "$SIZEBEFORE"`
		jshinfo "Decompressed to $SIZEPROP%"
		if [ -f "$DESTFILE" ] && cmp "$UNZIPPEDFILE" "$DESTFILE"
		then
			jshinfo "Decompressed matches already existing file :)"
			del "$UNZIPPEDFILE"
			del "$FILE"
		else
			if [ -e "$DESTFILE" ]
			then
				error "Dest file already exists: $DESTFILE"
			else
				[ -f "$UNZIPPEDFILE" ] &&
				mv -i "$UNZIPPEDFILE" "$PARENTDIR" &&
				del "$FILE" >/dev/null
			fi
		fi
	else
		echo "Decompression failed!"
		[ -f "$UNZIPPEDFILE" ] && del "$UNZIPPEDFILE"
		# exit 1
	fi

	echo

done
