. importshfn debug

NL="
"

"(1(2(3|)|)|)"

commonstring () {
	echo "$FIRSTLINE" |
	sed "s+.+\0\\$NL+g" |
	grep -v "^$" |
	(
	while read CHAR
	do
		REGEXPHEAD="$REGEXPHEAD\($CHAR"
		REGEXPEND="\|\)$REGEXPEND"
	done
	REGEXP="$REGEXPHEAD$REGEXPEND"
	# echo "+$REGEXP+"
	echo "$SECONDLINE" |
	sed "s+$REGEXP.*+\1+"
	)
}

COMMONSOFAR=""
CURRENTCOMMON=""

read FIRSTLINE

while read SECONDLINE
do

	debug
	debug "commonsofar:"
	# echo "$COMMONSOFAR"
	debug "first         = $FIRSTLINE"
	debug "second        = $SECONDLINE"
	COMMON=`commonstring "$FIRSTLINE" "$SECONDLINE"`
	debug "common        = $COMMON"

	NOTABOVE=`startswith "$COMMON" "$CURRENTCOMMON" && echo yes`
	NOTBELOW=`startswith "$CURRENTCOMMON" "$COMMON" && echo yes`
	SAME=`[ "$COMMON" = "$CURRENTCOMMON" ] && echo yes`

	debug "notabove      = $NOTABOVE"
	debug "notbelow      = $NOTBELOW"
	debug "same          = $SAME"

	APPEND=""

	if [ ! $SAME ] && [ $NOTABOVE ]
	then
		COMMONSOFAR="$COMMONSOFAR$NL$COMMON"
		CURRENTCOMMON="$COMMON"
		APPEND=" {"
		debug ">>>>"
	fi

	if [ ! $SAME ] && [ $NOTBELOW ]
	then
		while ! startswith "$SECONDLINE" "$CURRENTCOMMON"
		do
			COMMONSOFAR=`echo "$COMMONSOFAR" | chop 1`
			CURRENTCOMMON=`echo "$COMMONSOFAR" | tail -1`
			APPEND="$APPEND }"
			debug "<<<<"
			debug "newcurrentcommon = $CURRENTCOMMON"
		done
	fi

	echo "$FIRSTLINE$APPEND"

	FIRSTLINE="$SECONDLINE"

done

echo "Finally: $SECONDLINE"
