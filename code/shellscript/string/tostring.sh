STRING="$*"

while read LINE &&
      [ ! "$LINE" = "$STRING" ]
do echo "$LINE"
done

cat > /dev/null
