## Could replace (/neaten) includepath and addclasspath

. parseargs_base_impl << !
... description TODO
bool AFTER "add entries at end of pathlist (default at beginning)"
!

TOADD="$1"
shift

for VARNAME
do

	if test ! $AFTER
	then EVALSTR="$VARNAME=\"\$TOADD:\$$VARNAME\""
	else EVALSTR="$VARNAME=\"\$$VARNAME:\$TOADD\""
	fi

	eval "$EVALSTR"

done
