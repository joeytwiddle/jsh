EXCLUDE=
if [ "$1" = -x ]
then EXCLUDE=true; shift
fi
STRING="$*"

while read LINE &&
      [ ! "$LINE" = "$STRING" ]
do echo "$LINE"
done

[ ! $EXCLUDE ] && echo "$LINE"

cat > /dev/null
