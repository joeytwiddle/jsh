## fifovo: Plays a streaming video, saving it in rotating files,
##         and accepts messages to rewind, fast-forward, or record the stream.

## TODO: Time Management
##       Either: Loop dd-ing until 10seconds is up, then progress, gettings blocks of ~10secs.
##       Or: Record time taken to save each block, to get length-meta for each block.
##       Note: Don't obtain timing relatively in the shell with sleep; that's dodgy.
##             Instead use date relative to some absolute.
##       Either is nicer than Or cos it sorta guarantees buffer duration (altho not size!).

## TODO: If playing stream has paused at block 10 (or is just being slow to playback than encode),
##       when saving stream reaches 9, it should start creating new files rather than overtaking / overwriting the playing thread / stream.
## TODO: Yes, there is no management for overlap (either when rewind/fast-forwarding, or when paused or even just when streaming at different speeds).
##       It is never really desirable to pause the encoding thread, so in circumstances of unavoidable overlap, we should create more files (increase buffer size _globally_).

## TODO: how about implementing those messaging scripts eh?
##       if saving and restreaming threads both message their positions, we can create maxforward and maxback :)

## BUG: Doesn't currently work for rtsp because for mencoder to encode rtsp, it requires output formats that do not suit our fifo trick

## TODO: Try what Rande on #freevo said: "mplayer will play anything and output to mpegpes"
## and previously: <Rande> ahh.  yes - recoding on the fly is how a lot of 'streamer' products work.  actually, you should be able to do it with mplayer - just get it to play the stream and -vo mpegpes to the fifo
## Unfortunately, -vo mpegpes does not work on my system.
## But I can use -vo yuv4mpeg and -ao pcm to create stream.yuv and audiodump.wav!

## TODO: maybe we should add a buffer so that mencoder has more time to encode before mplayer plays; seems ok right now though (mplayer caches till it can play, then plays)

## Also TODO: add a higher resolution (smaller byte-block) pipe for more fine-controlled merging / splitting
##            and a meta-manager which knows the duration of video which each file in the ringbuffer spans.

## See also: transcode has a --avi_limit MB option, which will produce multiple files...

# jsh-depends: guifyscript verbosely jshinfo curseyellow cursenorm mykill jshwarn
# jsh-ext-depends: mencoder mkfifo mplayer seq tee
# jsh-depends-ignore: mplayer before
# jsh-ext-depends-ignore: from killall size less

## These vars are here and not in initialise, because they are needed for --help.

## Reduce this to encode at better quality, if you have a fast enough machine.
## (Check that your encoding_thead is managing one second of stream every second!)
## My poor computer needs to encode at low quality, just in case demoscene.tv is playing a very detailed video!
[ "$VQSCALE" ] || export VQSCALE="10"

export FIFOVO_MESSAGE_DIR=/tmp/fifovo

encoding_thread () {

	# ENCODING_NUM=0

	while [ ! -f "$FIFOVO_MESSAGE_DIR"/stop_everything ]
	do

		## CODE_TO_CHANGE_FIFO wasn't needed once we "while true; cat fifo; done"d because now fifo closes and reopens at both ends properly.
		# # verbosely rm -f "$ENCODED_FIFO"
		# ENCODING_NUM=`expr "$ENCODING_NUM" + 1`
		# ENCODED_FIFO=/tmp/encoded.$ENCODING_NUM.fifo
		# rm -f "$ENCODED_FIFO"
		# mkfifo "$ENCODED_FIFO"
		# echo "$ENCODED_FIFO" > "$FIFOVO_MESSAGE_DIR"/newfifo
		# jshinfo "Sending output to new fifo: $ENCODED_FIFO"

		## These ones DONT WORK:
		## Has real trouble encoding video as mpeg4:
		# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts acodec=mp3:vcodec=mpeg4:vqscale=6"
		# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vqscale=6"
		## Often nasty:
		# ENCODING_OPTIONS="-oac copy -ovc copy"
		## This successfully encodes RTSP, but doesn't create a stream playable from a fifo or even a file :(  In fact it is probably encoding into fifo that failed.
		# ENCODING_OPTIONS="-oac pcm -ovc lavc -lavcopts vqscale=6"

		## Audio and video playback OK provided -of mpeg below:
		# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts acodec=mp3:vcodec=mpeg2video:vqscale=6"

		## Seems OK but expensive for CPU unless we increase vqscale:
		# ENCODING_OPTIONS="-oac mp3lame -ovc lavc -lavcopts vcodec=mpeg1video:vqscale=6"
		## One time the video did not play on one clip:
		# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vcodec=mpeg2video:vqscale=2"
		ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vcodec=mpeg2video:vqscale=$VQSCALE"

		# ## WORKING METHOD:
		# # verbosely mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" $ENCODING_OPTIONS 2>&1 |
		# # verbosely mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" $ENCODING_OPTIONS
		# verbosely mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" $ENCODING_OPTIONS &
		# echo "$!" > "$FIFOVO_MESSAGE_DIR"/fifovo_encoder.pid
		# wait
		# ## Try to make reencoder use less CPU by running gentoo version:!
		# # export LD_LIBRARY_PATH="/lib:/usr/lib:/mnt/gentoo/lib:/mnt/gentoo/usr/lib"
		# # verbosely /mnt/gentoo/usr/bin/mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" $ENCODING_OPTIONS 2>&1 |

		## EXPERIMENTING:
		## Safe as sausages.  Toline now detects when mencoder has lost sync with the stream,
		## and instead of waiting for ages for mencoder to finally give up, it kills it nice and quickly.
		## Oh it appears that the kill is unneccessary?  The toline ending kills the mencoder.
		## Ah but now it won't exit when the user wants to quit!
		## Alright, now if either mencoder or toline stop, they kill the other, by killing the parent pipe.
		(
			verbosely mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" $ENCODING_OPTIONS 2>&1 # &
			MENCODER_PID="$!"
			jshinfo "FYI MENCODER_PID was $MENCODER_PID"
			# echo "$MENCODER_PID" > "$FIFOVO_MESSAGE_DIR"/fifovo_encoder.pid
			# jshinfo "Started mencoder with pid $MENCODER_PID"
			# wait
			jshinfo "Mencoder has stopped."
			TOLINE_PID=`cat "$FIFOVO_MESSAGE_DIR"/toline.pid`
			[ "$TOLINE_PID" ] && verbosely kill "$TOLINE_PID"
			# MENCODER_PID=`cat "$FIFOVO_MESSAGE_DIR"/fifovo_encoder.pid`
			# [ "$MENCODER_PID" ] && verbosely kill -KILL "$MENCODER_PID"
		# ) | (
			# export TOLINE_LEAVE_REST=true
			# tr '' '\n' | cat | toline ".*trying to resync.*" &
			# TOLINE_PID="$!"
			# echo "$TOLINE_PID" > "$FIFOVO_MESSAGE_DIR"/toline.pid
			# wait
			# if [ "$?" = 0 ]
			# then jshinfo "Detected sync loss."
			# else jshwarn "Don't know why mencoder stopped."
			# fi
		) | (
			# toline "^Writing.*" ## Strangly if we do this it works, but the following doesn't show.
			export TOLINE_LEAVE_REST=true
			tr '' '\n' | cat | toline ".*trying to resync.*" # | tr '\n' ''
			# tr '' '\n' | cat |
			# pipeboth --line-buffered |
			# grep "trying to resync" |
			# while read ERRORLINE
			# do
				# jshinfo "Detected sync loss; killing mencoder..."
				# MENCODER_PID=`cat "$FIFOVO_MESSAGE_DIR"/fifovo_encoder.pid`
				# [ "$MENCODER_PID" ] && verbosely kill -KILL "$MENCODER_PID"
				# jshinfo "Detected sync loss; killing encoding thread..."
				# TOLINE_PID=`cat "$FIFOVO_MESSAGE_DIR"/toline.pid`
				# [ "$TOLINE_PID" ] && verbosely kill "$TOLINE_PID"
				# break
				jshinfo "Detected sync loss; exiting encoding thread..."
			# done
		) &
		TOLINE_PID="$!"
		echo "$TOLINE_PID" > "$FIFOVO_MESSAGE_DIR"/toline.pid
		# MENCODER_PID="$!"
		# echo "$MENCODER_PID" > "$FIFOVO_MESSAGE_DIR"/fifovo_encoder.pid
		wait

		# mencoder "$STREAM_SOURCE" -of mpeg -o "$ENCODED_FIFO" $ENCODING_OPTIONS 2>&1 |
		# cat |
		# toline -x ".*trying to resync.*"

		## The following try to get a stream out of mplayer directly, without mencoder.
		## In these cases, you need to change ENCODED_FIFO in init to whatever mplayer outputs to.

		## mpegpes:
		## Won't work for me cos I have no /dev/dvb/adapter0/video0+audio0
		# verbosely mplayer "$STREAM_SOURCE" -vo mpegpes 2>&1 |

		## yuv4mpeg:
		## This one works but it separates audio/video:
		# verbosely mplayer "$STREAM_SOURCE" -vo yuv4mpeg -ao pcm 2>&1 |

		# highlight ".*" yellow
		# cat

		# wget "$STREAM_SOURCE" -O - > "$ENCODED_FIFO"

		VQSCALE=`expr "$VQSCALE" + 2`
		jshwarn "Encoding stopped.  Increasing VQSCALE to $VQSCALE and re-running..."

		# ( cat /dev/zero > "$ENCODED_FIFO" ) &
		# ( cat /dev/zero > "$ENCODED_FIFO" ) &

		findjob mencoder

	done

}

saving_thread () {

	WRITING_BLOCK=0

	## CONSIDER: If this thread would be happy to switch input source, then
	## we could get the reencoder to start encoding a new video stream, into a new fifo, effectively "switching the channel".
	## Eg. here we could:
	##   while true; cat "$ENCODED_FIFO"; get_new_fifo || break; done |

	while [ ! -f "$FIFOVO_MESSAGE_DIR"/stop_everything ]
	do

		## CODE_TO_CHANGE_FIFO
		# while [ ! -f "$FIFOVO_MESSAGE_DIR"/newfifo ]
		# do sleep 5
		# done
		# if [ -f "$FIFOVO_MESSAGE_DIR"/newfifo ]
		# then
			# ENCODED_FIFO=`cat "$FIFOVO_MESSAGE_DIR"/newfifo`
			# rm -f "$FIFOVO_MESSAGE_DIR"/newfifo
			# jshinfo "Switching to read from new fifo: $ENCODED_FIFO"
		# fi
		## Well now it assumes that mplayer has dies and will restart,
		## so it just opens the same fifo.
		## But it might be neat to make it wait for a new fifo to be
		## defined by mencoder.

		# verbosely dd if="$ENCODED_FIFO" count=1024 bs=1000
		verbosely cat "$ENCODED_FIFO"

	done |

	# cat "$ENCODED_FIFO" |

	while true
	do

		jshinfo "Saving re-encoded stream into block $WRITING_BLOCK"
		echo "$WRITING_BLOCK" > "$CURRENT_WRITING_BLOCK_INFO_FILE"
		WRITING_BLOCK=`printf "%04i" "$WRITING_BLOCK"`
		FILE="$STREAM_DATA_DIR/streamed.$WRITING_BLOCK.mpeg"

		sleep 0.2 &

		verbosely dd count=$BLOCK_SIZE bs=1 of="$FILE"
		# dd count=$BLOCK_SIZE bs=1 of="$FILE"

		## Bad:
		# verbosely dd count=1 bs=$BLOCK_SIZE of="$FILE"

		# ## Seems worse:
		# TRANS_BLOCK_SIZE=`expr "$BLOCK_SIZE" / 1024`
		# # verbosely dd count=$TRANS_BLOCK_SIZE bs=1024 of="$FILE"
		# verbosely dd count=$TRANS_BLOCK_SIZE bs=1024 | cat > "$FILE" ## Breaks $?

		# verbosely dd count=$BLOCK_SIZE bs=1 | cat > "$FILE"

		## TODO: None of the above create the desired error exit code if no bytes were read.
		if [ ! "$?" = 0 ]
		then
			jshinfo "There was a problem reading from encoder; exiting..."
			return
		fi

		wait

		WRITING_BLOCK=`expr "$WRITING_BLOCK" + 1`
		if [ "$WRITING_BLOCK" -gt "$BUFFER_SIZE" ]
		then WRITING_BLOCK=1
		fi

		[ -f "$FIFOVO_MESSAGE_DIR"/stop_everything ] && break

	done

}

restreaming_thread () {

	jshinfo "Will start streaming once MPlayer starts..."

	CURRENT_STREAMING_BLOCK=0

	while true
	do

		## This paragraph lets you rewind the playing stream, eg.:
		##   echo "20" > "$FIFOVO_MESSAGE_DIR"/rewind
		## TODO: doesn't check whether you cross the boundary of the
		##       start of the ringbuffer (go too far back)
		if [ -f "$FIFOVO_MESSAGE_DIR"/rewind ]
		then
			DISTANCE=`cat "$FIFOVO_MESSAGE_DIR"/rewind`
			jshinfo "Rewinding $DISTANCE by blocks ($BLOCK_SIZE bytes each)"
			LAST_CURRENT_STREAMING_BLOCK="$CURRENT_STREAMING_BLOCK"
			CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" - $DISTANCE`
			if [ ! "$CURRENT_STREAMING_BLOCK" ]
			then
				echo "Error rewinding by \"$DISTANCE\" blocks."
				CURRENT_STREAMING_BLOCK="$LAST_CURRENT_STREAMING_BLOCK"
			fi
			if [ "$CURRENT_STREAMING_BLOCK" -lt 1 ]
			then CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" + "$BUFFER_SIZE"`
			fi
			jshinfo "Moved from $LAST_CURRENT_STREAMING_BLOCK to $CURRENT_STREAMING_BLOCK"
			jshwarn "Due to mplayers cache you may need to wait a moment for the change..."
			rm -f "$FIFOVO_MESSAGE_DIR"/rewind
		fi

		## Copied from previous; bugs and all:
		if [ -f "$FIFOVO_MESSAGE_DIR"/fastforward ]
		then
			DISTANCE=`cat "$FIFOVO_MESSAGE_DIR"/fastforward`
			jshinfo "Fast-forwarding $DISTANCE by blocks ($BLOCK_SIZE bytes each)"
			LAST_CURRENT_STREAMING_BLOCK="$CURRENT_STREAMING_BLOCK"
			CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" + $DISTANCE`
			if [ ! "$CURRENT_STREAMING_BLOCK" ]
			then
				echo "Error rewinding by \"$DISTANCE\" blocks."
				CURRENT_STREAMING_BLOCK="$LAST_CURRENT_STREAMING_BLOCK"
			fi
			if [ "$CURRENT_STREAMING_BLOCK" -gt "$BUFFER_SIZE" ]
			then CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" - "$BUFFER_SIZE"`
			fi
			jshinfo "Moved from $LAST_CURRENT_STREAMING_BLOCK to $CURRENT_STREAMING_BLOCK"
			jshwarn "Due to mplayers cache you may need to wait a moment for the change..."
			rm -f "$FIFOVO_MESSAGE_DIR"/fastforward
		fi

		if [ -f "$FIFOVO_MESSAGE_DIR"/start_recording ]
		then
			RECORDING_FILE=`cat "$FIFOVO_MESSAGE_DIR"/start_recording`
			rm -f "$FIFOVO_MESSAGE_DIR"/start_recording
			RECORDING=true
			RECORDING_NUM=0
			if [ ! "$RECORDING_FILE" ]
			then
				while [ -f ""$FIFOVO_MESSAGE_DIR"/recorded$RECORDING_NUM.mpeg" ]
				do RECORDING_NUM=`expr "$RECORDING_NUM" + 1`
				done
				RECORDING_FILE="$FIFOVO_MESSAGE_DIR"/recorded$RECORDING_NUM.mpeg
			fi
			jshinfo "Starting recording into $RECORDING_FILE"
			## We need to get the header of the original stream, so we import the first file streamed:
			## (this is why 0000 is never replaced btw.)
			verbosely cat "$STREAM_DATA_DIR/streamed.0000.mpeg" > "$RECORDING_FILE"
			## TODO: we really should rewind by the number of blocks which mplayer's buffer + the fifo accept,
			##       because these are before CURRENT_STREAMING_BLOCK but haven't yet played for the user.
			##       I'm not sure how to determine what size that is.  We _could_ make mplayer's buffer 0 (no it won't go below 32)!
			##       When they stop recording, they will have already got more saved than they have seen!
			jshwarn "Please note that you will get none of the stream currently in MPlayer's buffer."
		fi

		if [ -f "$FIFOVO_MESSAGE_DIR"/stop_recording ]
		then
			rm -f "$FIFOVO_MESSAGE_DIR"/stop_recording
			jshinfo "Stopping recording"
			RECORDING=
		fi

		while [ `cat "$CURRENT_WRITING_BLOCK_INFO_FILE"` = "$CURRENT_STREAMING_BLOCK" ]
		do
			if [ -f "$FIFOVO_MESSAGE_DIR"/stop_everything ]
			then break ## If the saving_thread has finished but was on the same block as the playing_thread is waiting for, then only this can break it out!
			fi
			# CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" - 1`
			jshwarn "Waiting for block $CURRENT_STREAMING_BLOCK to finish writing (and letting encoder get ahead)..."
			jshwarn "MPlayer may temporarily block; consider pausing for a moment, or rewind!"
			jshwarn "(The alternative is to wait longer before initially starting the player.)"
			jshwarn "Free up CPU to hasten the encoding (increase VQSCALE); or check network."
			verbosely sleep 15
		done

		jshinfo "Re-streaming to mplayer from block $CURRENT_STREAMING_BLOCK"

		CURRENT_STREAMING_BLOCK=`printf "%04i" "$CURRENT_STREAMING_BLOCK"`
		if [ "$RECORDING" ]
		then
			verbosely cat "$STREAM_DATA_DIR/streamed.$CURRENT_STREAMING_BLOCK.mpeg" >> "$RECORDING_FILE"
		fi
		# dd if="$STREAM_DATA_DIR/streamed.$CURRENT_STREAMING_BLOCK.mpeg" |
		# cat
		verbosely cat "$STREAM_DATA_DIR/streamed.$CURRENT_STREAMING_BLOCK.mpeg"

		if [ ! "$?" = 0 ]
		then
			jshinfo "There was a problem sending to player; breaking out."
			break
		fi

		CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" + 1`
		if [ "$CURRENT_STREAMING_BLOCK" -gt "$BUFFER_SIZE" ]
		then CURRENT_STREAMING_BLOCK=1
		fi

	done > "$PLAYER_FIFO"
	# done |

	# # dd of="$PLAYER_FIFO"
	# cat > "$PLAYER_FIFO" 2>&1 |
	# cat

}

playing_thread () {
	jshinfo "Giving the encoder a head-start before starting the player..."
	verbosely sleep 10
	verbosely mplayer -cache-prefill 99 "$PLAYER_FIFO" # | highlight ".*" green

	touch "$FIFOVO_MESSAGE_DIR"/stop_everything
	## Might not be needed:
	# jshinfo "Giving saving_thread and restreaming_thread time to die."
	# verbosely sleep 5
	# ENCODER_PID=`cat "$FIFOVO_MESSAGE_DIR"/fifovo_encoder.pid`
	# [ "$ENCODER_PID" ] && verbosely kill -KILL "$ENCODER_PID"
	# kill "$ENCODING_PID"
	true
}

## I don't know why but if you leave the ()s out it causes a nasty infloop!
initialise () {

	export STREAM_SOURCE="$1"
	shift

	[ "$TOTAL_BUFFER_SIZE_MEG" ] || export TOTAL_BUFFER_SIZE_MEG=20
	## With my machine (and now that we are reading and writing from files), I really needed to save the ringbuffer in memory (aka ramfs):
	## (Ah that is now no longer necessary, since I increased VQSCALE.)
	# export STREAM_DATA_DIR=/dev/shm/joey/
	## But you probably won't have one of them!
	[ "$STREAM_DATA_DIR" ] && [ -w "$STREAM_DATA_DIR" ] || export STREAM_DATA_DIR=/tmp
	export CURRENT_WRITING_BLOCK_INFO_FILE="$FIFOVO_MESSAGE_DIR"/current_block.info

	## Larger bits, less shell cycles:
	export BUFFER_SIZE=`expr 5 '*' $TOTAL_BUFFER_SIZE_MEG`
	export BLOCK_SIZE=`expr 10240 '*' 20`
	## Fine-grained buffer bits:
	# export BUFFER_SIZE=1000
	# export BLOCK_SIZE=`expr 1024 '*' $TOTAL_BUFFER_SIZE_MEG`

	export ENCODED_FIFO="/tmp/encoded.fifo"
	# export ENCODED_FIFO="./stream.yuv"
	export PLAYER_FIFO="/tmp/toplay.fifo"

	rm -f "$ENCODED_FIFO" "$PLAYER_FIFO"
	mkfifo "$ENCODED_FIFO"
	mkfifo "$PLAYER_FIFO"

	mkdir -p "$FIFOVO_MESSAGE_DIR"

	rm -f "$FIFOVO_MESSAGE_DIR"/stop_everything

	## Cleanup any previous nasties:
	echo | mykill -x saving_thread > /dev/null

	export GUIFYSCRIPT_TIMEOUT=5
	export XTERM_OPTS="-geometry 80x12"

	# export XTERM_OPTS=
	verbosely guifyscript sh "$0" -invokefunction encoding_thread "$STREAM_SOURCE" &
	ENCODING_PID="$!"
	echo "ENCODING_PID=$ENCODING_PID"

	# verbosely sleep 2
	sleep 0.5

	# export XTERM_OPTS="-geometry 80x10"
	verbosely guifyscript sh "$0" -invokefunction saving_thread &
	SAVING_PID="$!"
	echo "SAVING_PID=$SAVING_PID"

	# jshinfo "Giving the encoder a head-start before starting the player..."
	# verbosely sleep 5
	sleep 0.5

	# export XTERM_OPTS="-geometry 80x10"
	verbosely guifyscript sh "$0" -invokefunction restreaming_thread &
	## Didn't appear to help:
	# verbosely guifyscript -timeout 2 nice -n 15 sh "$0" restreaming_thread &
	RESTREAMING_PID="$!"
	echo "RESTREAMING_PID=$RESTREAMING_PID"

	# verbosely sleep 5
	sleep 0.5

	# export XTERM_OPTS=
	verbosely guifyscript sh "$0" -invokefunction playing_thread &
	PLAYER_PID="$!"
	echo "PLAYER_PID=$PLAYER_PID"

	sleep 1 ## Ensures the &-ed verbosely prints before the following does.

	curseyellow
	fifovohelp
	cursenorm

	wait

	rm -f "$ENCODED_FIFO" "$PLAYER_FIFO"
	rm -f "$FIFOVO_MESSAGE_DIR"/stop_everything

	## Cleanup any leftover nasties:
	echo | mykill -x saving_thread > /dev/null

}

fifovohelp () {
	echo
	echo "Commands you can send to fifovo:"
	echo "  echo 20 > $FIFOVO_MESSAGE_DIR/rewind"
	echo "  echo 10 > $FIFOVO_MESSAGE_DIR/fastforward"
	echo "  touch $FIFOVO_MESSAGE_DIR/start_recording"
	echo "    or        (NOTE: due to mplayer's cache, you should start recording early!)"
	echo "  echo \$HOME/save_recording_here.mpeg > $FIFOVO_MESSAGE_DIR/start_recording"
	echo "  touch $FIFOVO_MESSAGE_DIR/stop_recording"
	echo
	echo "To stop fifovo:"
	echo "  Press 'q' on the mplayer window, and wait for the other threads to stop."
	# echo "  and press Ctrl+C on the saving window."
	# echo "  If they don't, then press Ctrl+C here to close all remaining windows."
	# echo
	# echo "Hopefully you no longer need these:"
	echo "If that doesn't work, press Ctrl+C once on each spawned window.  You could also:"
	# echo "  kill -KILL $ENCODING_PID $SAVING_PID $RESTREAMING_PID $PLAYER_PID"
	echo "  killall -KILL mencoder mplayer"
	# echo "  killall \"$0\""
	# echo "  mykill -x saving_thread"
	echo
	echo "For better/faster encoding, export VQSCALE=<something less/more than $VQSCALE> ."
	echo
}

if [ "$1" = -invokefunction ]
then
	shift
	FUNCTION="$1"
	shift
	"$FUNCTION" "$@"
	exit
fi

if [ "$1" = "" ] || [ "$1" = --help ]
then
	
	echo
	echo "fifovo <url_of_stream>"
	echo
	echo "  Plays a streaming video, saving it in rotating files, and accepts messages"
	echo "  to rewind, fast-forward, or record the stream."
	fifovohelp
	exit 1

else

	initialise "$@"

fi
