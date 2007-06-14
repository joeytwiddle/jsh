if [ "$1" = --help ]
then
  echo "startswith <string> <searchstring>"
  echo "  return status 0 means true, 1 means false."
  exit 123
fi

[ "$2" = "" ] ||

[ ! "${1#$2}" = "$1" ]

## Old method (actually matched regexps instead of strings):
# RESULT=`echo "$1" | grep "^$2"`
# if test "$RESULT" = ""; then
  # # echo "no"
  # exit 1
# else
  # # echo "yes"
  # exit 0
# fi
