# jsh-depends: absolutepath isabsolutepath justlinks filename
# Basically an implementation of realpath(1,3) in sh.

# Apparently dodgy?
# But certainly works better than former!
# Oh this was probably marked dodgy because var Y changed
# inside while loop is needed outside it.
# but it's ok cos it's not a | while

X=$1;
Y="";
X=`absolutepath "$X"`
while test ! "$X" = "/" && test ! "$X" = "."
do
	C=`filename "$X"`
	L=`justlinks "$X"` # 2> /dev/null
	X=`dirname "$X"`
	if test "$L"
	then
		if isabsolutepath "$L"
		then X="$L"
		else X="$X/$L"
		fi
	else Y="/$C$Y"
	fi
done
echo "$Y"
