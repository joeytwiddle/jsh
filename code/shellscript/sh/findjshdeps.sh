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
