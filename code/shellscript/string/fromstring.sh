EXCLUDE=
if [ "$1" = -x ]
then EXCLUDE=true; shift
fi
STRING="$*"

## TODO: What about when [ "$LINE" = "-n" ] eh?!

while read LINE &&
      [ ! "$LINE" = "$STRING" ]
do [ nothing ]
done

[ ! $EXCLUDE ] && echo "$LINE"

cat
