# [ "$DEBUG" ] && . importshfn debug

## Scans folds in one forwards pass, so would not do well at:
# 123
# 12
# 1
## but would be happy with reverse.

if [ "$1" = -onlyat ]
then
	ONLYAT="$2"
	shift; shift
fi

if [ "$1" = --help ]
then
cat << EOF

treesh [ -onlyat <delimeter> ] [ <file> ]

  will present a navigation interface for tree-like text.

  Tree-like means adjacent lines start with common strings, and tend to
  change on the right-hand side.

  For an example, try:

    cd $JPATH/code/shellscript
    find . -type f | notindir CVS | treesh -onlyat /

  The current navigation interface is vim with a custom folding plugin.
  Use -=_+ to expand/contract branches or NumPad's /* to change levels.

EOF
exit 1
fi

NL="
"

regexpescape () {
	## Escapes the special regexp chars in a plain string so it can appear as a plain string in a regexp expression.
	sed '
		s+\[+\\\\[+g
	'
}

commonstring () {
  ## Returns the portion of the two input strings which is common to both. (eg. "hello", "hegelian" -> "he")
  ## TODO: make it faster!
	## BUGS: does not handle special chars well (eg '.'!); should sedescape those necessary.
	## To test how much of "$2" matches with "123", we build regexp like:
	##   "(1(2(3|)|)|)"
	echo "$FIRSTLINE" |
	sed "s+.+\0\\$NL+g" |
	grep -v "^$" |
	regexpescape |
	(
	while read CHAR
	do
		REGEXPHEAD="$REGEXPHEAD\($CHAR"
		REGEXPEND="\|\)$REGEXPEND"
	done
	REGEXP="$REGEXPHEAD$REGEXPEND"
	# debug "+$REGEXP+"
	echo "$SECONDLINE" |
	sed "s$REGEXP.*\1" ||
	error "regexping $FIRSTLINE"
	)
}

## An upside-down stack, with topmost line cached:
COMMONSOFAR=""
CURRENTCOMMON=""

## Guarantees final stack popping.
( cat "$@" && echo ) | (

read FIRSTLINE

while read SECONDLINE
do

	# [ "$DEBUG" ] && debug
	# [ "$DEBUG" ] && debug "commonsofar:"
	# # debug "$COMMONSOFAR"
	# [ "$DEBUG" ] && debug "first         = $FIRSTLINE"
	# [ "$DEBUG" ] && debug "second        = $SECONDLINE"
	COMMON=`commonstring "$FIRSTLINE" "$SECONDLINE"`
	# [ "$DEBUG" ] && debug "common        = $COMMON"

	NOTABOVE=`startswith "$COMMON" "$CURRENTCOMMON" && echo yes`
	NOTBELOW=`startswith "$CURRENTCOMMON" "$COMMON" && echo yes`
	SAME=`[ "$COMMON" = "$CURRENTCOMMON" ] && echo yes`

	# [ "$DEBUG" ] && debug "notabove      = $NOTABOVE"
	# [ "$DEBUG" ] && debug "notbelow      = $NOTBELOW"
	# [ "$DEBUG" ] && debug "same          = $SAME"

	if [ ! $SAME ] && [ $NOTABOVE ] && ( [ ! "$ONLYAT" ] || endswith "$COMMON" "$ONLYAT" )
	then
		# [ "$DEBUG" ] && debug ">>>>"
		COMMONSOFAR="$COMMONSOFAR$NL$COMMON"
		CURRENTCOMMON="$COMMON"
		echo "+ $CURRENTCOMMON {"
	fi

	echo ". $FIRSTLINE$APPEND"

	if [ ! $SAME ] && [ $NOTBELOW ]
	then
		while ! startswith "$SECONDLINE" "$CURRENTCOMMON"
		do
			# [ "$DEBUG" ] && debug "<<<<"
			echo "- $CURRENTCOMMON }"
			COMMONSOFAR=`echo "$COMMONSOFAR" | chop 1`
			CURRENTCOMMON=`echo "$COMMONSOFAR" | tail -1`
			# [ "$DEBUG" ] && debug "newcurrentcommon = $CURRENTCOMMON"
		done
	fi

	FIRSTLINE="$SECONDLINE"

done

# SECONDLINE is now the empty line we put there, so we ignore it.  =)

) |

if [ "$DEBUG" ]
then pipeboth
else cat
fi |

treevim
