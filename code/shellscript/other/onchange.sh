# Todo: Make it work on multiple files

# This is OK on Linux but not Unix:
# function littletest() {
#   newer "$file" "$COMPFILE"
# }

if test "$1" = "" -o "$2" = ""; then
	echo 'onchange <files> [do] <command>'
	echo '  Multiple files must be contained in "quotes".'
	echo '  There is currently no support for the command to know which file changed, but there could be...'
	# NO!  echo '  If you are really cunning, you could use "\$file" in your command!'
	exit 1
fi

FILES="$1"
COMMANDONCHANGE="$2" # $3 $4 $5 $6 $7 $8 $9"
if test "$2" = "do"; then
	COMMANDONCHANGE="$3" # $4 $5 $6 $7 $8 $9"
fi
COMPFILE=`jgettmp onchange`
# COMPFILE="$JPATH/tmp/onchange.tmp"
touch "$COMPFILE"
while test "true" = "true"; do
	sleep 1
	breakonctrlc
	# echo "."
	for file in $FILES; do
		if mynewer "$file" "$COMPFILE"; then
			echo "$file changed, running: $COMMANDONCHANGE"
			touch "$COMPFILE"
			$COMMANDONCHANGE
			# break
		fi
	done
done
jdeltmp "$COMPFILE"
