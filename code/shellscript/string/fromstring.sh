STRING="$*"

## TODO: What about when [ "$LINE" = "-n" ] eh?!

while read LINE &&
      [ ! "$LINE" = "$STRING" ]
do [ nothing ]
done

cat
