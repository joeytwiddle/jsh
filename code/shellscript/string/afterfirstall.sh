# jsh-ext-depends: sed

# WRONG: Actually does last per line
# sed "s|.*$*||"

# This way is valid (well not really: e.g. echo -n ?!) but very slow.
# Shame sh isn't lazy, eg. for "randomorder | head -n 1".
# while read X; do
  # Y=`echo "$X" | sed "s|$*.*||"`
  # # echo "y=$Y"
  # echo "$X" | sed "s|^$Y$*||"
# done

SEARCHSTR="$1"
shift

# Valid provided following string unique
SEDHACKSTRING="<'\"34098)£~thisisjoeyssedhackstring>"

cat "$@" |
sed "s$SEARCHSTR\(.*\)$SEDHACKSTRING\1" |
sed "s.*$SEDHACKSTRING" |
cat
