#!/bin/sh

if [ "$1" = --help ]
then
cat << !

columnise-clever [ -only <regexp> | -ignore <regexp> ] <files>...

  Reformat the input into columns.

  You can use regexps to select which part of the line you do or don't want to
  be reformat.  The rest will be left as-is.

  TODO:

  -ignore doesn't seem to work - columnises the things after it
  -only was working though.  it keeps the delimeter too :)

!
exit 0
fi

ONLY=
if [ "$1" = -only ]
then ONLY="$2"; shift; shift
fi

IGNORE="^[	 ]*$ONLY"
if [ "$1" = -ignore ]
then IGNORE="$2"; shift; shift
fi

ORIGINAL=`jgettmp col-clev-orig`

cat "$@" > $ORIGINAL

LEFT=`jgettmp col-clev-left`
RIGHT=`jgettmp col-clev-right`

cat $ORIGINAL | splitatendofregexp -left "$IGNORE" > $LEFT
cat $ORIGINAL | splitatendofregexp -right "$IGNORE" > $RIGHT

## This was working on RIGHT but I changed it to work on LEFT.
# debug `countlines "$RIGHT"`
cat $LEFT   |
sed 's+^+.+' | ## Dirty hack to ensure no empty lines, cos columnise kill em
columnise    |
sed 's+^.++' | ## Undo dirty hack
dog $LEFT
# debug `countlines "$RIGHT"`

paste -d '\n' $LEFT $RIGHT | tr -d ''
# cat $LEFT $RIGHT

jdeltmp $ORIGINAL $LEFT $RIGHT
