FS=" "
THECOLS=""
for x in $*; do
  THECOLS="$THECOLS\$$x\" \""
done
awk ' { printf('"$THECOLS"'"\n"); } '
