# This is pretty nice (although it gets itself sometimes :-/ )

## BUGS: myps --forest somes does not show all the processes that myps does!
##       Not true!  The problem was COLUMNS was too low and forest pushes the process off the side of the screen into oblivion!

if test "$1" = ""; then
	echo "findjob [-tree] <cmd/arg_search_string>"
	exit 1
fi

if test "$1" = "-tree"; then
	shift
	# pstree -ap | grep -v "\-gvim(" | gvim -R - -c "/$@"
	# bigwin 'pstree -ap | grep -v "\-vi(" | vi -R - -c '"/$@"
	bigwin 'env COLUMNS=65535 myps -A --forest | grep -v "vim -R - -c" | vim -R - -c '"/$@"
fi

PID=$$
# echo "-$PID"
# Highlighting
# SEDSTR='s+\('"$@"'\)+'`curseyellow`"$@"`cursenorm`'+g'
# --cols 65535 
env COLUMNS=65535 myps -A |
	grep -v "grep" | grep "$@" |
	## TODO: This and the PPID in myps hide valid other jobs belonging to this shell
	##       Presumably that could be solved by starting new shell with #!/bin/sh
	grep -v " $PID " |
	grep -v "findjob" |
	# Highlighting and grep to hide it
	highlight "$@" | egrep -v "sed s#.*$@"
	# if test $JM_DOES_COLOUR; then
		# sed "$SEDSTR"
	# else
		# cat
	# fi
