#!/bin/bash
## zsh would also do (just need the $RANDOM param)

# jsh-ext-depends: sed
# jsh-depends: cursebold cursenorm getrandom

if [ "$1" = "" ] || [ "$1" = --help ]
then
  echo "highlight [-bold] <string> [<color>]"
  echo "  Note: the search <string> will be fed into sed, so may be in sed format."
  exit 1
fi

BOLD=
if [ "$1" = "-bold" ]
then
  BOLD=1
  shift
fi

COLOR="$2"
if [ "$COLOR" = "" ]
then

	# COLI=` expr 1 '+' '(' $RANDOM '%' 5 ')' `
	RAND=`getrandom`
	COLI=` expr 1 '+' '(' $RAND '%' 5 ')' `

	if test "$COLI" = ""; then
		COLI=3
	fi
	if [ "$COLI" = 1 ] || [ "$COLI" = 4 ]; then BOLDI=1; else BOLDI=0; fi
	HIGHCOL=`printf '\033[0'"$BOLDI"';3'"$COLI"'m'`

else

	HIGHCOL=`curse$COLOR`
	if [ "$BOLD" ]
	then HIGHCOL="$HIGHCOL"`cursebold`
	fi

fi

NORMCOL=`cursenorm`

# printf "$NORMCOL" ## Can throw off regexps, notably in jdiff, but could be fixed there if this is needed here.
# sed "s#$1#$HIGHCOL$1$NORMCOL#g"
# sed "s#\($1\)#$HIGHCOL\1$NORMCOL#g"
# sed "s#$1#$HIGHCOL\0$NORMCOL#g"

## Adding -u option should cause sed to print out more often, but it doesn't appear to work :-/
sed -u "s#$1#$HIGHCOL\0$NORMCOL#g"

