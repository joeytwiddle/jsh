#!/bin/sh
# jsh-ext-depends: diff vim
# jsh-ext-depends-ignore: sed
# jsh-depends: higrep bigwin dropcols takecols myps foreachdo jgettmp pipeboth xisrunning
# jsh-depends-ignore: highlight arguments tree
# This is pretty nice (although it gets itself sometimes :-/ )

## TODO: optionally allow user to edit process list.  Those lines which are deleted, means the process is killed.  =)

## TODO: implement -branch: tag each line as TOPLEVEL or CHILD, then xescape, then sed from \nTOPLEVEL.*target.*\nTOPLEVEL *non* greedily?!

## BUGS: myps --forest somes does not show all the processes that myps does!
##       Not true!  The problem was COLUMNS was too low and forest pushes the process off the side of the screen into oblivion!

## ps aux | grep "$SEARCH"   will often catch the grep and the findjob call!  We can avoid the grep by calling twice and keeping only processes that were there both times.

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

if [ "$1" = -tre ]
then
	TRE=true
	shift
fi

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo
	echo "findjob [-tree] <cmd/arg_regexp_word>"
	echo
	echo "  lists processes whose command or arguments match the given word."
	echo
	echo "  with -tree, shows all processes, focused on matches, so that parents can be"
	echo "  easily seen.  This opens in vim."
	echo
	echo "  -tre shows the tree without vim, grepping matches and a few lines above."
	echo
	echo "  Undocumented features: -kidstoo -kill -tre"
	exit 1
fi

findjob () {
	SEARCH_REGEXP="$1"
	env COLUMNS=65535 myps -novars -A |
		grep -v "\<grep\>" | grep "$SEARCH_REGEXP" |
		## TODO: This and the PPID in myps hide valid other jobs belonging to this shell
		##       Presumably that could be solved by starting new shell with #!/bin/sh
		grep -v "\<$PID\>" |
		grep -v "\<findjob\>" |
		## Done: We fail to hide the highlight below, but it only sometimes slips through.
		## TODO: Usually the best solution is to grep -v "\<$$\>"
		grep -v "\<sed\>"
}

findjobtree () {
	env COLUMNS=65535 myps -A --forest
}

PID=$$

# SEARCH_REGEXP="$*"
# SEARCH_REGEXP="\<$*\>"
SEARCH_REGEXP="\<$*\>"

if [ "$TRE" ]
then
	# BUG: Matches on processes created by higrep are displayed, despite $PID!
	findjobtree | dropcols 1 4 5 6 | higrep "$SEARCH_REGEXP" -B3 -A1 | grep -v "\<$PID\>"
	exit
fi

if [ "$KILL" ] || [ "$TREE" ]
then

	KILLFILEA=`jgettmp killfilea`
	KILLFILEB=`jgettmp killfileb`

	if [ "$TREE" ]
	then findjobtree "$SEARCH_REGEXP"
	else findjob "$SEARCH_REGEXP"
	fi > $KILLFILEA

	cp $KILLFILEA $KILLFILEB
	if xisrunning
	then bigwin -fg "vim $KILLFILEB -c ?$@" &
	else vim "$KILLFILEB" -c "?$@"
	fi

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

	findjob "$SEARCH_REGEXP" |
	## Use id of matching processes
	takecols 3 |
	while read X
	do
		## to search for itself and its children (matching parentid field)
		sh findjob "\<$X\>"
		echo
	done
else
	findjob "$SEARCH_REGEXP"
fi |

# Highlighting and grep to hide it
highlight "$SEARCH_REGEXP" | egrep -v "sed s#.*$@" | grep -v "highlight .*$1" ## .* handles the highlight control-chars that were added!

