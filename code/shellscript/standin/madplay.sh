if [ "$1" = -playnlock ]
then

	LOCKFILE="$2"
	shift; shift

	mplayer "$@"

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
