## fifovo: Watches a streaming video, saving it in rotating files, so that video from the past few minutes can be retrieved.

## TODO: Add facility to save the playing stream (so can rewind, then "hit" "start recording").
##       This might run into problems, since header is likely to be missing, but _we_ know what stream type it is (or we could possibly keep the very start of the stream and append it; hacky but it will at least get a working video with the bit we want).
## TODO: If playing stream has paused at block 10 (or is just being slow to playback than encode),
##       when saving stream reaches 9, it should start creating new files rather than overtaking / overwriting the playing thread / stream.

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
	# ENCODING_OPTIONS="-oac mp3lame -ovc lavc -lavcopts vcodec=mpeg1video:vqscale=6"
	## One time the video did not play on one clip:
	ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vcodec=mpeg2video:vqscale=3"

	verbosely mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" $ENCODING_OPTIONS 2>&1 |
	## Try to make reencoder use less CPU by running gentoo version:!
	# export LD_LIBRARY_PATH="/lib:/usr/lib:/mnt/gentoo/lib:/mnt/gentoo/usr/lib"
	# verbosely /mnt/gentoo/usr/bin/mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" $ENCODING_OPTIONS 2>&1 |
	#
	## Won't work for me cos I have no /dev/dvb/adapter0/video0+audio0
	# verbosely mplayer "$STREAM_SOURCE" -vo mpegpes 2>&1 |
	# verbosely mplayer "$STREAM_SOURCE" -vo yuv4mpeg -ao pcm 2>&1 |
	# highlight ".*" yellow
	cat

	# wget "$STREAM_SOURCE" -O - > "$ENCODED_FIFO"

}

saving_thread () {

	WRITING_BLOCK=0

	cat "$ENCODED_FIFO" |

	while true
	do

		echo "$WRITING_BLOCK" > "$CURRENT_WRITING_BLOCK_INFO_FILE"
		WRITING_BLOCK=`printf "%04i" "$WRITING_BLOCK"`
		FILE="$STREAM_DATA_DIR/streamed.$WRITING_BLOCK.mpeg"
		jshinfo "Now piping into $FILE"

		# verbosely dd count=$BLOCK_SIZE bs=1 of="$FILE"
		# verbosely dd count=1 bs=$BLOCK_SIZE of="$FILE"

		## Seems worse:
		TRANS_BLOCK_SIZE=`expr "$BLOCK_SIZE" / 1024`
		verbosely dd count=$TRANS_BLOCK_SIZE bs=1024 | cat > "$FILE"

		# verbosely dd count=$BLOCK_SIZE bs=1 | cat > "$FILE"

		if [ ! "$?" = 0 ]
		then
			jshinfo "There was a problem"
			return
		fi

		WRITING_BLOCK=`expr "$WRITING_BLOCK" + 1`
		if [ ! "$WRITING_BLOCK" -lt "$BUFFER_SIZE" ]
		then WRITING_BLOCK=0
		fi

	done

}

restreaming_thread () {

	CURRENT_STREAMING_BLOCK=0

	# while true
	# do
		
	while true
	do

		## This paragraph lets you rewind the playing stream, eg.:
		##   echo "20" > /tmp/rewind
		## TODO: doesn't check whether you cross the boundary of the
		##       start of the ringbuffer (go too far back)
		if [ -f /tmp/rewind ]
		then
			DISTANCE=`cat /tmp/rewind`
			jshinfo "Rewinding $DISTANCE blocks (of size $BLOCK_SIZE)"
			LAST_CURRENT_STREAMING_BLOCK="$CURRENT_STREAMING_BLOCK"
			CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" - $DISTANCE`
			if [ ! "$CURRENT_STREAMING_BLOCK" ]
			then
				echo "Error rewinding by \"$DISTANCE\" blocks."
				CURRENT_STREAMING_BLOCK="$LAST_CURRENT_STREAMING_BLOCK"
			fi
			if [ "$CURRENT_STREAMING_BLOCK" -lt 0 ]
			then CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" + "$BUFFER_SIZE"`
			fi
			rm -f /tmp/rewind
		fi
		
		while [ `cat "$CURRENT_WRITING_BLOCK_INFO_FILE"` = "$CURRENT_STREAMING_BLOCK" ]
		do
			# CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" - 1`
			jshinfo "Waiting for $CURRENT_STREAMING_BLOCK to finish writing..."
			sleep 10
		done

		jshinfo "Streaming block $CURRENT_STREAMING_BLOCK"

		CURRENT_STREAMING_BLOCK=`printf "%04i" "$CURRENT_STREAMING_BLOCK"`
		# dd if="$STREAM_DATA_DIR/streamed.$CURRENT_STREAMING_BLOCK.mpeg" |
		# cat
		cat "$STREAM_DATA_DIR/streamed.$CURRENT_STREAMING_BLOCK.mpeg"

		if [ ! "$?" = 0 ]
		then
			jshinfo "There was a problem"
			return
		fi

		CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" + 1`
		if [ ! "$CURRENT_STREAMING_BLOCK" -lt "$BUFFER_SIZE" ]
		then CURRENT_STREAMING_BLOCK=0
		fi

	# done

	done > "$PLAYER_FIFO"
	# done |

	# # dd of="$PLAYER_FIFO"
	# cat > "$PLAYER_FIFO" 2>&1 |
	# cat

}

playing_thread () {
	verbosely mplayer "$PLAYER_FIFO" # | highlight ".*" green
}

## I don't know why but if you leave the ()s out it causes a nasty infloop!
initialise () {

	export TOTAL_BUFFER_SIZE_MEG=20
	# export STREAM_DATA_DIR=/tmp/
	export STREAM_DATA_DIR=/dev/shm/joey/
	# export CURRENT_WRITING_BLOCK_INFO_FILE=/tmp/current_block.info
	export CURRENT_WRITING_BLOCK_INFO_FILE="$STREAM_DATA_DIR"/current_block.info

	export STREAM_SOURCE="$1"
	shift

	export BUFFER_SIZE=100
	export BLOCK_SIZE=`expr 10240 '*' $TOTAL_BUFFER_SIZE_MEG`

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

	guifyscript "$0" saving_thread &
	SAVING_PID="$!"
	echo "SAVING_PID=$SAVING_PID"

	sleep 2

	guifyscript "$0" restreaming_thread &
	## Didn't appear to help:
	# guifyscript nice -n 15 "$0" restreaming_thread &
	RESTREAMING_PID="$!"
	echo "RESTREAMING_PID=$RESTREAMING_PID"

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
	saving_thread)
		saving_thread "$@"
	;;
	restreaming_thread)
		restreaming_thread "$@"
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

