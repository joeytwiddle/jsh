# This work of genius attempts to prevent error messages
# if user greps eg. * and has not specified how to deal with directories.

if test "$JM_UNAME" = "sunos"; then

	REALGREP=`jwhich grep`

	# $REALGREP "$@" 1>&3 2>&1 | $REALGREP -v "^grep: .*: Is a directory$"
	$REALGREP "$@" 2> /dev/null

else

	grep -d skip "$@"
	# (other errors no longer redirected)

fi
