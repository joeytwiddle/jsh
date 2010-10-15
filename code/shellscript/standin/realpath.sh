#!/bin/sh
# jsh-depends: resolvedir jwhich
RP=`jwhich realpath 2> /dev/null`
if test "$?" = "0"; then
	$RP "$@"
else
	resolvedir "$@"
fi
