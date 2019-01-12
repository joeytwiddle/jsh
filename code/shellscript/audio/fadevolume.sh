#!/bin/sh
# jsh-ext-depends: aumix
## TODO: wrap aumix if it is missing.  e.g. try alsamixer/rexima/...

if ! which amixer >/dev/null   # aumix
then . errorexit "fadevolume cannot run: no amixer"
fi

## First argument is seconds between each nudge down in volume.
## Defaults to 60 seconds (slow fade).
if [ -n "$1" ]
then GAP="$1"
else GAP=60
fi

[ -n "$DOWNSTEP" ] || DOWNSTEP=1

start_volume=`get_volume`

if [ -n "$start_volume" ] && [ "$start_volume" -gt 0 ]
then
  for volume in `seq "$start_volume" -"$DOWNSTEP" 0` 0
  do
    #echo "[fadevolume] Reducing volume to: $volume"
    set_volume "$volume"
    sleep $GAP
  done
fi

# Stop programs playing music:
#killall mpg123 mp3blaster
#xmms -t &
## echo | mykill music
# And bring back some volume after that:
#sleep 3
#aumix -v 50
