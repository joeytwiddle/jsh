#!/bin/sh
METHOD=GET

while true
do
	case "$1" in
	-button)
		ADDBUTTON=true
		shift
		;;
	-post)
		METHOD=POST
		shift
		;;
	*)
		break
		;;
	esac
done

URL="$@"

MAIN=`echo "$URL" | before "?"`
REST=`echo "$URL" | afterfirst "?"`
BITS=`echo "$REST" | betweenthe "&"`

echo 'Main = "'$MAIN'"' > /dev/stderr
echo 'Rest = "'$REST'"' > /dev/stderr
echo 'Bits = "'$BITS'"' > /dev/stderr

# echo '  <FORM TARGET="blank" ACTION="'$MAIN'" method="'$METHOD'">'
echo "  <FORM TARGET='blank' ACTION='$MAIN' method='$METHOD'>"

for x in $BITS; do
  # echo "Doing $x"
  PARAM=`echo "$x" | before "="`
  VALUE=`echo "$x" | after "="`
  echo '    <INPUT type="hidden" name="'$PARAM'" value="'$VALUE'">'
done

test "$ADDBUTTON" &&
  echo '    <INPUT type="submit" value="&gt;">'

echo '  </FORM>'
