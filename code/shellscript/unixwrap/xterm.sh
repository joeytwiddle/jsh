# jsh-depends: jwhich xtermopts
# No longer backgrounded - that should be done as shell alias.
# XTERME=`jwhich kterm`
# if test "$XTERME" = ""; then
XTERME=`jwhich xterm`
[ ! "$XTERME" ] && XTERME=`jwhich konqueror`
[ ! "$XTERME" ] && XTERME=`jwhich dtterm`
# fi
$XTERME `xtermopts` "$@"
