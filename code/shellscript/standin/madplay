if [ "$1" = -playnlock ]
then

	LOCKFILE="$2"
	shift; shift

	mplayer "$@"

	del "$LOCKFILE"

else

	LOCKFILE="/tmp/madplay-$$.lock"
	touch "$LOCKFILE"

	inscreendo -xterm madplay madplay -playnlock "$LOCKFILE" "$@"
	# mplayer "$@"

	while [ -f "$LOCKFILE" ]
	do

		## preferably, we would block until that mplayer finishes
		## but for the time being, give screen + mplayer time to start, and block /dev/dsp
		sleep 5

	fi

fi
