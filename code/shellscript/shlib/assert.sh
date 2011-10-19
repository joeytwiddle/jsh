# assert (when written) can be used by a develoer to put checks in his scripts that ensure that the stream or arguments meet certain specified characteristics.
# This can be used as a bug-trapping tool, informing someone (eg. by email) when the data is out-of-order.
if "$@"
then :
else
	. errorexit "Assertion failed: $@"
fi
