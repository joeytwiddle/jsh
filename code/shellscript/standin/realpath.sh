X=$1;
Y="";
while test ! "$X" = "/"; do
  L=`justlinks "$X"`
  if test ! "$L" = ""; then
    Y="$L$Y"
  fi
  X=`dirname $X`
done
