if [ "$1" = "" ] || [ "$1" = --help ]
then
cat << !

jwatchchanges [ -n <delay_time> ] <command>

  will repeatedly run <command>, displaying its output with changes highlighted.

  Alternatively, you may like to try Unix watch(1): watch -d <command>

  Note: <command> should have | pipes escaped as "|"

!
exit 1
fi

DELAY=2s
if [ "$1" = -n ]
then DELAY=$2; shift; shift
fi

COM="$@"

OUTPUTLAST=`jgettmp jwatchchanges last_"$COM"`
OUTPUTNOW=`jgettmp jwatchchanges now_"$COM"`

## CONSIDER: Should I use sh -c like watch(1)?
eval "$COM" > $OUTPUTLAST

while true
do

	## Get command's output:
	eval "$COM" > $OUTPUTNOW

	## Find changes using diff and add colour to any new lines in the diff:
	diff -U0 $OUTPUTLAST $OUTPUTNOW |
	## BUG: This probably doesn't work on changed lines beginning "+", but the [^+] prevents patch errors from a "+++ " diff header being modified.
	sed 's|^+\([^+].*\)|+'`curseyellow`'\1'`cursenorm`'|' |

	## Apply colour changes to old file:
	patch $OUTPUTLAST > /dev/null
	## The pipe to /dev/null just hides patches output (which is usually +ve)
	## Pipe nowhere or to a file instead if you want to debug/check that patch is working.

	## Reduce flicker by putting clear-screen and header info right in the file:
	cat $OUTPUTLAST | (
		clear
		echo "Every $DELAY: $COM     `date`"
		echo
		cat
	) | dog $OUTPUTLAST

	## Display updated screen:
	cat $OUTPUTLAST

	sleep $DELAY

	## Cycle:
	cp $OUTPUTNOW $OUTPUTLAST

done

## TODO: How do I do this when the user breaks out?
jdeltmp $OUTPUTLAST $OUTPUTNOW
