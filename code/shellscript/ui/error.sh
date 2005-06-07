# jsh-depends: cursebold cursered curseyellow cursenorm
# echo "`cursered;cursebold`$@`cursenorm`" >&2
# beep # preferably don't beep on subsequent errors for 10s / 10m / ...
[ "$NOERROR" ] || echo "`cursered;cursebold`ERROR: `curseyellow`$@`cursenorm`" >&2
