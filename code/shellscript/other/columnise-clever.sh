#!/bin/sh

# See also: column -t -l 5

# TODO: But actually it works fine with GNU coreutils installed
if [ "$(uname)" = "Darwin" ] && false
then
        echo "[columnise-clever] Skipping columnisation because it does not work well on macOS"
        #sleep 0.1
        cat
        exit
fi

if [ "$1" = --help ]
then
cat << !

columnise-clever [ -only <regexp> | -ignore <regexp> ] <files>...

  Reformat the input into columns.

  You can use regexps to select which part of the line you do or don't want to
  be reformat.  The rest will be left as-is.

  TODO:

  -only was working though.  it keeps the delimeter too :)

  -ignore To use -ignore, you should in fact provide a regexp that, assuming it starts from ^, matches all the fields you want to columnise, and one more.
          So for example '[^ ]* *[^ ]*' would match two fields, where the first one is not indented, and therefore the second field will be columnised and nothing else will be affected.

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
