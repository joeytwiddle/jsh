# Basically an implementation of realpath(1,3) in sh.

# Apparently dodgy?

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
