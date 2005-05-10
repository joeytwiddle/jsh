# jsh-ext-depends: diff vim
# jsh-ext-depends-ignore: sed
# jsh-depends: higrep bigwin dropcols takecols myps foreachdo jgettmp pipeboth
# jsh-depends-ignore: highlight
# This is pretty nice (although it gets itself sometimes :-/ )

## TODO: optionally allow user to edit process list.  Those lines which are deleted, means the process is killed.  =)

## TODO: implement -branch: tag each line as TOPLEVEL or CHILD, then xescape, then sed from \nTOPLEVEL.*target.*\nTOPLEVEL *non* greedily?!

## BUGS: myps --forest somes does not show all the processes that myps does!
##       Not true!  The problem was COLUMNS was too low and forest pushes the process off the side of the screen into oblivion!

if [ "$1" = -kidstoo ]
then
	KIDSTOO=true
	shift
fi

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
	env COLUMNS=65535 myps -novars -A |
		grep -v "\<grep\>" | grep "$@" |
		## TODO: This and the PPID in myps hide valid other jobs belonging to this shell
		##       Presumably that could be solved by starting new shell with #!/bin/sh
		grep -v "\<$PID\>" |
		grep -v "\<findjob\>" |
		## TODO: We fail to hide the highlight below, but it only occasionally slips through.
		## TODO: Usually the best solution is to grep -v "\<$$\>"
		grep -v "\<sed\>"
}

findjobtree () {
	env COLUMNS=65535 myps -A --forest
}

PID=$$

if [ "$1" = -tre ]
then
	shift
	findjobtree | dropcols 1 4 5 6 | higrep "$@" -B3 -A1
	exit
fi

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


if [ "$KIDSTOO" ]
then

	findjob "$@" |
	## Use id of matching processes
	takecols 3 |
	while read X
	do
		## to search for itself and its children (matching parentid field)
		sh findjob "\<$X\>"
		echo
	done
else
	findjob "$@"
fi |

# Highlighting and grep to hide it
highlight "$@" | egrep -v "sed s#.*$@"

