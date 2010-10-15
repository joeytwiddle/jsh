#!/bin/sh
DIRA="`realpath \"$1\"`"
DIRB="`realpath \"$2\"`"

'cd' "$DIRA"

find . -type f |
while read FILE
do
  if test ! -f "$DIRB/$FILE" ||
     cmp "$DIRA/$FILE" "$DIRB/$FILE"
  then
    echo mkdir -p '"'"`dirname \"$DIRB/$FILE\"`"'"'
    echo mv '"'$DIRA/$FILE'"' '"'$DIRB/$FILE'"'
    # echo mv "$DIRA/$FILE" "$DIRB/$FILE"
  else
    echo "## Conflict: $FILE"
    cksum "$DIRA/$FILE" "$DIRB/$FILE"
  fi
done

find "$DIRA/" -type d |
reverse |
sed ' s+^+rmdir "+ ; s+$+"+ '
