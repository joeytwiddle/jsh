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

GAP=
while test "$1" = "-gap"; do
  GAP=true
  shift
done

ALL=`cat`

KEEP=`
  Y=""
  echo "$ALL" |
  takecols $* |
  sort |
  while read X; do
    if test "$X" = "$Y"; then
      echo "$X"
    fi
    Y="$X"
  done |
removeduplicatelines` # Should pipe through remdups!

  echo "$KEEP" |
  while read X; do
    echo "$ALL" |
    grep "$X"
    if test "$GAP"; then
      echo
    fi
  done

# Y=""
# sort | while read X; do
  # if test "$X" = "$Y"; then
    # echo "$X"
  # fi
  # Y="$X"
# done
