## fifovo: Watches a streaming video, saving it in rotating files, so that video from the past few minutes can be retrieved.

## TODO: maybe we should add a buffer so that mencoder has more time to encode before mplayer plays; seems ok right now though (mplayer caches till it can play, then plays)

# jsh-ext-depends: mencoder mkfifo mplayer seq tee
# jsh-depends: guifyscript verbosely
# jsh-depends-ignore: mplayer

encoding_thread () {
	## Not always nice:
	# ENCODING_OPTIONS="-oac copy -ovc copy"
	## Needs headers for playback (may have changed with -of mpeg):
	# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vqscale=6"
	## Streams back ok but no audio (blame -of avi and maybe try again):
	# ENCODING_OPTIONS="-oac mp3lame -ovc lavc -lavcopts vcodec=mpeg2video:vqscale=6"
	# ENCODING_OPTIONS="-oac mp3lame -ovc lavc -lavcopts vcodec=mpeg1video:vqscale=6"
	## Tried mjpeg msmpeg4 mpeg4, none of which replay!  Ah I needed -of mpeg below!
	## Audio and video playback ok provided -of mpeg below:
	ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts acodec=mp3:vcodec=mpeg2video:vqscale=6"
	verbosely mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" \
		$ENCODING_OPTIONS 2>&1 |
	# highlight ".*" yellow
	cat
}

piping_thread () {

	cat "$ENCODED_FIFO" |

	while true
	do

		for X in `seq -w 1 20`
		do
			FILE="/tmp/streamed.$X.avi"
			echo "Now piping into $FILE (as well as $PLAYER_FIFO)" >&2

			# verbosely dd if="$ENCODED_FIFO" count=1024 bs=1024 |

			verbosely dd count=1024 bs=1024 |

			# verbosely tee -a "$PLAYER_FIFO" >> "$FILE"

			verbosely tee "$FILE" |
			# cat > "$PLAYER_FIFO"

			# verbosely tee "$PLAYER_FIFO" |
			# cat > "$FILE"

			cat

			if [ ! "$?" = 0 ]
			then
				echo "There was a problem" >&2
				return
			fi

		done

	done |

	cat > "$PLAYER_FIFO" 2>&1 |

	# highlight -bold ".*" red
	cat
}

playing_thread () {
	verbosely mplayer "$PLAYER_FIFO" # | highlight ".*" green
}

## I don't know why but if you leave the ()s out it causes a nasty infloop!
initialise () {

	export STREAM_SOURCE="$1"
	shift

	export ENCODED_FIFO="/tmp/encoded.fifo"
	export PLAYER_FIFO="/tmp/toplay.fifo"

	rm -f "$ENCODED_FIFO" "$PLAYER_FIFO"
	mkfifo "$ENCODED_FIFO"
	mkfifo "$PLAYER_FIFO"

	guifyscript "$0" encoding_thread "$STREAM_SOURCE" &
	ENCODING_PID="$!"
	echo "ENCODING_PID=$ENCODING_PID"

	sleep 2

	guifyscript "$0" piping_thread &
	PIPING_PID="$!"
	echo "PIPING_PID=$PIPING_PID"

	sleep 2

	guifyscript "$0" playing_thread &
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
		echo "Try: fifovo stream http://some.url"
		exit 1
	;;
esac

