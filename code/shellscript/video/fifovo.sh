## fifovo: Watches a streaming video, saving it in rotating files, so that video from the past few minutes can be retrieved.

## TODO: maybe we should add a buffer so that mencoder has more time to encode before mplayer plays; seems ok right now though (mplayer caches till it can play, then plays)

# jsh-depends: guifyscript verbosely
# jsh-ext-depends: mencoder mkfifo mplayer seq tee
# jsh-depends-ignore: mplayer
# jsh-ext-depends-ignore: from

encoding_thread () {

	## These ones DONT WORK:
	## Has real trouble encoding video as mpeg4:
	# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts acodec=mp3:vcodec=mpeg4:vqscale=6"
	# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vqscale=6"
	## Often nasty:
	# ENCODING_OPTIONS="-oac copy -ovc copy"

	## Audio and video playback ok provided -of mpeg below:
	# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts acodec=mp3:vcodec=mpeg2video:vqscale=6"

	## One time the video did not play on one clip:
	ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vcodec=mpeg2video:vqscale=6"
	## Seems ok but expensive for CPU:
	# ENCODING_OPTIONS="-oac mp3lame -ovc lavc -lavcopts vcodec=mpeg1video:vqscale=6"

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

			## This paragraph lets you send earlier/other streams to the player, eg.:
			##   echo "/tmp/streamed.02.avi" > /tmp/replay.todo
			## Warning this causes the encoding thread to block, but hopefully it won't hang permanently if the replay is short.  (It frequently does cause encode to break though :( .)
			## mencoder complains: FAAD: error: Channel coupling not yet implemented, trying to resync!
			## Maybe it happens because the encoder's output fifo blocks because the player is not reading quickly enough (it played something else for a while).
			## We could either add a buffer, or maybe skip some of the real input, to keep the encoder's output buffer from filling.
			## OK this new method drops some of the input stream from the toplay.fifo
			## Of course, viewing a fixed size replay and skipping a fixed size from encoder, does not neccessarily take the same amount of time for each process
			## So, the encoder's output stream might become a little more blocked,
			## or the player will play the replay quickly, and then have to wait for the encoder.
			## Could avoid that by fixing bitrate.
			## Can avoid former by dropping all input from encoder, which would probably cause latter to happen.
			## So, what about... dropping all but a fixed amount?!
			TODO=
			if [ -f /tmp/replay.todo ]
			then
				TODO=`cat /tmp/replay.todo`
				printf "" > /tmp/replay.todo
				echo "$TODO" | grep -v "^$" |
				while read TOREPLAY
				do
					echo "Replaying from $TOREPLAY" >&2
					verbosely dd if="$TOREPLAY" &
				done
			fi

			FILE="/tmp/streamed.$X.avi"
			echo "Now piping into $FILE (as well as $PLAYER_FIFO)" >&2

			# verbosely dd if="$ENCODED_FIFO" count=1024 bs=1024 |

			verbosely dd count=1024 bs=1024 |

			# verbosely tee -a "$PLAYER_FIFO" >> "$FILE"

			verbosely tee "$FILE" |
			# cat > "$PLAYER_FIFO"

			# verbosely tee "$PLAYER_FIFO" |
			# cat > "$FILE"

			if [ "$TODO" ]
			then cat > /dev/null
			else cat
			fi

			wait ## For replay dd to finish

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

