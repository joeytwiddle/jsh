encoding_thread () {
	verbosely mencoder "$STREAM_SOURCE" -of avi -o "$ENCODED_FIFO" \
		-oac lavc -ovc lavc -lavcopts vqscale=6 2>&1 |
		# -oac copy -ovc copy
	highlight ".*" yellow
}

piping_thread () {
	# cat "$ENCODED_FIFO" |
	# while true
	for X in `seq -w 1 20`
	do
		FILE="/tmp/streamed.$X.avi"
		echo "Now piping into $FILE"
		# verbosely dd if="$ENCODED_FIFO" count=1024 bs=1024 |
		# tee -a "$PLAYER_FIFO" >> "$FILE"
		verbosely dd if="$ENCODED_FIFO" count=1024 bs=1024 |
		tee "$FILE" >> "$PLAYER_FIFO"
	done 2>&1 |
	highlight -bold ".*" red
}

playing_thread () {
	verbosely mplayer "$PLAYER_FIFO" # | highlight ".*" green
}

initialise () {

	xterm -e fifovo inner_initialise "$@"
	exit 1

}

inner_initialise {

	shift
	export STREAM_SOURCE="$1"
	shift

	export ENCODED_FIFO="/tmp/encoded.fifo"
	export PLAYER_FIFO="/tmp/toplay.fifo"

	rm -f "$ENCODED_FIFO" "$PLAYER_FIFO"
	mkfifo "$ENCODED_FIFO"
	mkfifo "$PLAYER_FIFO"

	encoding_thread "$STREAM_SOURCE" &
	ENCODING_PID="$!"
	echo "ENCODING_PID=$ENCODING_PID"

	sleep 2

	piping_thread &
	PIPING_PID="$!"
	echo "PIPING_PID=$PIPING_PID"

	sleep 2

	playing_thread &
	PLAYER_PID="$!"
	echo "PLAYER_PID=$PLAYER_PID"

	wait

	echo "Press a key."
	read KEY

	rm -f "$ENCODED_FIFO" "$PLAYER_FIFO"

}

COMMAND="$1"
shift
case "$COMMAND" in
	encoding_thread)
		encoding_thread "$@"
	;;
	piping_thread)
		piping_thread "$@"
	;;
	playing_thread)
		playing_thread "$@"
	;;
	inner_initialise)
		inner_initialise "$@"
	;;
	stream)
		xterm -e fifovo inner_initialise "$@"
	;;
	*)
		echo "Don't know command: $COMMAND"
		exit 1
	;;
esac

