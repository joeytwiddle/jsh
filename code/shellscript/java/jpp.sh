# -C : don't discard comments
# -H : show files being #included
# -P : don't add #lines
MACRO_ARGS="-C -P"

INCLUDES=""
while test ! "$1" = "--" && test ! "$1" = ""
do
	INCLUDES="$INCLUDES -imacros $1"
	shift
done
shift || echo "Usage: jpp <macro_files...> -- <jpp_files_to_compile...>"

for PPNAME
do

	## Pre-process:
	# gcc -x c Test.jpp -E $MACRO_ARGS -o - > Test.java

	## Pre-process using macros provided at command line:
	## Advantage: doesn't show include-file's contents =)
	JNAME=`echo "$PPNAME" | sed 's+\.jpp$+\.java+'`
	(
		echo "/** Auto-generated by jpp.  You probably want to be editing $PPNAME instead. **/" &&
		gcc -x c "$PPNAME" -E $MACRO_ARGS $INCLUDES -o -
	) > "$JNAME"
## | grep -v "^# " > Test.java (sorted now thanks to gcc -P!)

	## Really we should collect these compiled filenames for one big compile at the end.
	# jikes "$JNAME"
	# javac Test.java

done
