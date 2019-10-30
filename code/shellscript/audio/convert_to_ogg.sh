#!/bin/bash
. require_exes oggenc
# @see-also convert_to_mp3

if [ "$1" = "" ] || [ "$1" = --help ]
then
cat << !

convert_to_ogg <audio_or_video_files>...

  Converts the given audio files to ogg format, preserving any metadata that
  mplayer displays.

  You can provide optional parameters EXTRA_MPLAYER_OPTS and EXTRA_OGGENC_OPTS.

  For example to encode a low quality ogg, do the following before converting:

  export EXTRA_MPLAYER_OPTS="-srate 32000"
  export EXTRA_OGGENC_OPTS="-q 0.5 --downmix"

  -q 1.0 will produce a  80kbit ogg
  -q 2.0 will produce a  96kbit ogg
  -q 3.0 will produce a 112kbit ogg

!
exit 0
fi

extract_info() {
	cat info.tmp.$$ | grep "^ $1: " | afterfirst ": "
}

## Be gentle:
which renice >/dev/null 2>&1 && renice -n 10 -p $$
which ionice >/dev/null 2>&1 && ionice -c 3 -p $$

for INFILE
do

	## We don't want it to look like we succeeded if something went wrong!
	set -e

	dump_audio_from "$INFILE" | tee info.tmp.$$ 2>&1
	## Should create $INFILE.wav

	artist="`extract_info artist`"
	title="`extract_info title`"
	album="`extract_info album`"
	date="`extract_info date`"
	genre="`extract_info genre`"
	composer="`extract_info composer`"
	## Ogg doesn't have a composer field, but it does have a comment field :P

	## For players which do not respect replaygain tags, we normalize the raw audio.
	if which normalize-audio >/dev/null 2>&1
	then normalize-audio -v "$INFILE.wav"
	elif which normalize >/dev/null 2>&1
	then normalize -v "$INFILE.wav"
	fi

	oggenc $EXTRA_OGGENC_OPTS -a "$artist" -t "$title" -l "$album" -d "$date" -G "$genre" -c "composer=$composer" "$INFILE".wav

	rm "$INFILE".wav
	# mv "$INFILE.ogg" "$artist - $title".ogg

	## Rename the final file (strip the original extension)
	outfile="`echo "$INFILE" | sed 's+\.[^.]*$++'`".ogg
	mv "$INFILE".ogg "$outfile"

	# vorbisgain adds REPLAYGAIN tags to the file.  Unfortunately mplayer's ffvorbis replay codec ignores them!
	if which vorbisgain >/dev/null 2>&1
	then vorbisgain "$outfile"
	fi

	verbosely touch -r "$INFILE" "$outfile"

	originalSize=$(filesize "$INFILE")
	finalSize=$(filesize "$outfile")
	sizeReduction=$(( originalSize - finalSize ))
	percentageShrunk=$(( 100 * sizeReduction / originalSize ))
	jshinfo "Shrunk file by $percentageShrunk%."

	rm info.tmp.$$

done

