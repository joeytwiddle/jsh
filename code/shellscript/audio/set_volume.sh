VOL="$1"
if which amixer >/dev/null
then amixer -c 0 sset "Master" "playback" "$VOL" >/dev/null
elif which aumix >/dev/null
# then aumix -d $MIXER -w $VOL
then aumix $AUMIX_OPTS -w "$VOL"
fi
