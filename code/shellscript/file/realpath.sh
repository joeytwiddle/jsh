RP=`jwhich realpath quietly`
if test "$?" = "0"; then
	$RP "$@"
else
	resolvedir "$@"
fi
