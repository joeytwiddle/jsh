#!/bin/bash
. require_exes mp3info
# bladeenc or lame
# @see-also convert_to_ogg

set -e

if [ "$1" = --help ]
then
cat << !

convert_to_mp3 <audio_or_video_file>

  Converts the given audio files to mp3 format, preserving any metadata that
  mplayer displays.

  You can provide parameters EXTRA_MPLAYER_OPTS and EXTRA_BLADEENC_OPTS.

  Bladeenc requires input wavs at 32, 44.1 or 48 kHz.  If bladeenc complains
  about the input sample rate, try: export EXTRA_MPLAYER_OPTS="-srate 44100"

  To encode a high bitrate mp3: export EXTRA_BLADEENC_OPTS="-320"

  Or to encode a low quality mp3: export EXTRA_BLADEENC_OPTS="-64 -MONO"

!
exit 0
fi

extract_info() {
	cat info.tmp | grep "^ $1: " | afterfirst ": "
}

## Be gentle:
which renice >/dev/null && renice -n 10 -p $$
which ionice >/dev/null && ionice -c 3 -p $$

for INFILE
do

	set -e   ## We don't want it to look like we succeeded if something went wrong!

	dump_audio_from "$INFILE" | tee info.tmp 2>&1
	## dump_audio_from always creates $INFILE.wav
	wavfile="$INFILE.wav"

	artist="`extract_info artist`"
	title="`extract_info title`"
	album="`extract_info album`"
	date="`extract_info date`"
	genre="`extract_info genre`"
	composer="`extract_info composer`"

	if which ffmpeg >/dev/null
	then

		#ffmpeg  -ab -i 20110928-210058_do.wav  20110928-210058_do_test.mp3

	elif which lame >/dev/null

		mp3file="$INFILE.$$.mp3"
		lame "$wavfile" "$mp3file"

	elif which bladeenc >/dev/null

		# We can't send to $mp3file here, bladeenc always outputs .mp3 filename, with .wav removed.
		bladeenc $EXTRA_BLADEENC_OPTS -QUIT "$wavfile"
		# bladeenc always creates $wavfile.mp3
		# bladeenc always creates $INFILE.mp3
		mp3file="$INFILE.mp3"

	else

		echo "Could not find an mp3 encoder.  (Install lame, ffmpeg or bladeenc.)"
		exit 5

	fi

	rm "$wavfile"

	## Rename the final file (strip the original extension)
	# mv "$mp3file" "$artist - $title".ogg
	outfile="`echo "$INFILE" | sed 's+\.[^.]*$++'`".mp3
	verbosely mv "$mp3file" "$outfile"

	mp3info -a "$artist" -l "$album" -t "$title" -y "$date" -g "$genre" -c "$composer" "$outfile"

	echo
	nicels -l "$INFILE" "$mp3file" "$outfile" 2>/dev/null || true   # Avoid returning 2
	echo

done

rm info.tmp

