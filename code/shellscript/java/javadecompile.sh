find . -name "*.class" |
while read CLASSFILE
do
	DIR=`dirname "$CLASSFILE"`
	FILE=`filename "$CLASSFILE"`
	JADFILE=`echo "$FILE" | sed 's/\.class$/\.jad/'`
	FINALFILE=`echo "$JADFILE" | sed 's/\.jad$/\.java/'`
	jad -f -ff "$DIR/$FILE"
	mv "$JADFILE" "$DIR/$FINALFILE"
done
# jad -f -ff *.class
# -o to overwrite
