if test "x$@" = "x"; then
  echo 'replaceline [ <file> ] "search string" "replacement line"'
  exit 1
fi

if test "x$3" = "x"; then
  sed "s.*$1.*$2"
else
  cat $1 | sed "s.*$2.*$3"
fi

#if test "x$3" = "x"; then
#
#  while read L; do
#    if startswith "$L" "$1"; then
#      echo "$2"
#    else
#      echo "$L"
#    fi
#  done  
#
#else
#  cat "$1" | replaceline "$2" "$3"
#fi
