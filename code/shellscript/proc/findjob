# This is pretty nice (although it gets itself sometimes :-/ )

if test "$1" = ""; then
	echo "findjob [-tree] <cmd/arg_search_string>"
	exit 1
fi

if test "$1" = "-tree"; then
	shift
	# pstree -ap | grep -v "\-gvim(" | gvim -R - -c "/$@"
	bigwin 'pstree -ap | grep -v "\-vi(" | vi -R - -c '"/$@"
fi

PID=$$
# echo "-$PID"
# Highlighting
# SEDSTR='s+\('"$@"'\)+'`curseyellow`"$@"`cursegrey`'+g'
# --cols 65535 
env COLUMNS=65535 myps -A |
	grep -v "grep" | grep "$@" | grep -v " $PID " | grep -v "findjob" |
	# Highlighting and grep to hide it
	highlight "$@" | egrep -v "sed s#.*$@"
	# if test $JM_DOES_COLOUR; then
		# sed "$SEDSTR"
	# else
		# cat
	# fi
