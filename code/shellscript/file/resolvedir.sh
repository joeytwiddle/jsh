# Basically an implementation of realpath(1,3) in sh.

# SOFAR=""
# absolutepath "$1" |
# tr "/" "\n" |
# (
# read SOFAR;
# while read X; do
	# NOWAT="$SOFAR/$X"
	# echo "$NOWAT"
	# TARGET=`justlinks "$NOWAT"`
	# echo " -> >$TARGET<"
	# if test ! "$TARGET" = ""; then
		# # TODO: need to check target does not have any
		# #       links in its path!
		# if isabsolutepath "$TARGET"; then
			# NOWAT="$TARGET"
		# else
			# NOWAT="$SOFAR/$TARGET"
		# fi
	# fi
	# SOFAR="$NOWAT"
# done
# )
# 
# exit 0

# Apparently dodgy?
# But certainly works better than former!
# Oh this was probably marked dodgy because var Y changed
# inside while loop is needed outside it.

X=$1;
Y="";
X=`absolutepath "$X"`
while test ! "$X" = "/" -a ! "$X" = "."; do
	C=`filename "$X"`
	L=`justlinks "$X"`
	# echo
	# echo "X=$X"
	# echo "Y=$Y"
	# echo "C=$C"
	# echo "L=>$L<"
	X=`dirname "$X"`
	if test ! "$L" = ""; then
		if isabsolutepath "$L"; then
			X="$L"
		else
			X="$X/$L"
		fi
	else
		Y="/$C$Y"
	fi
	# echo "X=$X"
	# echo "Y=$Y"
done
echo "$Y"
