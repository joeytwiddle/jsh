# jsh-ext-depends-ignore: linux
# jsh-ext-depends: hostname
# jsh-depends: endswith
ARGS="-cc 33:48,37:48,45-47:48,64:48,126:48"
if test "$VNCDESKTOP" = "X"
then ## Actually for low-res desktops; we could guess this from xdpyinfo?
	# FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
	# FONT='-b&h-lucidatypewriter-medium-r-normal-*-11-*-*-*-m-*-iso8859-1'
	## These are these same, but seem weird - am I just used to Lucida?!
	# FONT='-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv'
	FONT='-schumacher-clean-medium-r-normal-*-12-*-*-*-c-*-iso646.1991-irv'
# elif test "$JM_UNAME" = "linux" && ! startswith `hostname` "qanir"
elif test "$JM_UNAME" = "linux" && ! endswith `hostname` cs.bris.ac.uk
then
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'
	ARGS="$ARGS -rightbar"
elif test "$JM_UNAME" = "cygwin"
then
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-12-*-*-m-*-iso8859-1'
	# cygwin doesn't like -cc
	ARGS=""
else
	## Uni?
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
fi
## Big Courier:
# FONT='-adobe-courier-medium-r-normal-*-*-140-*-*-p-*-iso8859-2'

echo $ARGS $GEOM +sb -sl 5000 -vb -si -sk -bg black -fg white -font "$FONT" "$@"
