if test "x$SHRINKTO" = "x"; then
  SHRINKTO="10"
fi

for X in $@; do
  # echo $X
  COM="convert $X -geom $SHRINKTO tmp.jpg"
  echo "$COM"
  $COM
  COM="convert tmp.jpg $X"
  echo "$COM"
  $COM
  # mv -f tmp.$X $X
done