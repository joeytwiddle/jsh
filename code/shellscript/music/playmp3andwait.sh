#!/bin/sh

file_to_play="$1"

if endswith "$file_to_play" "\.ogg" && which ogg123 >/dev/null 2>&1
then

	#ogg123 "$@" ; exit

	# nextsong does not work so well on oggs played through pulseaudio by mplayer
	# Let's re-encode it to an mp3 file

	# --- DISABLED currently ---
	#CONVERT_OGGS_TO_MP3S_BEFORE_PLAYING=1

	if [ -n "$CONVERT_OGGS_TO_MP3S_BEFORE_PLAYING" ]
	then

		ogg_clone="/tmp/$$.ogg"
		mp3_file="/tmp/$$.mp3"

		jshinfo "Converting to $mp3_file"

		cat "$file_to_play" > "$ogg_clone"

		if nice ionice convert_to_mp3 "$ogg_clone"
		then
			echo "Converted $file_to_play to $mp3_file"

			# Change the file which will be played later to our newly encoded file
			file_to_play="$mp3_file"
		else
			echo "Failed to convert to mp3: $ogg_clone"
		fi

	fi

	#echo "[log] file_to_play: $file_to_play"

# # else mpg123 -b 10000 "$@" > /dev/null 2>&1
# else unj mplayer "$@" > /dev/null 2>&1
fi

# ~/j/tools/mplayer -louder "$@" ; exit



## totem doesn't exit after it's played (but we could watch for it) - it probably won't work without X
## noatun dunno... :)

# I think this wasn't working:
#find_exe() {
#	for X
#	do
#		if jwhich "$X" >/dev/null 2>&1
#		then echo "$X"; return
#		fi
#	done
#}
#PLAYER=`find_exe mplayer-minixterm mplayer totem noatun`
#verbosely unj "$PLAYER" $AUDIO_PLAYER_OPTS "$file_to_play"

# Both of these were working for me:
#verbosely mpg123 $AUDIO_PLAYER_OPTS "$file_to_play"
echo -n "which mplayer: "
which mplayer
verbosely mplayer $AUDIO_PLAYER_OPTS "$file_to_play"

## Dodgy attempt to strip out the verbose header lines
# mplayer "$@" |
# (
	# while read LINE
	# do
		# if [ "$LINE" = "Starting playback..." ]
		# then
			# cat
			# break
		# fi
	# done
# 
# )
