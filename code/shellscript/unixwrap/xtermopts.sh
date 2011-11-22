#!/bin/sh
######################
## DEPRECATED
## This was inefficient, and only used in the 'xterm' script.
## The best bits are now back in the 'xterm' script, and this is no longer called, but may be useful for testing things.





# jsh-ext-depends-ignore: linux
# jsh-ext-depends: hostname
# jsh-depends: endswith
ARGS="-cc 33:48,37:48,45-47:48,64:48,126:48"
if [ "$VNCDESKTOP" = "X" ]
then ## Actually for low-res desktops; we could guess this from xdpyinfo?
	# FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
	# FONT='-b&h-lucidatypewriter-medium-r-normal-*-11-*-*-*-m-*-iso8859-1'
	## These are these same, but seem weird - am I just used to Lucida?!
	# FONT='-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv'
	FONT='-schumacher-clean-medium-r-normal-*-12-*-*-*-c-*-iso646.1991-irv'
# elif test "$JM_UNAME" = "linux" && ! startswith `hostname` "qanir"
elif [ "$HOSTNAME" = "ganymede" ]
then
	if grep -i "SuSE" /etc/issue > /dev/null
	then FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
	elif grep -i "Debian" /etc/issue > /dev/null
	then FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'
	else FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
	fi
elif test "$JM_UNAME" = "linux" && ! endswith `hostname` cs.bris.ac.uk
then
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'
	ARGS="$ARGS -rightbar"
elif [ "$JM_UNAME" = "cygwin" ]
then
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-12-*-*-m-*-iso8859-1'
	# cygwin doesn't like -cc
	ARGS=""
elif endswith `hostname` cs.bris.ac.uk
then
	## Uni?
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
else
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'
fi
## Big:
# FONT='-adobe-courier-medium-r-normal-*-*-140-*-*-p-*-iso8859-2'
## Thin big (wipeout):
# FONT='-*-clean-medium-r-*-*-*-160-*-*-*-*-*-*'
## Medium:
# FONT='-*-terminus-*-*-*-*-16-*-*-*-*-*-*-*' ## not so good bold
## Thin Lucida-style medium:
# FONT="'-*-dejavu sans mono-medium-r-*-*-*-110-*-*-*-*-*-*'"
## Great small:
# FONT='-*-clean-medium-r-*-*-*-120-*-*-*-*-*-*'
# FONT='-*-terminus-*-*-*-*-12-*-*-*-*-*-*-*' ## taller with no cost to rowcount
## Some alternatives to "clean":
# FONT='-*-fixed-*-r-*-*-12-*-*-*-*-*-*-*' ## This one should work on all systems?
# FONT='-*-proggysmalltt-*-*-*-*-*-120-*-*-*-*-*-*'   ## wider and shorter than clean
# FONT='-*-montecarlo fixed 12-medium-r-*-*-*-120-*-*-*-*-*-*'   ## small and neat (1 pixel shorter than clean!), good bold, but weak 'a'
# FONT='-*-modesevenfixed-*-*-*-*-12-*-*-*-*-*-*-*'
## My favourite:
FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'
if [ "$HOSTNAME" = "pod" ]
then FONT='-*-terminus-*-*-*-*-*-140-*-*-*-*-*-*'
fi

echo $ARGS $GEOM +sb -sl 5000 -vb -si -sk -bg black -fg white -font "$FONT" -rightbar -j -s "$@"

