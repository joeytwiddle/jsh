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

TMPFILE=`jgettmp keepduplicatelines`

export GAP=
while test "$1" = "-gap"
do export GAP=true; shift
done

cat > "$TMPFILE"

LAST=""

cat "$TMPFILE" |
takecols "$@" |
sort |

while read LINE
do
  if test "$LINE" = "$LAST"
  then echo "$LINE"
  fi
  LAST="$LINE"
done |

removeduplicatelines |

while read LINE; do
  if test "$LINE"
  then
    if test "$GAP"
    then echo
    fi
    if test ! "$1"
    then echo "$LINE"
    # else grep "$LINE" "$TMPFILE" # The dodgy grep
    else grep "\(^\|[ 	]\)$LINE\([ 	]\|$\)" "$TMPFILE" # The dodgy grep
    fi
  fi
done |

removeduplicatelinespo # These can occur if the kept column matches an irrelevent line (eg. subset or irrelevent column)

jdeltmp "$TMPFILE"
