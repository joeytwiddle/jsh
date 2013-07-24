if which amixer >/dev/null
then
	## No we don't want the % from alsa - this has quantum size ~4!
	# amixer -c 1 sget "Master" | grep "Front .* Playback" | head -n 1 | sed 's+^[^[]*\[++ ; s+%\].*$++'
	amixer -c 0 sget "Master" | grep "Front .* Playback" | head -n 1 | sed 's+^.* Playback ++ ; s+ .*++'
elif which aumix >/dev/null
then
	# aumix -d $MIXER -q | grep "pcm " | after "pcm " | before ","
	aumix $AUMIX_OPTS -q | grep "pcm " | sed 's+pcm ++;s+,.*++'
fi
