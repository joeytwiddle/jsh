FILE="$*"
X=$$;
while test -e "$FILE""$X"; do
  X=$[$X+1];
done
touch "$FILE""$X"
echo "$FILE""$X"
