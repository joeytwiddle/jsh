ARGS=""
if test "$JM_UNAME" = "linux" && ! startswith `hostname` "qanir"; then
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'
	ARGS="-rightbar"
else
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
fi

echo $ARGS +sb -sl 5000 -vb -si -sk -bg black -fg white -font "$FONT" "$@"
