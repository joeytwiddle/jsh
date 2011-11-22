## With some help from http://wiki.multimedia.cx/index.php?title=MPlayer_FAQ#Mencoder_questions

if [ -z "$1" ] || [ -z "$2" ]
then echo "convert_audio_to_video <audio_file> <image_file>" ; exit 0
fi

AUDIO_FILE="$1"
IMAGE_FILE="$2"

OUTPUT_FILE="$AUDIO_FILE.avi"

## Get the length of the audio file by playing 1 second and reading the log.
DURATION_OF_AUDIO="`mplayer -ao null -vo null -endpos 1s "$AUDIO_FILE" | grep "^A: .* of " | head -n 1 | sed 's+^A: .* of ++ ; s+ .*++'`"

# The length gets confused if we reencode the audio using -oac lavc, so for the moment we are stuck with -oac copy.
mencoder mf://"$IMAGE_FILE" -ovc lavc -oac copy -audiofile "$AUDIO_FILE" -fps 1/$DURATION_OF_AUDIO -ofps 30 -o "$OUTPUT_FILE"

