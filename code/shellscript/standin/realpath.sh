RP=`jwhich realpath`
# echo "$? $RP"

if test "$?" = "0"; then
	$RP "$@"
else
	resolvedir "$@"
fi

# `jwhich realpath` $*

# Can be removed really.  resolvedir does realpath with sh scripts.
