if startswith "$*" "$JPATH/tmp"; then
  mkdir -p $JPATH/trash/$JPATH/tmp
  mv "$*" $JPATH/trash/$*
  # del "$*"
else
  echo "jdeltmp: $* does not start with $JPATH/tmp"
fi
