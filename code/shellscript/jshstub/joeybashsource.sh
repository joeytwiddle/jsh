## When bash sources a script, that script cannot obtain the name it was sourced with!
## But if we alias "source" and "." in bash to this script, it can intercept
## the call, and set the TOSOURCE variable.

# echo "[joeybashsource] Intercepted ($0) >$*<" >&2
echo "[ joeybashsource Intercepted . $* ]" >&2
# echo "[joeybashsource] $*" >&2
# "$@"
# '.' "$@"
# "$TOSOURCE" "$@"
TOOLNAME="$1"
shift
# if test -L $JPATH/tools/$TOOLNAME || test -L $TOOLNAME
# then
	# echo "[joeybashsource] export TOSOURCE=\"$TOOLNAME\"" >&2
	export TOSOURCE=$TOOLNAME
	## I thought we might need this when bash didn't seem to be rehashing, but I now think the problem was elsewhere.
	# export DONTEXEC=true
	# '.' $TOOLNAME "$@"
	# unset DONTEXEC
# else
	# echo "[joeybashsource] $TOOLNAME >$*<" >&2
	# echo >&2
	# set -x
	# $TOOLNAME "$@"
# fi
# echo "[ joeybashsource '.' $TOOLNAME $* ]" >&2
# echo >&2
'.' $TOOLNAME "$@"
