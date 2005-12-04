# for FILE in *.uz
for FILE
do

	PARENTDIR=`dirname "$FILE"`
	UNZIPPEDNAMESB=`filename "$FILE" | sed 's+.uz$++'`
	# UNZIPPEDFILE="$HOME"/.loki/ut/System/"$UNZIPPEDNAME"
	REALFILE=`realpath "$FILE"`

	# jshinfo "Doing $FILE -> $UNZIPPEDNAME"
	jshinfo "Doing $FILE ..."

	# if /home/oddjob2/ut_server/ut-server/ucc decompress `realpath "$FILE"`
	# then
	UNZIPPEDNAME=`
		/home/oddjob2/ut_server/ut-server/ucc decompress "$REALFILE" |
		pipeboth |
		grep "Decompressed .* -> " |
		afterlast " -> "
	`
	UNZIPPEDFILE="$HOME"/.loki/ut/System/"$UNZIPPEDNAME"
	if [ "$UNZIPPEDFILE" ] && [ -f "$UNZIPPEDFILE" ]
	then
		if [ ! "$UNZIPPEDNAME" = "$UNZIPPEDNAMESB" ]
		then jshwarn "Old name $UNZIPPEDNAMESB and new name $UNZIPPEDNAME do not match."
		fi
		DESTFILE="$PARENTDIR/$UNZIPPEDNAMESB"
		SIZEBEFORE=`filesize "$FILE"`
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
				# verbosely mv -i "$UNZIPPEDFILE" "$PARENTDIR" &&
				# verbosely mv -i "$UNZIPPEDFILE" "$PARENTDIR"/"$UNZIPPEDNAMESB" &&
				verbosely mv -i "$UNZIPPEDFILE" "$DESTFILE" &&
				del "$FILE" # >/dev/null
			fi
		fi
	else
		echo "Decompression failed!"
		[ -f "$UNZIPPEDFILE" ] && del "$UNZIPPEDFILE"
		# exit 1
	fi

	echo

done
