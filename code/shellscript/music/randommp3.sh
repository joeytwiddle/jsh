# jsh-depends: playmp3andwait takecols chooserandomline filename
# this-script-does-not-depend-on-jsh: music del

## TODO: Have mp3gain not change the file, but create a tiny file to cache the results of the mp3gain scan.  Use mp3gain to apply the (cached) result to a temporary copy of the mp3 before playing.

SEARCH="$1"

# memo -t "2 hours" updatemusiclist
# memo -t "2 days" updatemusiclist

if which mp3gain > /dev/null 2>&1 && [ ! "$DONT_USE_MP3GAIN" ]
then
	USE_MP3GAIN=true
	NORMALISEDTRACK="/tmp/randommp3-gainchange.mp3"
	NORMALISEDTRACK2="/tmp/randommp3-gainchange-2.mp3"
fi

FIRSTLOOP=true

while true
do

	# TRACK=`cat $JPATH/music/list.m3u | grep -i "$SEARCH" | chooserandomline`
	TRACK=`memo updatemusiclist | grep -i "$SEARCH" | chooserandomline`

	[ ! -f "$TRACK" ] && continue

	## Normalise volume (gain)
	TRACKTOPLAY="$TRACK"
	## TODO: what if it fails, eg. ogg, will not know when playing, will probably play previous track!
	# if [ "$USE_MP3GAIN" ] && [ ! "$FIRSTLOOP" ] && endswith "$TRACK" "\.mp3" ## because mp3gain does nasty things with oggs (like filling up the computer's memory?!)
	echo "`curseblue`Next track: `cursemagenta`$TRACK`cursenorm`" >&2
	if [ "$USE_MP3GAIN" ] && [ ! "$FIRSTLOOP" ] && echo "$TRACK" | grep -i "\.mp3$" ## because mp3gain does nasty things with oggs (like filling up the computer's memory?!)
	then
		# echo "`curseblue`Normalising next track: `cursemagenta`$TRACK`cursenorm`" >&2

		curseblue
		undomp3gain "$TRACK" # >/dev/null 2>&1 ## can be removed once i've un-mp3gained my collection!
		cursenorm

		TMPFILE="$NORMALISEDTRACK"
		nice -n 18 mp3gainhelper "$TRACK" "$TMPFILE" &&
		TRACKTOPLAY="$TMPFILE"

		## Swap round tmpfile names, so mp3gain doesn't interfere with player.
		TMP="$NORMALISEDTRACK"
		NORMALISEDTRACK="$NORMALISEDTRACK2"
		NORMALISEDTRACK2="$TMP"

		## Before we play it, the whatsplaying script wants to know the original track file:
		echo "$TRACK" > "$NORMALISEDTRACK".whatsplaying

		echo "`curseblue`Done normalising track: $TRACK`cursenorm`" >&2
	fi

	# [ "$FIRSTLOOP" ] || echo "`curseblue`Waiting for current track to finish playing.`cursenorm`"
	wait

	echo
	echo "--------------------------------------"
	echo

	xttitle "randommp3: `mp3info -p "%a - %t" "$TRACK" 2>/dev/null` [`filename "$TRACK"`]"

	## Inform the log
	echo "$TRACK" >> $JPATH/logs/xmms.log

	## Echo output to user
	# SIZE=`du -sh "$TRACK" | takecols 1`
	SIZE=`mp3duration "$TRACK" | takecols 1`
	# echo "$SIZE: "`curseyellow``cursebold`"$TRACK"`cursenorm`
	echo "\""`curseyellow``cursebold`"$TRACK"`cursenorm`"\" ($SIZE)"

	MP3INFO=`mp3info "$TRACK" 2>/dev/null`

	echo "$MP3INFO" |
	grep -v "^File: " | grep -v "^$" |
	sed "s+[[:alpha:]]*:+`cursemagenta`\0`cursenorm`+g" |
	# sed "s+\(File:[^ ]* \)\(.*\)+`curseblue`\1 `curseblue`\2+"
	cat

	(
		echo "randommp3: `mp3info -p "%a - %t" "$TRACK" 2>/dev/null` [`filename "$TRACK"`]"
		echo "$MP3INFO"
	) |
	osd_cat -c green -f '-*-lucida-*-r-*-*-*-200-*-*-*-*-*-*'

	echo "`cursered`del \"$TRACK\"`cursenorm`""*" # * added for .mp3gain files :)

	# [ "$USE_MP3GAIN" ] && [ ! "$FIRSTLOOP" ] && TRACK="$NORMALISEDTRACK"

	# if [ -x /usr/bin/time ]
	# then /usr/bin/time -f "%e seconds ( Time: %E CPU: %P Mem: %Mk )" playmp3andwait "$TRACK" &
	# else playmp3andwait "$TRACK" &
	# fi
	# echo "randommp3: `mp3info -p "%a - %t" "$TRACK" 2>/dev/null` [`filename "$TRACK"`]" | osd_cat -f '-*-lucida-*-r-*-*-*-440-*-*-*-*-*-*'
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
