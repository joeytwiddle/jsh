if test "$1" = ""; then
  echo "highlight [-bold] <string> [<color>]"
  echo "  Note: the search <string> will be fed into sed, so may be in sed format."
  exit 1
fi

BOLD=
if test "$1" = "-bold"; then
  BOLD=1
  shift
fi

COLOR="$2"
if test "$COLOR" = ""; then
  COLOR="yellow"
fi

NORMCOL=`cursegrey`
HIGHCOL=`curse$COLOR`
if test $BOLD; then
  HIGHCOL="$HIGHCOL"`cursebold`
fi

printf "$NORMCOL"
sed "s#$1#$HIGHCOL$1$NORMCOL#g"
