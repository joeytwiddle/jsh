FILE="catch.txt"
touch "$FILE"
D="$$"
(
  $* > $FILE 2>&1
  # kill "$D"
  # exit 0
  killchild $$ tail
) &
# tail -f $FILE | more
tail -f $FILE
