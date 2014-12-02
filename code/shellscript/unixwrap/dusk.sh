#!/bin/bash
# Mac OSX's sh-3.2 has a builtin echo which prints -n instead of interpreting it.  So we use bash.
# Mac OSX's sh-3.2 is actually  GNU bash, version 3.2.51(1)-release-(x86_64-apple-darwin13)

## Simple version:
# du -sk * ; exit

SHOWSCAN=true

DUCOM="du -skx"
# du can be heavy on disk access, and even the system CPU, so we relax it a bit.
which nice >/dev/null && DUCOM="nice -n 5 $DUCOM"       # weak: -n 5 strong: -n 15
which ionice >/dev/null && DUCOM="ionice -n 5 $DUCOM"   # weak: -n 5 strong: -c 3
# jshinfo "DUCOM=$DUCOM"

## Enable this if you want to see files colored like with ls.
[ "$USER" = joey ] && DUSK_COLORS=1

if [ -z "$DUSK_COLORS" ]
then LSCOM=echo
else
	if [ -n "$JM_COLOUR_LS" ]
	then
		# TODO: This is bad if the output is being streamed through automation!  Check tty?
		LSCOM="ls -artFd --color"
	else
		# Too slow on Unix ATM (and not enough for it ATM ;):
		# LSCOM="fakels -d"
		LSCOM="ls -dF"
	fi
fi

(

	[ "$SHOWSCAN" ] && echo -n "Scanning: " >&2

	## Output a list of files/folders to scan:
	if [ "$*" = "" ]
	then
		echolines .* * | grep -v '^\(\.\|\.\.\)$'
		# find . -maxdepth 1 -mindepth 1 | sed 's+^\./++'
	else
		echolines "$@"
		# find "$@" -maxdepth 0 -mindepth 0 | sed 's+^\./++'
	fi |

	## Actually scan them:
	while read X
	do
		[ "$SHOWSCAN" ] && echo -n "$X " >&2
		$DUCOM "$X"
	done

	[ "$SHOWSCAN" ] && echo "" >&2

) | sort -n -k 1 |

# Pretty printing
while read SIZE FILE
do
	printf "$SIZE\t"
	$LSCOM "$FILE"
done

