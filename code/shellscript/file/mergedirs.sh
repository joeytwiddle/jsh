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

  There is no intelligent handling of symlinks yet.  They will be untouched.

  WARNING: Will not play nicely with files containing "s, \\s and other special characters.

!
  exit 1
fi

DIRA="`realpath \"$1\"`" || exit 2
DIRB="`realpath \"$2\"`" || exit 2

'cd' "$DIRA"

find . -type f |
while read FILE
do
  if [ -L "$DIRA/$FILE" ]
  then
    echo "## I do not yet know how to handle symlinks: $DIRA/$FILE"
  elif [ -L "$DIRB/$FILE" ]
  then
    echo "## I do not yet know how to handle symlinks: $DIRB/$FILE"
  elif [ ! -f "$DIRB/$FILE" ]
  then
    echo "mkdir -p \"`dirname \"$DIRB/$FILE\"`\""
    echo "mv \"$DIRA/$FILE\" \"$DIRB/$FILE\""
  elif cmp "$DIRA/$FILE" "$DIRB/$FILE" >/dev/null
  then
    echo "del \"$DIRA/$FILE\""
  else
    echo "## Conflict: $FILE" >&2
    ls -l "$DIRA/$FILE" "$DIRB/$FILE" >&2
    cksum "$DIRA/$FILE" "$DIRB/$FILE" >&2
  fi
done

find "$DIRA/" -type d |
reverse |
sed ' s+^+rmdir "+ ; s+$+"+ '
