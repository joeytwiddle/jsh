#!/bin/sh
## Uses mplayer to extract a wav/pcm file from the video/audio file.

## Needed for some .flv files (e.g. from YouTube)
fixTooManyPtsError="-nocorrect-pts"

for infile
do

	outfile="$infile.wav"

	## We can specify the filename, but get problems if $outfile contains ',' chars!
	# mplayer -noconsolecontrols $fixTooManyPtsError -vc null -vo null -ao pcm:fast:file="$outfile" "$infile"

	## So we go for default (audiodump.wav) instead, then rename after :P
	## -vo null hides the window, -vc dummy greatly improves speed.
	## There may or may not have been a good reason why we chose -vc null instead
	mplayer -noconsolecontrols $fixTooManyPtsError -vc null -vo null -ao pcm:fast "$infile" &&
	mv audiodump.wav "$outfile"

	## I think this might dump whatever format the audio is in the video
	# mplayer -dumpaudio "$infile" -dumpfile "$outfile"

done
