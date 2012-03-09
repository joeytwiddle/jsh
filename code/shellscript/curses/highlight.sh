#!/bin/bash
# jsh-ext-depends-ignore: find make
## zsh would also do (just need the $RANDOM param)  (well actually that's a job for getrandom to worry about now :)

## TODO: scripts sometimes use highlight ".*" curseblue as a lazy way of printing the whole stream in blue
##       We could detect this regexp, and add the colours to the stream more efficiently than actually using sed for the regexp search/replace.

# jsh-ext-depends: sed
# jsh-depends: cursebold cursenorm getrandom

if [ "$1" = "" ] || [ "$1" = --help ]
then cat << !

highlight [ -bold ] <regexp> [ <color> ]

  highlights all occurrences of the expression in stdout using a random termcap
  colour (or the colour specified).
	
  Can be used to make certain expressions stand out (easier to find),
  in long streams of data.

  Note: the search <regexp> will be fed into sed, so should be sed-compatible.

  For example, try: highlight | highlight "col.*r"

!
exit 1
fi

## Parse arguments and prepare colours:

BOLD=
if [ "$1" = "-bold" ]
then
  BOLD=1
  shift
fi

COLOR="$2"
if [ ! "$COLOR" ]
then

	## Choose a random colour:

	# COLI=` expr 1 '+' '(' $RANDOM '%' 5 ')' `
	RAND=`getrandom`
	COLI=` expr 1 '+' '(' $RAND '%' 5 ')' `

	if [ ! "$COLI" ] ## In case random failed, choose yellow :)
	then COLI=3
	fi
	## These colours appear dark against my black background, but might not against a light one!
	if [ "$COLI" = 1 ] || [ "$COLI" = 4 ]; then BOLDI=1; else BOLDI=0; fi
	HIGHCOL=`printf '\033[0'"$BOLDI"';3'"$COLI"'m'`

else

	HIGHCOL=`curse$COLOR`
	if [ "$BOLD" ]
	then HIGHCOL="$HIGHCOL"`cursebold`
	fi

fi

NORMCOL=`cursenorm`

## Replace all matches in the stream with a highlighted copy:

## TODO: cvs copy had alternatives here for highlighting only the first -atom specified in the regexp (like extractregexp).  do it :)

sed -u "s$1$HIGHCOL\0$NORMCOLg"

