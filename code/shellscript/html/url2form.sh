URL="$@"

MAIN=`echo "$URL" | before "?"`
REST=`echo "$URL" | afterfirst "?"`
BITS=`echo "$REST" | betweenthe "&"`

echo 'Main = "'$MAIN'"'
echo 'Rest = "'$REST'"'
echo 'Bits = "'$BITS'"'

echo '  <FORM ACTION="'$MAIN'" method="GET">'

for x in $BITS; do
  # echo "Doing $x"
  PARAM=`echo "$x" | before "="`
  VALUE=`echo "$x" | after "="`
  echo '    <INPUT type="hidden" name="'$PARAM'" value="'$VALUE'">'
done

echo '  </FORM>'
