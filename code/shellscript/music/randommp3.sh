# jsh-depends: playmp3andwait takecols chooserandomline filename
# jsh-depends-ignore: music del

SEARCH="$1"

while true
do

	TRACK=`cat $JPATH/music/list.m3u | grep -i "$SEARCH" | ungrep INCOMPLETE | chooserandomline`

	## Inform the log
	echo "$TRACK" >> $JPATH/logs/xmms.log

	## Echo output to user

		# filename "$TRACK"
		SIZE=`du -sh "$TRACK" | takecols 1`
		# echo "$SIZE: "`filename "$TRACK"`" ("`dirname "$TRACK"`")"
		# echo "$SIZE: "`dirname "$TRACK";curseyellow`/`filename "$TRACK";cursenorm`""
		echo "$SIZE: "`curseyellow;cursebold`filename "$TRACK"`cursenorm`

		echo "`cursered`del \"$TRACK\"`cursenorm`"

		MP3INFO=`mp3info "$TRACK"`
		echo "$MP3INFO" |
		grep -v "^File: " |
		sed "s+[[:alpha:]]*:+`cursemagenta`\0`cursenorm`+g" |
		# sed "s+\(File:[^ ]* \)\(.*\)+`curseblue`\1 `curseblue`\2+"
		cat

	## Normalise volume (gain)

		if which mp3gain > /dev/null 2>&1
		then
			NEWTRACK="/tmp/randommp3-gainchange.mp3"
			cp "$TRACK" "$NEWTRACK"
			mp3gain -r -c "$NEWTRACK"
			TRACK="$NEWTRACK"
		fi

	echo "Waiting for last mpg123 to finish."
	wait
	echo "Done waiting!"

	/usr/bin/time -f "%e seconds ( Time: %E CPU: %P Mem: %Mk )" playmp3andwait "$TRACK" &

	echo
	echo "--------------------------------------"
	echo

done
