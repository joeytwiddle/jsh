# This is pretty nice (although it gets itself sometimes :-/ )

## TODO: optionally allow user to edit process list.  Those lines which are deleted, means the process is killed.  =)

## BUGS: myps --forest somes does not show all the processes that myps does!
##       Not true!  The problem was COLUMNS was too low and forest pushes the process off the side of the screen into oblivion!

if [ "$1" = -kill ]
then
	KILL=true
	shift
fi

if [ "$1" = "-tree" ]
then
	TREE=true
	shift
fi

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "findjob [-tree] <cmd/arg_search_string>"
	exit 1
fi

findjob () {
	env COLUMNS=65535 myps -A |
		grep -v "grep" | grep "$@" |
		## TODO: This and the PPID in myps hide valid other jobs belonging to this shell
		##       Presumably that could be solved by starting new shell with #!/bin/sh
		grep -v " $PID " |
		grep -v "findjob"
}

findjobtree () {
	env COLUMNS=65535 myps -A --forest
}

PID=$$

if [ "$KILL" ] || [ "$TREE" ]
then

	KILLFILEA=`jgettmp killfilea`
	KILLFILEB=`jgettmp killfileb`

	if [ "$TREE" ]
	then findjobtree "$@"
	else findjob "$@"
	fi > $KILLFILEA

	cp $KILLFILEA $KILLFILEB
	bigwin -fg "vim $KILLFILEB -c ?$@"

	if [ "$KILL" ]
	then
		diff $KILLFILEA $KILLFILEB |
		grep "^< " |
		takecols 4 |
		pipeboth |
		foreachdo kill -KILL
	fi

fi


findjob "$@" |
# Highlighting and grep to hide it
highlight "$@" | egrep -v "sed s#.*$@"

