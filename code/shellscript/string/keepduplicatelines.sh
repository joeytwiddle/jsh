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

FILE=`jgettmp keepduplicatelines`

export GAP=
while test "$1" = "-gap"; do
  export GAP=true
  shift
done

# ALL=`cat`
cat > "$FILE"

# KEEP=`
  Y=""
  # echo "$ALL" |
  cat "$FILE" |
  takecols "$@" |
  sort |
  while read X; do
    if test "$X" = "$Y"; then
      echo "$X"
    fi
    Y="$X"
  done |
  removeduplicatelines |
  # removeduplicatelines`

# echo "$KEEP" |
  while read X; do
    if test ! "$X" = ""; then
      # echo "$ALL" |
      # grep "$X" # Yes this one!
      if test "$GAP"; then
        echo
        # echo "$X ------------------"
        # echo "$X"
		  # # Er what is this sed for?
        # grep "$X" "$FILE" | sed "s+$X++"
	  fi
      # else
			# Only do grep if previously stripped by columns
			if test "x$@" = "x"; then
				echo "$X"
			else
				grep "$X" "$FILE" # The dodgy grep
			fi
      # fi
    fi
  done |
  removeduplicatelinespo # These can occur if the kept column matches an irrelevent line (eg. subset or irrelevent column)

# Y=""
# sort | while read X; do
  # if test "$X" = "$Y"; then
    # echo "$X"
  # fi
  # Y="$X"
# done
