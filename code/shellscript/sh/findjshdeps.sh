if test ! trynew ### PROBLEM: grep requests LOADS of memory to check this long regexp
then

	LIST=`
		## Disabled to make it less dangerous:
		find /bin /usr/bin /sbin -maxdepth 1 -type f | afterlast /
		find $JPATH/tools -maxdepth 1 -type l | afterlast /
	`

	REGEXP=`
		printf '\\<\\('
		echo "$LIST" |
		sort | ## doesn\'t help
		sed 's+$+\\\|+' |
		tr -d '\n' |
		sed 's+\\\|$++'
		printf '\\)\\>'
	`

	echo "$REGEXP"
	find $JPATH/code/shellscript -type f -not -path "*/CVS/*" |

	while read SCRIPT
	do
		echo "Trying $SCRIPT"
		grep "$REGEXP" "$SCRIPT" &&
		echo "  are dependencies in $SCRIPT" && echo
	done

	exit

fi



TMPTREE="$JPATH/tmp/jshdeps"

rm -rf "$TMPTREE"
mkdir -p "$TMPTREE"

cd "$JPATH/tools"

ALLSCRIPTS=` 'ls' * `

echo "$ALLSCRIPTS" |
while read SCRIPT
do
	echo "Finding dependencies on $SCRIPT"
	FILE="$TMPTREE/$SCRIPT.usedby"
	grep -l "\<$SCRIPT\>" * >> "$FILE"
done

cd "$TMPTREE"

echo "$ALLSCRIPTS" |
while read SCRIPT
do
	echo "Finding dependencies for $SCRIPT"
	FILE="$TMPTREE/$SCRIPT.uses"
	grep -l "^$SCRIPT$" *.usedby |
	beforelast "\.usedby" >> "$FILE"
done
