RP=`jwhich realpath`
if test "$?" = "0"; then
	$RP "$@"
else
	resolvedir "$@"
fi
