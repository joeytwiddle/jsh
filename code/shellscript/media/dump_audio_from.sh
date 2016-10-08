#!/bin/sh

## Uses mplayer to extract a wav/pcm file from the video/audio file.

## This is a foolproof way of extracting audio frmo a video, with the
## disadvantage that wav files take a lot of space!
## The extract_audio_from_video is prone to failures.

## EXTRA_MPLAYER_OPTS might include things like: -srate 44100

## Needed for some .flv files (e.g. from YouTube)
fixTooManyPtsError="-nocorrect-pts"

## Dumping a large wav file can be heavy on I/O so:
which renice >/dev/null && renice -n 10 -p $$
which ionice >/dev/null && ionice -c 3 -p $$

for infile
do

	set -e   ## We don't want it to look like we succeeded if something went wrong!

	## convert_to_ogg/mp3 expect this output name, so don't change it!
	outfile="$infile.wav"

	## We can specify the filename, but get problems if $outfile contains ',' chars!
	# mplayer -noconsolecontrols $fixTooManyPtsError -vc null -vo null -ao pcm:fast:file="$outfile" "$infile"

	## So we go for default (audiodump.wav) instead, then rename after :P
	## -vo null hides the window
	## -vc dummy greatly improves speed, but used to crash sometimes (before fixTooManyPtsError fix).
	## TODO: Perhaps we should export to $$.wav, so that multiple processes will not collide on audiodump.wav
	## and to /dev/shm/$$.wav if possible (and requested mmm)!
	mplayer -noconsolecontrols $fixTooManyPtsError $EXTRA_MPLAYER_OPTS -vc null -vo null -ao pcm:fast "$infile" &&
	mv audiodump.wav "$outfile"

	## I think this might dump whatever format the audio is in the video
	# mplayer -dumpaudio "$infile" -dumpfile "$outfile"

done

