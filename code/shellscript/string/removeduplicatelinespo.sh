LAST=""
cat "$@" |
awk ' {
        printf("%s",NR);
        printf("%s"," ");
        printf("%s",$0);
        printf("%s","\n");
      }
    ' |
sort -k 2 |
while read N LINE; do
  # Ugh these three lines are a hack/fix for keepduplicatelines's gap mode!
  if test "$LINE" = ""; then
    echo "$N "
  elif test ! "$LINE" = "$LAST"; then
    echo "$N $LINE"
    LAST="$LINE"
  fi
done |
sort -n -k 1,1 |
afterfirst " "
