# jsh-depends: playmp3andwait takecols chooserandomline filename
# jsh-depends-ignore: music del

## TODO: Have mp3gain not change the file, but create a tiny file to cache the results of the mp3gain scan.  Use mp3gain to apply the (cached) result to a temporary copy of the mp3 before playing.

SEARCH="$1"

# memo -t "2 hours" updatemusiclist
memo -t "2 days" updatemusiclist

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
	TRACKTOPLAY="$TRACK"
	## TODO: what if it fails, eg. ogg, will not know when playing, will probably play previous track!
	if [ "$USE_MP3GAIN" ] && [ ! "$FIRSTLOOP" ] && endswith "$TRACK" "\.mp3" ## because mp3gain does nasty things with oggs (like filling up the computer's memory?!)
	then
		echo "`curseblue`Normalising next track: $TRACK`cursenorm`" >&2

		curseblue
		undomp3gain "$TRACK" # >/dev/null 2>&1 ## can be removed once i've un-mp3gained my collection!
		cursenorm

		TMPFILE="$NORMALISEDTRACK"
		mp3gainhelper "$TRACK" "$TMPFILE" &&
		TRACKTOPLAY="$TMPFILE"

		## Swap round tmpfile names, so mp3gain doesn't interfere with player.
		TMP="$NORMALISEDTRACK"
		NORMALISEDTRACK="$NORMALISEDTRACK2"
		NORMALISEDTRACK2="$TMP"

		echo "`curseblue`Done normalising track: $TRACK`cursenorm`" >&2
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
	echo "$SIZE: "`cursecyan``cursebold`"$TRACK"`cursenorm`
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
		playmp3andwait "$TRACKTOPLAY" &
		## Gives mpg123 time to cache, so mp3gain doesn't steal vital CPU!  TODO: renice mpg123
		sleep 10
	else
		playmp3andwait "$TRACKTOPLAY"
	fi
	echo

	FIRSTLOOP=

done
