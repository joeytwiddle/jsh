jfc simple oneway "$1" "$2"
OTHER=`jfc simple oneway "$2" "$1"`
if ! test "x$OTHER" = "x"; then
  echo
  echo "<<< DIED:"
  echo "$OTHER"
  echo ">>>"
  echo
fi
