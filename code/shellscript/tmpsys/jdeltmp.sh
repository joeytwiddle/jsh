for X in "$@"; do
  if startswith "$X" "$JPATH/tmp"; then
    # mkdir -p $JPATH/trash/$JPATH/tmp
    # mv "$X" $JPATH/trash/$X
    del "$X" > /dev/null
  else
    echo "jdeltmp: $X does not start with $JPATH/tmp"
  fi
done
