if [ ! "$DISPLAY" ]
then DISPLAY=":0"
fi

FONT='-schumacher-clean-medium-r-normal-*-60-*-*-*-c-*-iso646.1991-irv'
# GEOM='-geometry 44x19'
GEOM='-geometry 44x18'

# echo $ARGS $GEOM +sb -sl 5000 -vb -si -sk -bg black -fg white -font "$FONT" "$@"

# unj
xterm -font $FONT $GEOM -e screen -DDR big &

sleep 5
screen -x big
