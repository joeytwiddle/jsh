## Check the jad exe is available:
which jad > /dev/null || exit 1

find . -name "*.class" |
while read CLASSFILE
do
	DIR=`dirname "$CLASSFILE"`
	FILE=`filename "$CLASSFILE"`
	JADFILE=`echo "$FILE" | sed 's/\.class$/\.jad/'`
	FINALFILE=`echo "$JADFILE" | sed 's/\.jad$/\.java/'`
	jad -f -ff -t -safe "$DIR/$FILE"
	mv "$JADFILE" "$DIR/$FINALFILE"
done
# jad -f -ff *.class
# -b additional braces
# -o to overwrite (not needed since we move)
