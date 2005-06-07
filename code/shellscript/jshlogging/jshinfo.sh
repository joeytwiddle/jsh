# jsh-depends: cursebold curseyellow cursenorm
# echo "`curseyellow;cursebold`[INFO] `cursecyan`$*`cursenorm`" >&2
[ "$NOINFO" ] || echo "`curseyellow;cursebold`[INFO] `curseyellow`$*`cursenorm`" >&2
## I don't know why I don't like the green!
# echo "`cursegreen;cursebold`[INFO] `cursegreen`$*`cursenorm`" >&2
