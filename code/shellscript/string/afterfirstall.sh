# Actually does last per line
# sed "s|.*$*||"

# This way is valid but very slow.
# Shame sh isn't lazy, eg. for "randomorder | head -n 1".
# while read X; do
  # Y=`echo "$X" | sed "s|$*.*||"`
  # # echo "y=$Y"
  # echo "$X" | sed "s|^$Y$*||"
# done

# Valid provided following string unique
SEDHACKSTRING="<'\"34098)£~thisisjoeyssedhackstring>"
sed "s|$@\(.*\)|$SEDHACKSTRING\1|" |
  sed "s|.*$SEDHACKSTRING||"
