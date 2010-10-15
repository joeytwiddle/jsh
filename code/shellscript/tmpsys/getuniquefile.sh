#!/bin/sh
FILE="$@"
X=$$;
while test -f "$FILE""$X"; do
  X=$[$X+1];
done
touch "$FILE""$X"
echo "$FILE""$X"
