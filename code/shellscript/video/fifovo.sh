## fifovo: Watches a streaming video, saving it in rotating files, so that video from the past few minutes can be retrieved.

## BUG: Doesn't currently work for rtsp because for mencoder to encode rtsp, it requires output formats that do not suit our fifo trick

## TODO: Try what Rande on #freevo said: "mplayer will play anything and output to mpegpes"
## and previously: <Rande> ahh.  yes - recoding on the fly is how a lot of 'streamer' products work.  actually, you should be able to do it with mplayer - just get it to play the stream and -vo mpegpes to the fifo
## Unfortunately, -vo mpegpes does not work on my system.
## But I can use -vo yuv4mpeg and -ao pcm to create stream.yuv and audiodump.wav!

## TODO: maybe we should add a buffer so that mencoder has more time to encode before mplayer plays; seems ok right now though (mplayer caches till it can play, then plays)

## Also TODO: add a higher resolution (smaller byte-block) pipe for more fine-controlled merging / splitting
##            and a meta-manager which knows the duration of video which each file in the ringbuffer spans.

## Yeah essentially this script is useless until we either:
##  Get it to rewind and playback if user desires
##  or, allow a nice way to save what has just passed and what is coming, to somewhere sensible.

## See also: transcode has a --avi_limit MB option, which will produce multiple files...

# jsh-depends: guifyscript verbosely jshinfo
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
	## This successfully encodes RTSP, but doesn't create a stream playable from a fifo or even a file :(  In fact it is probably encoding into fifo that failed.
	# ENCODING_OPTIONS="-oac pcm -ovc lavc -lavcopts vqscale=6"

	## Audio and video playback ok provided -of mpeg below:
	# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts acodec=mp3:vcodec=mpeg2video:vqscale=6"

	## Seems ok but expensive for CPU:
	ENCODING_OPTIONS="-oac mp3lame -ovc lavc -lavcopts vcodec=mpeg1video:vqscale=6"
	## One time the video did not play on one clip:
	# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vcodec=mpeg2video:vqscale=6"

	verbosely mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" $ENCODING_OPTIONS 2>&1 |
	#
	## Won't work for me cos I have no /dev/dvb/adapter0/video0+audio0
	# verbosely mplayer "$STREAM_SOURCE" -vo mpegpes 2>&1 |
	# verbosely mplayer "$STREAM_SOURCE" -vo yuv4mpeg -ao pcm 2>&1 |
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
			## Tho interestingly, it didn't seem to happen until after mplayer rejoined the encoded stream
			## We could either add a buffer, or maybe skip some of the real input, to keep the encoder's output buffer from filling.
			## OK this new method avoids sending some of the input stream from the toplay.fifo
			## BUG: Of course, viewing a fixed size replay and skipping a fixed size from encoder, does not neccessarily take the same amount of time for each process
			## So, (bad1) the encoder's output stream might become a little more blocked,
			## or (notsobad2) the player will play the replay quickly, and then have to wait for the encoder.
			## (bad1) especially happens if you replay more than one file.
			## I'm not sure if it causes audio-unsync too; that might have been when the & was inside the do.
			## Could avoid that by fixing bitrate.
			## Can avoid (bad1) by dropping all input from encoder, which would probably cause (notsobad2) to happen.
			## So, what about... dropping all but a fixed amount?!
			## TODO: Or this might be a solution: all the time you are replaying, dd into dev/null, but dd back into toplay when replaying is over.  This will most likely cause the player to need to rebuffer because dev/null probably reads a lot faster than the fifo!
			TODO=
			if [ -f /tmp/replay.todo ]
			then
				TODO=`cat /tmp/replay.todo`
				printf "" > /tmp/replay.todo
				echo "$TODO" | grep -v "^$" |
				while read TOREPLAY
				do
					jshinfo "Replaying from $TOREPLAY"
					verbosely dd if="$TOREPLAY"
				done &
			fi

			## CONSIDER: Here, instead of piping from encoder to player
			## we could just pipe to files, and have a separate playing
			## thread pipe back from files into player fifo.
			## This new thread could also manage rewinding, and possibly
			## setting record points etc.

			FILE="/tmp/streamed.$X.avi"
			if [ "$TODO" ]
			then jshinfo "Now piping into $FILE, but not into $PLAYER_FIFO"
			else jshinfo "Now piping into $FILE, and also into $PLAYER_FIFO"
			fi

			# verbosely dd if="$ENCODED_FIFO" count=1024 bs=1024 |

			verbosely dd count=1024 bs=1024 |

			# verbosely tee -a "$PLAYER_FIFO" >> "$FILE"

			verbosely tee "$FILE" |
			# cat > "$PLAYER_FIFO"

			# verbosely tee "$PLAYER_FIFO" |
			# cat > "$FILE"

			if [ "$TODO" ] ## I think this if breaks the usefulness of "$?" below.
			then cat > /dev/null
			else cat
			fi

			wait ## For replay dd to finish

			if [ ! "$?" = 0 ]
			then
				jshinfo "There was a problem"
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
	# export ENCODED_FIFO="./stream.yuv"
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

