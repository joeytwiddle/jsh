FS=" "
THECOLS=""
FIRST="$1"
for x in $*; do
  if test ! "$x" = "$FIRST"; then
    THECOLS="$THECOLS\" \""
  fi
  THECOLS="$THECOLS\$$x"
done
awk ' { printf('"$THECOLS"'"\n"); } '
