if which pulseaudio-ctl >/dev/null 2>&1
then pulseaudio-ctl | striptermchars | grep "^ Volume level" | afterfirst ':' | grep -o '[0-9]*'
elif which amixer >/dev/null 2>&1
then
	## No we don't want the % from alsa - this has quantum size ~4!
	# amixer -c 1 sget "Master" | grep "Front .* Playback" | head -n 1 | sed 's+^[^[]*\[++ ; s+%\].*$++'
	amixer -c 0 sget "Master" | grep "\(Front\|Mono:\).*Playback" | head -n 1 | sed 's+^.* Playback ++ ; s+ .*++'
elif which aumix >/dev/null 2>&1
then
	# aumix -d $MIXER -q | grep "pcm " | after "pcm " | before ","
	aumix $AUMIX_OPTS -q | grep "pcm " | sed 's+pcm ++;s+,.*++'
fi
