# No longer backgrounded - that should be done as shell alias.
# XTERME=`jwhich kterm`
# if test "$XTERME" = ""; then
	XTERME=`jwhich xterm`
# fi
$XTERME `xtermopts` "$@"
