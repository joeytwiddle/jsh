#!/bin/sh
## TODO: docs
## TODO: preserve order (add index at front, increment fields (create fields if none), extract dups, sort by index, and remove index)
## TODO: use sort -n -k rather thank takecols then grep!

# Does not preserve order (in fact orders with sort)
# and unfortunately produces duplicate duplicates twice (etc.)!

# # Could provide arguments represnting columns to not-ignore
# # And could provide -gap to separate different twins

# # OK now (optional) numbers are columns by which duplicates are matched
# # otherwise whole line

# # Oh dear at the moment of course, by using takecols it clips
# # the whole output to those columns specified, when really we
# # would like to print the original whole line out.
# # Need to do the column clipping internally, and then fix dependent scripts...

# OK that's all done by keeping the streams and reading them back :-P not scalable
# Only "bug" now is that clipped columns must be adjacent for final grep to work.

# # Isn't the KEEP=`...` broken if sort doesn't keep them numerical according to requested columns?!

# Gap mode now separates the (adjacent) columns from the other data on the matched lines

# Only problem now is with substring matches.
# We can't do a ^...$ match because we might be taking columns.

# OK now we fork depending on cols or not, so problem will only occur if using cols

if [ "$1" = --help ]
then
cat << !

keepduplicatelines [ -gap ] [ <column_#>s ]

  reads from stdin, and keeps any lines which have duplicates
	(or, if columns are specified, keeps lines which have duplicates
	in just those columns).

	With -gap, prints an empty line between each set of duplicates

!
exit 1
fi

TMPFILE=`jgettmp keepduplicatelines`

export GAP=
while [ "$1" = "-gap" ]
do export GAP=true; shift
done

## Save the stream (we need to read it twice later).
cat > "$TMPFILE"

## Find lines which are duplicated (in specified columns).

LAST=""

cat "$TMPFILE" |
takecols "$@" | ## TODO: is this syntax ok?
sort |

while read LINE
do
  if [ "x$LINE" = "x$LAST" ]
  then printf "%s\n" "$LINE"
  fi
  LAST="$LINE"
done |

## OK but if a line had lots of duplicates, we only need one instance of it to get each set, so:
removeduplicatelines |

## For each duplicate line-type found, show all its instances:
while read LINE; do
  if [ -n "$LINE" ]
  then
    if [ -n "$GAP" ]
    then echo
    fi
    if [ -z "$1" ]
    then printf "%s\n" "$LINE"
    # else grep "$LINE" "$TMPFILE"
    ## Dodgy grep which ensures the string is in its own column:
    else grep "\(^\|[ 	]\)$LINE\([ 	]\|$\)" "$TMPFILE" # The dodgy grep
    fi
  fi
done |

removeduplicatelinespo # These can occur if the kept column matches an irrelevent line (eg. subset or irrelevent column)     ## TODO: Eh?!  Example please.

jdeltmp "$TMPFILE"
