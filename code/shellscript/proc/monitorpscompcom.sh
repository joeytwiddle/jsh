OTHER=`jfc simple oneway "$2" "$1" | ungrep "cat$"`
if ! test "x$OTHER" = "x"; then
  echo
  echo `cursered``cursebold`"<<< DIED:"
  echo "$OTHER"
  echo ">>>"`cursenorm`
  echo
fi
jfc simple oneway "$1" "$2" | ungrep "cat$"
