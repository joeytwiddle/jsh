URL="$@"

MAIN=`echo "$URL" | before "?"`
REST=`echo "$URL" | afterfirst "?"`
BITS=`echo "$REST" | betweenthe "&"`

echo 'Main = "'$MAIN'"' > /dev/stderr
echo 'Rest = "'$REST'"' > /dev/stderr
echo 'Bits = "'$BITS'"' > /dev/stderr

echo '  <FORM TARGET="blank" ACTION="'$MAIN'" method="GET">'

for x in $BITS; do
  # echo "Doing $x"
  PARAM=`echo "$x" | before "="`
  VALUE=`echo "$x" | after "="`
  echo '    <INPUT type="hidden" name="'$PARAM'" value="'$VALUE'">'
done

echo '  </FORM>'
