## fifovo: Plays a streaming video, saving it in rotating files,
##         and accepts messages to rewind, fast-forward, or record the stream.

## TODO: change channel feature: requires that something kill mencoder, then it may load new channel.
##       but this would have a small overhead, so if the player is caught up with the encoding, it will stall
##       it's complicated to get round this; we need to start a new mencoder piping to a different socket; the saving stream should switch input socket as soon as the new socket gets input; might we need a second saving stream to detect this, and halt its sibling?

## TODO: Remaining BUG that mencoder starts two processes but only the parent one dies.
##       I think it might be ok if we kill mplayer with a -KILL, but at the moment we don't bg it.

## TODO: Time Management
##       Either: Loop dd-ing until 10seconds is up, then progress, gettings blocks of ~10secs.
##       Or: Record time taken to save each block, to get length-meta for each block.
##       Note: Don't obtain timing relatively in the shell with sleep; that's dodgy.
##             Instead use date relative to some absolute.
##       Either is nicer than Or cos it sorta guarantees buffer duration (altho not size!).
##       WAIT: consider this: time that encoder gives us bits of stream is not the same time that it is in the stream (although it is on average, so we could assume a line of best fit!)

## TODO: how about implementing that messaging framework eh?
##       if saving and restreaming threads both message their positions, we can create maxforward and maxback :)

## TODO: If playing stream has paused at block 10 (or is just being slower to playback than encode),
##       when saving stream reaches 9, it should start creating new files rather than overtaking / overwriting the playing thread / stream.
## TODO: Yes, there is no management for overlap (either when rewind/fast-forwarding, or when paused or even just when streaming at different speeds).
##       It is never really desirable to pause the encoding thread, so in circumstances of unavoidable overlap, we should create more files (increase buffer size _globally_).

## BUG: Doesn't currently work for rtsp because for mencoder to encode rtsp, it requires output formats that do not suit our fifo trick

## TODO: Try what Rande on #freevo said: "mplayer will play anything and output to mpegpes"
## and previously: <Rande> ahh.  yes - recoding on the fly is how a lot of 'streamer' products work.  actually, you should be able to do it with mplayer - just get it to play the stream and -vo mpegpes to the fifo
## Unfortunately, -vo mpegpes does not work on my system.
## But I can use -vo yuv4mpeg and -ao pcm to create stream.yuv and audiodump.wav!

## TODO: maybe we should add a buffer so that mencoder has more time to encode before mplayer plays; seems ok right now though (mplayer caches till it can play, then plays)

## Also TODO: add a higher resolution (smaller byte-block) pipe for more fine-controlled merging / splitting
##            and a meta-manager which knows the duration of video which each file in the ringbuffer spans.

## See also: transcode has a --avi_limit MB option, which will produce multiple files...

# jsh-depends: guifyscript verbosely jshinfo curseyellow cursenorm mykill jshwarn toline
# jsh-ext-depends: mencoder mkfifo mplayer seq tee
# jsh-depends-ignore: mplayer before findjob
# jsh-ext-depends-ignore: from killall size less sync

## These vars are here and not in initialise, because they are needed for --help.

## Reduce this to encode at better quality, if you have a fast enough machine.
## (Check that your encoding_thead is managing one second of stream every second!)
## My poor computer needs to encode at low quality, just in case demoscene.tv is playing a very detailed video!
[ "$VQSCALE" ] || export VQSCALE="10"

export FIFOVO_MESSAGE_DIR=/tmp/fifovo

unbuffered_tr () {
	## We use tr to scan mencoder's output, but tr's buffer causes final user output to burst in blocks.
	## If we want continuous output from mencoder to user, then we can do this:
	if [ "$MORE_PRETTY_LESS_EFFICIENT" ]
	then
		## TODO BUG: this doesn't catch sync loss which is a problem!  (Well, maybe it catches it, but it doesn't exit cleanly.)
		while true
		do nice -n 15 dd bs=200 count=1 2>/dev/null | nice -n 15 tr "$@" || break
		done
	else
		## this still catches sync loss :)
		nice tr "$@"
	fi
}

encoding_thread () {

	# ENCODING_NUM=0

	while [ ! -f "$FIFOVO_MESSAGE_DIR"/stop_everything ]
	do

		MENCODER_OUTPUT_FORMAT="-of mpeg" ## Needed for the ones I got working

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
		## Often nasty (might work on some stream formats, but didn't for demoscene.tv):
		# ENCODING_OPTIONS="-oac copy -ovc copy"
		## This successfully encodes RTSP, but doesn't create a stream playable from a fifo or even a file :(  In fact it is probably encoding into fifo that failed.
		# ENCODING_OPTIONS="-oac pcm -ovc lavc -lavcopts vqscale=6"

		## Audio and video playback OK provided -of mpeg below:
		# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts acodec=mp3:vcodec=mpeg2video:vqscale=6"

		## Seems OK but expensive for CPU unless we increase vqscale:
		# ENCODING_OPTIONS="-oac mp3lame -ovc lavc -lavcopts vcodec=mpeg1video:vqscale=6"
		## One time the video did not play on one clip:
		# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vcodec=mpeg2video:vqscale=2"
		# OPTIMISATION_ATTEMPT="vhq:dia=-3:subq=4" # :last_pred=20
		ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vcodec=mpeg2video:vqscale=$VQSCALE:$OPTIMISATION_ATTEMPT"

		## Got this working one time; survived the nonsense at start, then seemed ok.  So it's maybe just the start that is the problem.
		## Much easier on CPU.  But can it be recorded?  Probably equally buggy for recording :-( .
		## Hmmm haven't even successfully rewound yet!
		# ENCODING_OPTIONS="-oac lavc -ovc copy"
		# MENCODER_OUTPUT_FORMAT="-of avi"

		## Unfortunately I couldn't get the lossless codecs to play back (well not automatically)!
		# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vcodec=ffv1:vstrict=-1" ## slow cos big or broken, requires NOT -of mpeg
		# MENCODER_OUTPUT_FORMAT=
		# ENCODING_OPTIONS="-oac lavc -ovc lavc -lavcopts vcodec=ljpeg" ## slow cos big or broken, requires -of mpeg

		## I thought a cache might buffer input if mencoder was temporarily slow
		## but 1) mencoder doesn't seem to use it; 2) when mplayer uses it, it's a pre-cache not post-cache, so it starts full not empty!
		## Left it in anyway!
		MENCODER_OPTS="$MENCODER_OPTS -cache 2000" ## Hey don't do that, we are in a loop!  (Bring all these outside loop, but not vqscale.)

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
			if [ "$USE_MPLAYER_MPEGPES_NOT_MENCODER" ]
			# then verbosely unj mplayer -x 100 -cache 3000 "$STREAM_SOURCE" -vo mpegpes -ao mpegpes 2>&1
			then
				verbosely unj mplayer -cache 3000 "$STREAM_SOURCE" \
					-vo mpegpes:"$ENCODED_FIFO" -vf lavc=$VQSCALE \
					-ao mpegpes:"$ENCODED_FIFO" -af-adv force=2 2>&1
			else
				verbosely mencoder "$STREAM_SOURCE" \
					$MENCODER_OUTPUT_FORMAT -o "$ENCODED_FIFO" $MENCODER_OPTS $ENCODING_OPTIONS 2>&1
			fi
			# MENCODER_PID="$!"
			# jshinfo "FYI MENCODER_PID was $MENCODER_PID"
			# echo "$MENCODER_PID" > "$FIFOVO_MESSAGE_DIR"/fifovo_encoder.pid
			# jshinfo "Started mencoder with pid $MENCODER_PID"
			# wait
			jshinfo "Mencoder has stopped."
			TOLINE_PID=`cat "$FIFOVO_MESSAGE_DIR"/toline.pid`
			if [ "$TOLINE_PID" ]
			then
				jshinfo "Killing encoding pipe $TOLINE_PID"
				verbosely kill "$TOLINE_PID" ## Course it might have happily exited already!
			fi
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
			## Either td or toline's awk is causing buffering which means output is not continuous (ever 3 secs).
			export TOLINE_LEAVE_REST=true
			## Print initial mencoder info normally (optional):
			# unbuffered_tr '' '\n' | toline "^(Writing|Starting).*" ## Strangely if we do this it works, but the following doesn't show.  Ah, before I tr-ed here, the awk never finished reading that last long line!
			unbuffered_tr '' '\n' | toline "^(Pos|A):.*" ## Strangely if we do this it works, but the following doesn't show.  Ah, before I tr-ed here, the awk never finished reading that last long line!
			## Watch for any errors reporting sync loss:
			unbuffered_tr '' '\n' | toline ".*rying to resync.*" |
			unbuffered_tr '\n' '' ## optional
			echo
			jshinfo "Detected sync loss; exiting encoding thread..."
			## Earlier attempts:
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
				# jshinfo "Detected sync loss; exiting encoding thread..."
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
		[ "$VQSCALE" -gt 30 ] && VQSCALE=30
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

		jshinfo "Saving re-encoded stream into block $WRITING_BLOCK / $TOTAL_BLOCKS"
		echo "$WRITING_BLOCK" > "$CURRENT_WRITING_BLOCK_INFO_FILE"
		WRITING_BLOCK=`printf "%04i" "$WRITING_BLOCK"`
		FILE="$STREAM_DATA_DIR/streamed.$WRITING_BLOCK.mpeg"

		## This method uses too much CPU:
		# # dd count=$BLOCK_SIZE bs=1 of="$FILE"
		# verbosely dd count=$BLOCK_SIZE bs=1 of="$FILE"
		# verbosely nice -n 18 dd count=$BLOCK_SIZE bs=1 of="$FILE"

		## This one appears to drop out early if there is nothing immediate to read from stream.
		## Can be sort of fixed with the sleep/wait:
		# # sleep 2 & ## But how do we know what amount is appropriate?
		# verbosely dd count=1 bs=$BLOCK_SIZE of="$FILE"
		# ## For the record, this is even worse:!
		# # verbosely dd count=1 ibs=$BLOCK_SIZE obs=$BLOCK_SIZE of="$FILE"
		# # wait

		## Better, compromise:
		COUNT=`expr "$BLOCK_SIZE" / 1024`
		# # COUNT=`expr "$BLOCK_SIZE"`
		BS=1024
		verbosely dd count=$COUNT bs=$BS of="$FILE"
		## Helps free some CPU for encoder, but should be reduced if blocks are copied really quickly:
		verbosely sleep 0.2 # ideally we would only sleep if we observed that much less than max bytes were available for reading
		## Is this really releasing CPU or is it just causing mencoder to halt while the fifo blocks?!

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

		WRITING_BLOCK=`expr "$WRITING_BLOCK" + 1`
		if [ "$WRITING_BLOCK" -gt "$TOTAL_BLOCKS" ]
		then WRITING_BLOCK=1
		fi

		[ -f "$FIFOVO_MESSAGE_DIR"/stop_everything ] && break

	done

}

restreaming_thread () {

	jshinfo "Will start streaming when MPlayer starts..."

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
			then CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" + "$TOTAL_BLOCKS"`
			fi
			jshinfo "Moved from $LAST_CURRENT_STREAMING_BLOCK to $CURRENT_STREAMING_BLOCK"
			jshwarn "Due to mplayers cache you may need to wait a moment for the change..."
			rm -f "$FIFOVO_MESSAGE_DIR"/rewind
		fi

		## TODO: Might be a nice feature, if they are recording, but forwardwind, to
		##       record all the inbetween streams, but just forwardwing the player.

		## Copied from previous; bugs and all:
		if [ -f "$FIFOVO_MESSAGE_DIR"/fastforward ]
		then
			DISTANCE=`cat "$FIFOVO_MESSAGE_DIR"/fastforward`
			jshinfo "Fast-forwarding $DISTANCE by blocks ($BLOCK_SIZE bytes each)"
			LAST_CURRENT_STREAMING_BLOCK="$CURRENT_STREAMING_BLOCK"
			CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" + $DISTANCE`
			if [ ! "$CURRENT_STREAMING_BLOCK" ]
			then
				echo "Error fast-forwarding by \"$DISTANCE\" blocks."
				CURRENT_STREAMING_BLOCK="$LAST_CURRENT_STREAMING_BLOCK"
			fi
			if [ "$CURRENT_STREAMING_BLOCK" -gt "$TOTAL_BLOCKS" ]
			then CURRENT_STREAMING_BLOCK=`expr "$CURRENT_STREAMING_BLOCK" - "$TOTAL_BLOCKS"`
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
				while [ -f "$FIFOVO_MESSAGE_DIR"/recorded$RECORDING_NUM.mpeg ]
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
			jshwarn "MPlayer may temporarily stall; consider pausing for a moment, or rewind!"
			jshwarn "(The alternative is to wait longer before initially starting the player.)"
			jshwarn "If you see this message often, then your encoder is encoding too slowly!"
			jshwarn "Free up CPU to hasten the encoding (increase VQSCALE); or check network."
			verbosely sleep 15
		done

		jshinfo "Re-streaming to mplayer from block $CURRENT_STREAMING_BLOCK / $TOTAL_BLOCKS"

		CURRENT_STREAMING_BLOCK=`printf "%04i" "$CURRENT_STREAMING_BLOCK"`
		if [ "$RECORDING" ]
		then
			jshinfo "Also saving block $CURRENT_STREAMING_BLOCK to $RECORDING_FILE"
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
		if [ "$CURRENT_STREAMING_BLOCK" -gt "$TOTAL_BLOCKS" ]
		then CURRENT_STREAMING_BLOCK=1
		fi

	done > "$PLAYER_FIFO"
	# done |

	# # dd of="$PLAYER_FIFO"
	# cat > "$PLAYER_FIFO" 2>&1 |
	# cat

}

playing_thread () {
	# PLAYER_CACHE=32 ## Ideally we would use mplayer's minimum but it requires too much live dd-ing (gobbles CPU)!
	PLAYER_CACHE=128 ## This works OK on my system
	# PLAYER_CACHE=512
	# PLAYER_CACHE=2048 ## Too slow really
	## But for mpegpes:
	# PLAYER_CACHE=4096 ## Tried to make mpegpes stream better but didn't actually help
	jshinfo "Giving the encoder a head-start before starting the player..."
	verbosely sleep 10
	if [ "$USE_MPLAYER_MPEGPES_NOT_MENCODER" ]
	then
		PLAYER_CACHE=2048
		MPLAYER_OPTS="$MPLAYER_OPTS -speed 1.0"
	fi
	## Not recognised by gentoo's mplayer: -cache-prefill 99 
	verbosely unj mplayer $MPLAYER_OPTS -cache "$PLAYER_CACHE" "$PLAYER_FIFO" # | highlight ".*" green

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

	[ "$BUFFER_SIZE_MEG" ] || export BUFFER_SIZE_MEG=20
	## With my machine (and now that we are reading and writing from files), I really needed to save the ringbuffer in memory (aka ramfs):
	## (Ah that is now no longer necessary, since I increased VQSCALE.)
	# export STREAM_DATA_DIR=/dev/shm/joey/
	## But you probably won't have one of them!
	[ "$STREAM_DATA_DIR" ] && [ -w "$STREAM_DATA_DIR" ] || export STREAM_DATA_DIR=/tmp
	export CURRENT_WRITING_BLOCK_INFO_FILE="$FIFOVO_MESSAGE_DIR"/current_block.info

	if [ ! "$DONT_USE_MPEGPES" ] && unj mplayer -vo help | grep "mpegpes.*Mpeg-PES file" >/dev/null
	then
		export USE_MPLAYER_MPEGPES_NOT_MENCODER=true
		# export ENCODED_FIFO=$PWD/grab.mpg
		jshinfo "Using mplayer with mpegpes output instead of mencoder :)"
	fi

	## Fine-grained buffer bits:
	# export TOTAL_BLOCKS=1000
	# export BLOCK_SIZE=`expr 1024 '*' $BUFFER_SIZE_MEG`
	if [ "$USE_MPLAYER_MPEGPES_NOT_MENCODER" ]
	then
		## Even larger:
		# export TOTAL_BLOCKS=`expr 1 '*' $BUFFER_SIZE_MEG`
		export BLOCK_SIZE=`expr 1024 '*' 1024` ## 1Meg
	else
		## Larger bits, less shell cycles:
		# export TOTAL_BLOCKS=`expr 5 '*' $BUFFER_SIZE_MEG`
		export BLOCK_SIZE=`expr 1024 '*' 200` ## 200k
	fi
	export TOTAL_BLOCKS=`expr "$BUFFER_SIZE_MEG" '*' 1024 '*' 1024 / "$BLOCK_SIZE"`
	jshinfo "TOTAL_BLOCKS=$TOTAL_BLOCKS"

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

	export GUIFYSCRIPT_TIMEOUT=2
	export XTERM_OPTS="-geometry 80x12"

	# export XTERM_OPTS=
	guifyscript sh "$0" -invokefunction encoding_thread "$STREAM_SOURCE" &
	ENCODING_PID="$!"
	# echo "ENCODING_PID=$ENCODING_PID"

	# verbosely sleep 2
	sleep 0.5

	# export XTERM_OPTS="-geometry 80x10"
	# verbosely guifyscript sh "$0" -invokefunction saving_thread &
	guifyscript nice -n 5 sh "$0" -invokefunction saving_thread &
	SAVING_PID="$!"
	# echo "SAVING_PID=$SAVING_PID"

	# jshinfo "Giving the encoder a head-start before starting the player..."
	# verbosely sleep 5
	sleep 0.5

	# export XTERM_OPTS="-geometry 80x10"
	# verbosely guifyscript sh "$0" -invokefunction restreaming_thread &
	## Didn't appear to help:
	guifyscript nice -n 5 sh "$0" -invokefunction restreaming_thread &
	RESTREAMING_PID="$!"
	# echo "RESTREAMING_PID=$RESTREAMING_PID"

	# verbosely sleep 5
	sleep 0.5

	# export XTERM_OPTS=
	guifyscript sh "$0" -invokefunction playing_thread &
	PLAYER_PID="$!"
	# echo "PLAYER_PID=$PLAYER_PID"

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
	echo "Commands you can send to fifovo as it runs:"
	echo "  echo 20 > $FIFOVO_MESSAGE_DIR/rewind"
	echo "  echo 10 > $FIFOVO_MESSAGE_DIR/fastforward"
	echo "  touch $FIFOVO_MESSAGE_DIR/start_recording"
	echo "  echo \$HOME/save_recording_here.mpeg > $FIFOVO_MESSAGE_DIR/start_recording"
	echo "  touch $FIFOVO_MESSAGE_DIR/stop_recording"
	# echo "(NOTE: due to mplayer's cache, you should start recording early!)"
	echo
	echo "To stop fifovo:"
	echo "  Press 'q' on the mplayer window, and wait for the other threads to stop."
	# echo "  and press Ctrl+C on the saving window."
	# echo "  If they don't, then press Ctrl+C here to close all remaining windows."
	# echo
	# echo "Hopefully you no longer need these:"
	echo "  If that doesn't work, press Ctrl+C once on each spawned window (playing_thread first!), or Ctrl+C here; and then: killall -KILL mencoder mplayer"
	# echo "  kill -KILL $ENCODING_PID $SAVING_PID $RESTREAMING_PID $PLAYER_PID"
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
	echo
	echo "  Options: BUFFER_SIZE_MEG, DONT_USE_MPEGPES, MPLAYER_OPTS, MENCODER_OPTS."
	fifovohelp
	exit 1

else

	initialise "$@"

fi
