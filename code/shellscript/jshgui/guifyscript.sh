## jsh-help: Runs the given command in an xterm, and pauses after it has finished, so the user can see the results.
## jsh-help: Not neccessarily for scripts, any command is ok.

# jsh-depends: error jshinfo
# this-script-does-not-depend-on-jsh: xterm

if [ "$1" = -inxterm ]
then

	shift

	if [ "$1" = -timeout ]
	then GUIFYSCRIPT_TIMEOUT="$2"; shift; shift
	fi

	"$@"

	RES="$?"
	echo
	if [ "$RES" = 0 ]
	then jshinfo "Command succeeded: $*"
	else error "Command failed with \"$RES\": $*"
	fi

	if [ "$GUIFYSCRIPT_TIMEOUT" ]
	then
		## Really we can only say "seconds" if GUIFYSCRIPT_TIMEOUT contains not alpha characters.
		jshinfo "Will close in $GUIFYSCRIPT_TIMEOUT seconds ..."
		sleep "$GUIFYSCRIPT_TIMEOUT"
	else
		jshinfo "Hit <Enter> to close the window."
		read KEY
	fi

else

	# xterm $XTERM_OPTS -title "$*" -e guifyscript -inxterm "$@"
	bigwin guifyscript -inxterm "$@"
	# whitewin -e guifyscript -inxterm "$@"

fi
