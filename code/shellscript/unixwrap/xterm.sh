# XTERME=`jwhich kterm`
# if test "$XTERME" = ""; then
	XTERME=`jwhich xterm`
# fi
$XTERME `xtermopts` "$@" &
