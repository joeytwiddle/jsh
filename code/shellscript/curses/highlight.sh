#!/bin/bash
# zsh would also do (just need $RANDOM param)

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

	COLI=` expr 1 '+' '(' $RANDOM '%' 5 ')' `

	if test "$COLI" = ""; then
		COLI=3
	fi
	if test "$COLI" = 1 || test "$COLI" = 4; then BOLDI=1; else BOLDI=0; fi
	# BOLDI=1
	HIGHCOL=`printf '\033[0'"$BOLDI"';3'"$COLI"'m'`

else

	HIGHCOL=`curse$COLOR`
	if test $BOLD; then
	  HIGHCOL="$HIGHCOL"`cursebold`
	fi

fi

NORMCOL=`cursegrey`

printf "$NORMCOL"
# sed "s#$1#$HIGHCOL$1$NORMCOL#g"
sed "s#\($1\)#$HIGHCOL\1$NORMCOL#g"
