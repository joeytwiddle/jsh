# jsh-depends: playmp3andwait takecols chooserandomline filename
# jsh-depends-ignore: music del

SEARCH="$1"

memo -t "2 hours" updatemusiclist

if which mp3gain > /dev/null 2>&1 && [ ! "$DONT_USE_MP3GAIN" ]
then
	USE_MP3GAIN=true
	NORMALISEDTRACK="/tmp/randommp3-gainchange.mp3"
	NORMALISEDTRACK2="/tmp/randommp3-gainchange-2.mp3"
fi

FIRSTLOOP=true

while true
do

	TRACK=`cat $JPATH/music/list.m3u | grep -i "$SEARCH" | chooserandomline`

	[ ! -f "$TRACK" ] && continue

	## Normalise volume (gain)
	## TODO: what if it fails, eg. ogg, will not know when playing, will probably play previous track!
	if [ "$USE_MP3GAIN" ] && [ ! "$FIRSTLOOP" ] && endswith "$TRACK" "\.mp3" ## because mp3gain does nasty things with oggs (like filling up the computer's memory?!)
	then
		# echo "`curseblue`Normalising next track: $TRACK`cursenorm`"
		# jshinfo
		jshinfo "Normalising next track: $TRACK"
		# jshinfo
		# cp "$TRACK" "$NORMALISEDTRACK" || continue
		# ln -sf "$TRACK" "$NORMALISEDTRACK".whatsplaying ## To help the whatsplaying script with these tracks!
		# cursecyan
		# nice -n 20 mp3gain "$NORMALISEDTRACK" | grep '\(Recommended "Track" mp3 gain change\| not \)'
		# nice -n 20 mp3gain -r -c "$NORMALISEDTRACK" > /dev/null 2>&1
		# cursenorm
		## TODO: this assumed the > pipe is local to qkcksum, not the whole line.  Check.
		[ -e "$TRACK.qkcksum.b4mp3gain" ] || qkcksum "$TRACK" > "$TRACK.qkcksum.b4mp3gain" ## Lol!
		# nice -n 20 mp3gain -r -c "$TRACK" > /dev/null
		# nice -n 20 mp3gain "$TRACK"
		nice -n 16 mp3gain -r -c "$TRACK"
		# nice -n 20 mp3gain "$TRACK" | grep '\(Recommended "Track" mp3 gain change\| not \)' 2>&1

		# jshinfo "Results of normalisation:"
		# mp3gain -s c "$TRACK" # | grep '\(Recommended "Track" mp3 gain change\| not \)'

		mp3gain -s c "$TRACK" | grep '\(^Recommended \"Track\" mp3 gain change:\| not \)'
		# jshinfo
		jshinfo "Done normalising track: $TRACK"
		# jshinfo
	fi

	# [ "$FIRSTLOOP" ] || echo "`curseblue`Waiting for current track to finish playing.`cursenorm`"
	wait

	echo
	echo "--------------------------------------"
	echo

	## Inform the log
	echo "$TRACK" >> $JPATH/logs/xmms.log

	## Echo output to user
	# SIZE=`du -sh "$TRACK" | takecols 1`
	SIZE=`mp3duration "$TRACK" | takecols 1`
	echo "$SIZE: "`curseyellow``cursebold`"$TRACK"`cursenorm`
	MP3INFO=`mp3info "$TRACK"`
	echo "$MP3INFO" |
	grep -v "^File: " | grep -v "^$" |
	sed "s+[[:alpha:]]*:+`cursemagenta`\0`cursenorm`+g" |
	# sed "s+\(File:[^ ]* \)\(.*\)+`curseblue`\1 `curseblue`\2+"
	cat
	echo "`cursered`del \"$TRACK\"`cursenorm`"

	# [ "$USE_MP3GAIN" ] && [ ! "$FIRSTLOOP" ] && TRACK="$NORMALISEDTRACK"

	# if [ -x /usr/bin/time ]
	# then /usr/bin/time -f "%e seconds ( Time: %E CPU: %P Mem: %Mk )" playmp3andwait "$TRACK" &
	# else playmp3andwait "$TRACK" &
	# fi
	if [ "$USE_MP3GAIN" ]
	then
		playmp3andwait "$TRACK" &
		## Gives mpg123 time to cache, so mp3gain doesn't steal vital CPU!  TODO: renice mpg123
		sleep 10
	else
		playmp3andwait "$TRACK"
	fi
	echo

	## Swap round tmpfile names, so mp3gain doesn't interfere with player.
	TMP="$NORMALISEDTRACK"
	NORMALISEDTRACK="$NORMALISEDTRACK2"
	NORMALISEDTRACK2="$TMP"

	FIRSTLOOP=

done
