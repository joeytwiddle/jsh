# sed "s+\\+\\\\+g;s+\n+\\n+g" |
# sed "s+.*$1++" |
# sed "s+\\n+

# No longer defined as multi-line
# now works like sed on each line separately
# (and removes need for afterlastall?)

sed "s+.*$1++"

# tr "\n" " " | sed "s+.*$1++"

# tr "\n" " " | 
# if test "x$2" = "x"; then
#   echo 'eg.'
#   echo '% afterlast "ABCDEFG" "D"'
#   echo 'EFG'
#   echo '%'
#   exit 1
# fi

# NEXT=`echo "$1" | after "$2"`
# echo '>'$NEXT'<'
# if test "x$NEXT" = "x"; then
#   echo "$1"
# else
#   afterlast "$NEXT" "$2"
# fi
