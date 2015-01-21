# @sourceme

## Avoid "cannot grep directory" errors:

if [ "$JM_UNAME" = "sunos" ]
then

	function mygrep () {
		REALGREP=`jwhich grep`
		# $REALGREP "$@" 1>&3 2>&1 | $REALGREP -v "^grep: .*: Is a directory$"
		$REALGREP "$@" 2> /dev/null
	}
	alias grep='mygrep'

else

	## Linux grep can aviod off directory errors:
	alias grep='grep -d skip'

fi
