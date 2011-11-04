#!/bin/bash
. require_exes bladeenc mp3info
# @see-also convert_to_ogg

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

for INFILE
do

	set -e   ## We don't want it to look like we succeeded if something went wrong!

	extract_audio_from_video "$INFILE" | tee info.tmp 2>&1

	artist="`extract_info artist`"
	title="`extract_info title`"
	album="`extract_info album`"
	date="`extract_info date`"
	genre="`extract_info genre`"
	composer="`extract_info composer`"

	bladeenc $EXTRA_BLADEENC_OPTS -QUIT "$INFILE".wav

	rm "$INFILE".wav
	# mv "$INFILE.ogg" "$artist - $title".ogg

	## Rename the final file (strip the original extension)
	outfile="`echo "$INFILE" | sed 's+\.[^.]*$++'`".mp3
	mv "$INFILE".mp3 "$outfile"

	mp3info -a "$artist" -l "$album" -t "$title" -y "$date" -g "$genre" -c "$composer" "$outfile"

done

rm info.tmp

