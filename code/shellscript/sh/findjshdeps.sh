TMPTREE="/tmp/jshdeps"

rm -rf "$TMPTREE"
mkdir -p "$TMPTREE"

cd "$JPATH/tools"
'ls' * |
while read SCRIPT
do
	FILE="$TMPTREE/$SCRIPT.usedby"
	cd "$JPATH/code/shellscript/"
	grep -l "\<$SCRIPT\>" * -r |
	grep -v CVS |
	afterlast "/" | beforelast "\." >> "$FILE"
done

cd "$JPATH/tools"
'ls' * |
while read SCRIPT
do
	FILE="$TMPTREE/$SCRIPT.uses"
	grep -l "^$SCRIPT$" $TMPTREE/*.usedby |
	beforelast "\.usedby" >> "$FILE"
done
