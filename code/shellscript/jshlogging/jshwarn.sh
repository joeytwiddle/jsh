# jsh-depends: cursebold cursecyan curseyellow cursenorm
## TODO: CONSIDER: WARN=off disabled it?
## TODO: CONSIDER: some global variable sends jsh logs to a file?
# if [ "$WARN" ]
# then
echo "`curseyellow;cursebold`[WARN] `cursecyan`$*`cursenorm`" >&2
# fi
