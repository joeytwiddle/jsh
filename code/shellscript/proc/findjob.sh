# echo "grep $*" 1>&2
PID=$$
# echo "-$PID"
# Highlighting
SEDSTR='s+\('"$@"'\)+'`curseyellow`"$@"`cursegrey`'+g'
# --cols 65535 
env COLUMNS=65535 myps -A |
	grep -v "grep" | grep "$@" | grep -v " $PID " |
	# Highlighting
	if test $JM_DOES_COLOUR; then
		sed "$SEDSTR"
	else
		cat
	fi
