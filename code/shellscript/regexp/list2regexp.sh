## Unfortunately grep can be very slow with large regexps.
## Often a better solution is to pipe the stream to a file
## and have grep run over it multiple times, once for each argument (to list2regexp).

echo -n "\("
FIRST=true
while read LINE
do
  [ "$FIRST" ] || echo -n "\|"
  # echo "Adding to list: >$LINE<" >&2
  echo -n "$LINE"
  FIRST=
done
echo -n "\)"
