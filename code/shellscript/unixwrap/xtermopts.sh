ARGS="-cc 33:48,37:48,45-47:48,64:48"
if test "$VNCDESKTOP" = "X"
then
	# FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-11-*-*-*-m-*-iso8859-1'
elif test "$JM_UNAME" = "linux" && ! startswith `hostname` "qanir"
then
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'
	ARGS="$ARGS -rightbar"
elif test "$JM_UNAME" = "cygwin"
then
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-12-*-*-m-*-iso8859-1'
	# cygwin doesn't like -cc
	ARGS=""
else
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
fi

echo $ARGS +sb -sl 5000 -vb -si -sk -bg black -fg white -font "$FONT" "$@"
