# jsh-depends: cursebold cursecyan curseyellow cursenorm cursered
## TODO: CONSIDER: WARN=off disables it?
## TODO: CONSIDER: some global variable sends jsh logs to a file?
# if [ "$WARN" ]
# then
# echo "`curseyellow;cursebold`[WARN] `cursecyan`$*`cursenorm`" >&2
# echo "`cursered;cursebold`[WARN] `curseyellow`$*`cursenorm`" >&2
# echo "`cursered;cursebold`[`curseyellow;cursebold`WARN`cursered;cursebold`] `curseyellow`$*`cursenorm`" >&2
[ "$NOWARN" ] || echo "`curseyellow;cursebold`[`cursered;cursebold`WARN`curseyellow;cursebold`] `curseyellow`$*`cursenorm`" >&2
# fi
