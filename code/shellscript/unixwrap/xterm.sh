# jsh-ext-depends-ignore: konqueror
# jsh-depends: jwhich xtermopts
# No longer backgrounded - that should be done as shell alias.
# XTERME=`jwhich kterm`
# if test "$XTERME" = ""; then

## Just for fun, set the default xterm cursor to a random colour:
# COL=` for X in \`seq 1 6\`; do echolines \`seq 1 9\` a b c d e f | chooserandomline; done | tr -d '\n' `
# echo "XTerm*cursorColor: #$COL" | xrdb -merge

XTERME=`jwhich xterm`
[ ! "$XTERME" ] && XTERME=`jwhich konqueror`
[ ! "$XTERME" ] && XTERME=`jwhich dtterm`
# fi
$XTERME `xtermopts` "$@"
