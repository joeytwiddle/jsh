VOL="$1"
if which pulseaudio-ctl >/dev/null 2>&1
then pulseaudio-ctl set "$VOL"
elif which amixer >/dev/null 2>&1
then amixer -c 0 sset "Master" "playback" "$VOL" >/dev/null
elif which aumix >/dev/null 2>&1
# then aumix -d $MIXER -w $VOL
then aumix $AUMIX_OPTS -w "$VOL"
fi

[ -n "$SHOW_VOLUME" ] && show_volume
