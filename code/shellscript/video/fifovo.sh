encoding_thread () {
	verbosely mencoder "$STREAM_SOURCE" -of avi -o "$ENCODED_FIFO" \
		-oac lavc -ovc lavc -lavcopts vqscale=6
		# -oac copy -ovc copy
}

piping_thread () {
	# cat "$ENCODED_FIFO" |
	# while true
	for X in `seq -w 1 20`
	do
		echo "Now piping into $FILE"
		FILE="/tmp/streamed.$X.avi"
		verbosely dd if="$ENCODED_FIFO" count=1024 bs=1024 |
		tee -a "$PLAYER_FIFO" >> "$FILE"
	done
}

playing_thread () {
	verbosely mplayer "$PLAYER_FIFO"
}

initialise () {

	export STREAM_SOURCE="$1"
	shift

	export ENCODED_FIFO="/tmp/encoded.fifo"
	export PLAYER_FIFO="/tmp/toplay.fifo"

	rm -f "$ENCODED_FIFO" "$PLAYER_FIFO"
	mkfifo "$ENCODED_FIFO"
	mkfifo "$PLAYER_FIFO"

	xterm -e "$0" encoding_thread "$STREAM_SOURCE" &
	ENCODING_PID="$!"
	echo "ENCODING_PID=$ENCODING_PID"

	sleep 2

	xterm -e "$0" piping_thread &
	PIPING_PID="$!"
	echo "PIPING_PID=$PIPING_PID"

	sleep 2

	xterm -e "$0" playing_thread &
	PLAYER_PID="$!"
	echo "PLAYER_PID=$PLAYER_PID"

	wait

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
	stream)
		initialise "$@"
	;;
	*)
		echo "Don't know command: $COMMAND"
		exit 1
	;;
esac

