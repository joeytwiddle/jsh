#!/bin/sh
## TODO: migrate to options:
# export MADPLAY_STANDIN_PLAYS_RANDOM_TUNE_TOO=true

## Now irate is calling these:
## madplay -Q --mono --sample-rate 22050 --output wav:/tmp/irate_marsyas/out.wav /home/joey/linux/irate/download/KIND_TX_-_In_1980.mp3
## madplay --start=0:00:00 --amplify -1 -v --display-time=remaining /home/joey/linux/irate/download/The_Phoenix_Trap_-_You're_On_Fire.mp3

if [ "$1" = -playnlock ]
then

	LOCKFILE="$2"
	shift; shift

	## Skip extra madplay options
	# while [ "$#" -gt 1 ]
	while [ "$2" ]
	do shift
	done

	mplayer "$@"

	if [ "$MADPLAY_STANDIN_PLAYS_RANDOM_TUNE_TOO" ]
	then
		FILE=`cat $JPATH/music/list.m3u | ungrep INCOMPLETE | chooserandomline`
		echo
		echo "`curseyellow`Also playing: `cursered`del `cursemagenta``cursebold`\"$FILE\"`cursenorm`"
		mp3duration "$FILE"
		echo
		NAME=`echo "$FILE" | afterlast /`
		echo "Also playing: $NAME" | txt2speech
		mplayer "$FILE"
	fi

	jdeltmp "$LOCKFILE"

	sleep 5

else

	echo "Called: madplay $*" >> /tmp/madplay_script.log

	# if [ "$1" = -Q ]
	if true
	then unj madplay "$@"
	else
	# then

		## Skip extra madplay options
		# while [ "$#" -gt 1 ]
		while [ "$2" ]
		do shift
		done

		LOCKFILE=`jgettmp madplay.lock`
		touch "$LOCKFILE"

		# inscreendo -xterm madplay madplay -playnlock "$LOCKFILE" "$@"
		inscreendo -xterm madplay $JPATH/jsh $JPATH/tools/madplay -playnlock "$LOCKFILE" "$@"
		# mplayer "$@"

		echo "Waiting on $LOCKFILE ..." >&2
		while [ -f "$LOCKFILE" ] || fuser /dev/dsp
		do

			## preferably, we would block until that mplayer finishes
			## but for the time being, give screen + mplayer time to start, and block /dev/dsp
			sleep 2

		done
		echo "Unlocked" >&2

		# echo "-00:00:01"

	fi

fi
