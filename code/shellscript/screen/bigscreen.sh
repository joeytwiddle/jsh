if [ ! "$DISPLAY" ]
then export DISPLAY=":0"
fi

if [ "$1" = -xl ]
then
	shift
	FONT='-schumacher-clean-medium-r-normal-*-60-*-*-*-c-*-iso646.1991-irv'
	GEOM='-geometry 44x18'
elif [ "$1" = -big ] || [ "$1" = -large ]
then
	shift
	FONT='-schumacher-clean-medium-r-normal-*-44-*-*-*-c-*-iso646.1991-irv'
	GEOM='-geometry 66x28'
elif [ "$1" = -medium ]
then
	shift
	# FONT='-schumacher-clean-medium-r-normal-*-36-*-*-*-c-*-iso646.1991-irv'
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-32-*-*-*-m-*-iso8859-1'
	GEOM='-geometry 75x33'
## TODO: Above geometries may be overoptimistic.  Also, are they affected if we change screen resolution?!  (Use points instead of pixels?)
else
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-28-*-*-*-m-*-iso8859-1'
	# GEOM='-geometry 80x37'
	GEOM='-geometry 80x34'
fi

# echo $ARGS $GEOM +sb -sl 5000 -vb -si -sk -bg black -fg white -font "$FONT" "$@"

export SCREEN_COMMAND_CHARS="^aa" ## we don't want to use jsh's default because we want it to seem transparent, so we use the original default
## Problem with export, it reaches child screens too.
# SCREEN_COMMAND_CHARS="^aa" ## we don't want to use jsh's default because we want it to seem transparent, so we use the original default
## Now unset in screen script

# unj
xterm -font $FONT $GEOM -e screen -DDR big &

jshinfo "Waiting for xterm and screen to start"
sleep 3
jshinfo "Modifying bigscreen (remove caption and default keys)"
screen -S big -X defescape "$SCREEN_COMMAND_CHARS" ## less vital
screen -S big -X escape "$SCREEN_COMMAND_CHARS" ## the one which works!
screen -S big -X caption splitonly

jshinfo "Joining bigscreen locally =)"
screen -x big
