#!/bin/sh
# jsh-ext-depends: aumix
## TODO: wrap aumix if it is missing.  e.g. try alsamixer/rexima/...

if ! which amixer >/dev/null   # aumix
then . errorexit "fadevolume cannot run: no amixer"
fi

## First argument is seconds between each nudge down in volume.
## Defaults to 60 seconds (slow fade).
if [ "$1" ]
then GAP="$1"
else GAP=60
fi

[ "$DOWNSTEP" ] || DOWNSTEP=1

DONE=
while [ ! "$DONE" ]
do
  DONE=true # Cleared if any of the mixers has not yet hit 0

  VOL=`get_volume`
  VOL=`expr "$VOL" - $DOWNSTEP`
  [ "$VOL" -gt 0 ] || VOL=0
  echo "$VOL"
  [ "$VOL" ] && [ "$VOL" -gt -1 ] &&
  set_volume "$VOL" &&
  [ "$VOL" ] && [ "$VOL" -gt 0 ] && DONE=

  sleep $GAP
done

# Stop programs playing music:
#killall mpg123 mp3blaster
#xmms -t &
## echo | mykill music
# And bring back some volume after that:
#sleep 3
#aumix -v 50
