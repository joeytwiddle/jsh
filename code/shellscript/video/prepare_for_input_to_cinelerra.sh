if [ "$1" = -foolproof ]
then shift; FOOLPROOF=true
fi

# MEET_STANDARD="-vf scale=720:480 -ofps 30" ## NTSC
MEET_STANDARD="-vf scale=720:576 -ofps 25" ## PAL
## transcode: --export_fps 25,3 
# TC_CLIP="-c 200-600"
# TC_CLIP="-c 500-1200"

NOT_SO_BLUE=-k
RIGHT_WAY_UP=-z

for VIDEOFILE
do

	echo
	jshinfo "Doing: $VIDEOFILE"

	MPLAYER_OR_NOT="-x mplayer"

	if [ "$FOOLPROOF" ]
	then

		echo
		jshinfo "Doing simple re-encode with mplayer to make the process more foolproof..."

		if reencode_video_simple "$VIDEOFILE"
		then
			VIDEOFILE="$VIDEOFILE"-simple.avi
			MPLAYER_OR_NOT="$RIGHT_WAY_UP $NOT_SO_BLUE"
			## Note this makes the second attempts below identical to the first, except for the RIGHT_WAY_UP and NOT_SO_BLUE, and hence superfluous
		else jshwarn "Foolproof decode failed!"
		fi

		## Hehe sometimes -x mplayer below will not read the output!
		## But sometimes it reads from /dev/null and doesn't complain!
		## That's why -x mplayer is prioritised as second,
		## but I suspect we get the same problem sometimes without -x.
		## ok now it's prioritised first but switched off by MPLAYER_OR_NOT

		## TODO:
		## I still have problems:
		## with s11redux.wmv (and -foolproof), I need to reduce the size!
		## ok did that with -Q 2 but it's prolly bad - it's prolly related to the 1000fps hence 32identicaldrops!
		## ok sorted reencode_video_simple now has -ofps 25 =)

	fi

	# ## Joey converged upon split:
	# ## The -Q 3 graetly reduced size when converting from an ffmpeg divx, but there was quality reduction so comprimised with -Q 4
	# ## -w <n> seems to have no effect
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE-video.mov" -y mov,null -F mjpa -Q 4 $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE
	# # # ## Audio seemed better through vsound trplayer! ( -N 0x55 is mp3)
	# transcode -i "$VIDEOFILE" -N 0x1 -o "$VIDEOFILE-audio.wav" -y null,wav
	# transcode -i "$VIDEOFILE" -N 0x1     -o "$VIDEOFILE-video.mov" -y mov,null -F mjpa -Q 4 $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE
	# transcode -i "$VIDEOFILE" -x ffmpeg    -o "$VIDEOFILE-video.mov" -y mov,null -F mjpa -Q 4 $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE || continue

	echo
	jshinfo "Transcoding video"

	rm -f stream.yuv ## If not cleaned up (eg. due to crash), mplayer input plugin will not work
	transcode -i "$VIDEOFILE" $MPLAYER_OR_NOT -o "$VIDEOFILE-video.mov" -y mov,null -F mjpa -Q 4 $TC_CLIP $DOWNSAMPLE ||
	transcode -i "$VIDEOFILE"                 -o "$VIDEOFILE-video.mov" -y mov,null -F mjpa -Q 4 $TC_CLIP $DOWNSAMPLE || continue

	echo
	jshinfo "Transcoding audio"

	rm -f stream.yuv
	transcode -i "$VIDEOFILE" $MPLAYER_OR_NOT -o "$VIDEOFILE-audio.wav" -N 0x1 -y null,wav $TC_CLIP ||
	transcode -i "$VIDEOFILE"                 -o "$VIDEOFILE-audio.wav" -N 0x1 -y null,wav $TC_CLIP || continue
	## Haven't managed to get cinelerra reading mp3 (smaller files)
	# transcode -i "$VIDEOFILE" -x mplayer -N 0x55 -o "$VIDEOFILE-audio" -y null,lame $TC_CLIP || continue
	# transcode -i "$VIDEOFILE" -x mplayer -N 0x50 -o "$VIDEOFILE-audio" -y null,mp2enc $TC_CLIP || continue

	# mencoder "$VIDEOFILE" -o "$VIDEOFILE"-video.mpeg -oac raw -nosound -ovc lavc -lavcopts vcodec=mpeg4 # $MEET_STANDARD || continue
	# mencoder $VIDEOFILE" -dumpaudio "$VIDEOFILE"-audio.mp3 -o /dev/null -oac mp3lame -ovc lavc -lavcopts vcodec=mpeg4 # $MEET_STANDARD || continue

	#### WIKI says:
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.avi" -y divx4
	# transcode -i "$VIDEOFILE" -x mplayer -o "$VIDEOFILE.yuv" -y yuv4mpeg
	# or http://www.theorie.physik.uni-goettingen.de/~ostreich/transcode/
	#------------
	# mencoder "$VIDEOFILE" -o "$VIDEOFILE.mpeg4" -ovc lavc -lavcopts vcodec=mpeg4:vhq:vbitrate=300 -oac mp3lame -lameopts br=64:vol=1
	# mencoder "$VIDEOFILE" -o "$VIDEOFILE.yuv" -ovc rawyuv -oac copy
	#------------
	## Nicely readable by MPlayer but not by Cinerella!
	# ffmpeg -sameq -i "$VIDEOFILE" "$VIDEOFILE".mpeg
	#------------
	## video:
	# lav2yuv "$VIDEOFILE" | mpeg2enc -o output.m1v &&
	## audio:
	# lav2wav "$VIDEOFILE" | mp2enc -o output.mp2 &&
	## mixing audio & video:
	# mplex output.mp2 output.m1v -o new_video.m1v

	## Recommendations for Cinelerra:
	# Mine failed: transcode -i re_encoded.avi -y raw -o re_encoded_for_cinelerra.avi
	## mencoder input.avi -ovc rawyuv -oac copy -o output.avi
	## transcode -i test.mov -x mplayer -o output.mpg -y yuv4mpeg
	## ffmpeg -sameq ORIGINAL.avi new_video.mpeg
	# mencoder "$@" $CLIPOPTS -ovc libdv -oac pcm $MEET_STANDARD -o re_encoded.dv
	## Nope none of the above work, and none of the below!
	# mencoder "$@" $CLIPOPTS -o re_encoded.avi -ovc libdv $AUDIO $MEET_STANDARD || continue
	# transcode -i re_encoded.avi -x mplayer -o output.mpg -y yuv4mpeg
	# dv2dv ./re_encoded.avi ./final_dv.avi

	# mencoder "$VIDEOFILE" -o "$VIDEOFILE".raw -ovc raw $AUDIO # $MEET_STANDARD || continue
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.avi" -y raw

	# transcode -J modfps --export_fps 25,3 -i "$VIDEOFILE" -E 44100,8,2 -k -o ~/stage1 -y mpeg2enc,mp2enc -N 0x50 -F "3, -M 2"
	# mplex -V -f 3 -r 2000 -o final.mpg stage1.m2v stage1.mpa
	# transcode -J modfps -i "$VIDEOFILE" -k -o ~/stage1 -y mpeg2enc,mp2enc -F "3, -M 2"
	# mplex -V -f 3 -r 2000 -o final.mpg stage1.m2v stage1.mpa
	# mpeg3toc /home/daniel/final.mpg final.toc
	# rm stage1.m2v
	# rm stage1.mpa

	### This method just about works but things seem a bit choppy in cinelerra.  Who's fault is it?!
	### Hmmm it appears to be the avi's fault because initial attempts with avidemux gave similar results.
	## audio only: -F cvid
	## I got a long list of other quicktime mov internal formats for -F here: http://brennan.young.net/Comp/LiveStage/things.html
	## Appear upside-down and blue in Cinelerra without these:
	# DOWNSAMPLE="-E 44100,8,2 --export_fps 25,3 -r 2"
	## Slower to encode but smaller on disk:
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.mov" -N 0x1 -y mov $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE ## same as next!
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.mov" -N 0x1 -y mov -F mjpa $NOT_SO_BLUE $RIGHT_WAY_UP
	## Faster to encode but larger on disk:
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.mov" -N 0x1 -y mov -F yv12 $NOT_SO_BLUE $RIGHT_WAY_UP
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.mov" -N 0x1 -y mov -F yuv2 $NOT_SO_BLUE $RIGHT_WAY_UP

	# mencoder "$VIDEOFILE" -o "$VIDEOFILE".ljpg -oac pcm -ovc lavc -lavcopts vcodec=ljpeg $AUDIO # $MEET_STANDARD || continue
	# mencoder "$VIDEOFILE" -o "$VIDEOFILE".mpeg -oac pcm -ovc lavc -lavcopts vcodec=mpeg4 # $MEET_STANDARD || continue

	## Best so far has been:
	# mencoder "$VIDEOFILE" -o "$VIDEOFILE".avi -ovc lavc $AUDIO # $MEET_STANDARD || continue

	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.mpg" -N 0x1 -F 3 -y mpeg2enc,mp2enc $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE ## same as next!

	# # ## Does ok-ish:
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE-video.mov" -y mov,null -F yv12 $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE-video.mov" -y mov,null -F mjpa $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE

	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.mov" -y mov,lame -F mjpa -Q 4 $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE
	## Cinelerra doesn't notice the lame or mp2enc'ed audio
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.mov" -y mov,lame -F mjpa -Q 4 $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE
	# transcode -i "$VIDEOFILE" -o "$VIDEOFILE.mov" -y mov,mp2enc -F mjpa -Q 4 $NOT_SO_BLUE $RIGHT_WAY_UP $DOWNSAMPLE

	## Cinelerra reads these but they are not good when read!
	# mencoder "$@" $CLIPOPTS -o re_encoded.avi -ovc libdv $AUDIO $MEET_STANDARD || continue
	# transcode -i re_encoded.avi -y dv -o re_encoded.dv
	# transcode -i re_encoded.avi -y dvraw -o re_encoded.dvraw

	# mencoder "$VIDEOFILE" -o "$VIDEOFILE".mpeg -oac pcm -ovc lavc -lavcopts vcodec=mjpeg # $MEET_STANDARD || continue
	# mencoder "$VIDEOFILE" -o "$VIDEOFILE".mpeg.avi -of avi -oac mp3lame -ovc lavc -lavcopts vcodec=mpeg4 # $MEET_STANDARD || continue
	# mencoder "$VIDEOFILE" -o "$VIDEOFILE".mpeg -of mpeg -oac mp3lame -ovc lavc -lavcopts vcodec=mpeg4 # $MEET_STANDARD || continue
	# mencoder "$VIDEOFILE" -o "$VIDEOFILE".avi -of avi -oac pcm -ovc lavc -lavcopts vcodec=mpeg4 $MEET_STANDARD || continue

done

## Cinelerra output:

## If you output two mpeg's, you can:
# mplayer ./out-video.mpeg -audiofile ./out-audio.mpeg

## If you output Quicktime for Linux, but you can't read it, convert it with:
# transcode -i ./out.qt -o ./out2.mpg -y divx5 -z -k
## note the .qt's tent to be pretty large, because the audio is PCM

## No idea what to do with Cinelerra's M$ AVI output.
