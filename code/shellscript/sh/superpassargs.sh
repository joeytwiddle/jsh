#!/bin/sh

# The final conclusive proof that "$@" is the best
# way to pass arguments forwards intact.

# Ahem, this requires of course that ${1+"$@"} works with your sh
# (that's no longer true)

echo "The correct answer for the set version is three (3)."
echo

for WHICHSH in sh ash csh tcsh zsh bash; do

  # WHICHSH="$1"
  SHFILE="./tmp.$WHICHSH"
  
  (
    echo "#!/bin/$WHICHSH"
    echo "echo \"USING $WHICHSH\""
    cat `which passargs`
  ) > "$SHFILE"
  
  chmod a+x "$SHFILE"
  
  # "$SHFILE" ${1+"$@"}
  "$SHFILE" "$WHICHSH" "to  gether" "toge ther"

done
