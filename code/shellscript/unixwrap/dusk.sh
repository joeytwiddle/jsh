#!/bin/sh

## Simple version:
# du -sk * ; exit

SHOWSCAN=true

DUCOM="du -skx"
which nice >/dev/null && DUCOM="nice -n 5 $DUCOM"
which ionice >/dev/null && DUCOM="ionice -n 5 $DUCOM"
jshinfo "DUCOM=$DUCOM"

if test $JM_COLOUR_LS
then
	# This is bad if the output is being streamed through autoamtion!
	LSCOM="ls -artFd --color"
else
	# Too slow on Unix ATM (and not enough for it ATM ;):
	LSCOM="fakels -d"
	# LSCOM="ls -dF"
	# LSCOM="echo"
fi

(

	[ "$SHOWSCAN" ] && echo -n "Scanning: " >&2

	## Output a list of files/folders to scan:
	if [ "$*" = "" ]
	then
	  # Yuk we need to strip out . and ..!
	  for X in * .*
		do
			if test ! "$X" = ".."
			then
				# Uncomment this next if to keep this dir . (total)
				if test ! "$X" = "."
				then echo "$X"
				fi
			fi
		done
	else
		echolines "$@"
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

