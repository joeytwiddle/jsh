EXPR="\("
for X
do EXPR="$EXPR\<$X\>\|"
done
EXPR=`echo "$EXPR" | sed 's+\\\|$++'`
EXPR="$EXPR\)"
# echo "$EXPR"
cd $JPATH/code/shellscript
higrep "$EXPR" * -r |
notindir CVS
