if [ "" = "`which aumix`" ]
then . errorexit "fadevolume cannot run: no aumix"
fi

## First argument is seconds between each nudge down in volume.
## Defaults to 60 seconds (slow fade).
if [ "$1" ]
then GAP="$1"
else GAP=60
fi

DONE=
while test ! $DONE
do
  VOL=`aumix -q | grep "vol" | sed 's+vol ++;s+,.*++'`
  VOL=`expr "$VOL" - 1`
  echo "$VOL"
  aumix -v "$VOL"
  if [ "$VOL" -lt 1 ] || [ ! "$VOL" ]
  then DONE=true
  else sleep $GAP
  fi
done

## Stop programs playing music:
# killall mpg123 mp3blaster
# xmms -t &
# # echo | mykill music
## And bring back some volume after that:
# sleep 3
# aumix -v 50
