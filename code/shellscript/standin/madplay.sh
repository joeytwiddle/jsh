## TODO: migrate to options:
export MADPLAY_STANDIN_PLAYS_RANDOM_TUNE_TOO=true

if [ "$1" = -playnlock ]
then

	LOCKFILE="$2"
	shift; shift

	mplayer "$@"

	if [ "$MADPLAY_STANDIN_PLAYS_RANDOM_TUNE_TOO" ]
	then
		FILE=`cat $JPATH/music/list.m3u | chooserandomline`
		echo
		echo "`curseyellow`Also playing: `cursemagenta``cursebold`$FILE`cursenorm`"
		echo
		echo "Also playing: $FILE" | txt2speech
		mplayer "$FILE"
	fi

	jdeltmp "$LOCKFILE"

else

	LOCKFILE=`jgettmp madplay.lock`
	touch "$LOCKFILE"

	inscreendo -xterm madplay madplay -playnlock "$LOCKFILE" "$@"
	# mplayer "$@"

	echo "Waiting on $LOCKFILE ..." >&2
	while [ -f "$LOCKFILE" ]
	do

		## preferably, we would block until that mplayer finishes
		## but for the time being, give screen + mplayer time to start, and block /dev/dsp
		sleep 5

	done
	echo "Unlocked" >&2

fi
