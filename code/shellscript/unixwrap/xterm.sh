ARGS=""
if test "$JM_UNAME" = "linux"; then
	ARGS="-rightbar"
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'
else
	FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
fi

# Of course font sizes depend on the machine you are on!!

# `jwhich xterm` +sb -sl 5002 -bg black -fg white -font '-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1' $* &
# `jwhich xterm` $ARGS +sb -sl 5000 -vb -si -sk -bg black -fg white -font '-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv' $* &
# `jwhich xterm` $ARGS +sb -sl 5000 -vb -si -sk -bg black -fg white -font '-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1' $* &

# echoargs "$@"
`jwhich xterm` $ARGS +sb -sl 5000 -vb -si -sk -bg black -fg white -font "$FONT" "$@" &
