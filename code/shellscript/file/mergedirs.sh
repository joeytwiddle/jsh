#!/bin/sh

if [ "$1" = "" ] || [ "$1" = --help ]
then
cat << !

mergedirs <dirA> <dirB>  [ |sh ]

  Displays the commands required to move files from <dirA> into <dirB>
  recursively, except when there is a non-identical file already present, in
  which case the conflict is reported on stdout.

  If you want to run what mergedirs suggests, simply re-run with |sh

  TODO: Allow interactive conflict resolution by showing the size and dates of
  conflicting files, and allowing display of a diff or resolution with vimdiff.

  WARNING: There is no intelligent handling of symlinks.

!
  exit 1
fi

DIRA="`realpath \"$1\"`"
DIRB="`realpath \"$2\"`"

'cd' "$DIRA"

find . -type f |
while read FILE
do
  if [ ! -f "$DIRB/$FILE" ] ||
     cmp "$DIRA/$FILE" "$DIRB/$FILE"
  then
    echo mkdir -p '"'"`dirname \"$DIRB/$FILE\"`"'"'
    echo mv '"'$DIRA/$FILE'"' '"'$DIRB/$FILE'"'
    # echo mv "$DIRA/$FILE" "$DIRB/$FILE"
  else
    echo "## Conflict: $FILE" >&2
    ls -l "$DIRA/$FILE" "$DIRB/$FILE" >&2
    cksum "$DIRA/$FILE" "$DIRB/$FILE" >&2
  fi
done

find "$DIRA/" -type d |
reverse |
sed ' s+^+rmdir "+ ; s+$+"+ '
