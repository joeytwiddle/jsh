if [ "$1" = "" ] || [ "$1" = --help ]
then
cat << !

jwatchchanges [ -fine ] [ -n <delay_time> ] <command>

  will repeatedly run <command>, displaying its output with changes highlighted.

  -fine will highlight changed characters, not changed lines, but uses more CPU.

  Alternatively, you may like to try Unix watch(1): watch -d <command>

  Note: any | pipes in <command> should be escaped as "|"

  Example: jwatchchanges -fine top n 1

!
exit 1
fi

## TODO: STRIP could be guessed from one initial call and check (hackcheck could cmp output of striptermchars with original!), ot STRIP could be requested by user, but then the user could just end with "... | striptermchars" .  Anyway it's a delaying monitor, so it needn't be efficient!
# STRIP=cat
STRIP=striptermchars

if [ "$1" = -fine ]
then
	shift
	RESONREAD="escapenewlines -x"
	RESONWRITE="unescapenewlines -x"
else
	RESONREAD=cat
	RESONWRITE=cat
fi

DELAY=2s
if [ "$1" = -n ]
then DELAY=$2; shift; shift
fi

COM="$@"

[ ! "$COLUMNS" ] && COLUMNS=80
[ ! "$LINES" ] && LINES=24
## Haks to prevent any chance of overflow:
# export COLUMNS=`expr "$COLUMNS" - 1`
export LINES=`expr "$LINES" - 3` ## -2 for header.  BUG: Won't be enough if header goes over one line!  solution: strip header in the same way as stripping in the next section

## TODO: CONSIDER: Could (optionally) strip height and width to those in COLUMNS/LINES, for lists with long output.
##                 in that case, ideally we would not change and export them here, but read it them realtime (xterm => COLUMNS,LINES volatile), and -1 then.

OUTPUTLAST=`jgettmp jwatchchanges last_"$COM"`
OUTPUTNOW=`jgettmp jwatchchanges now_"$COM"`

## CONSIDER: Should I use sh -c like watch(1)?
eval "$COM" | $STRIP | $RESONREAD > $OUTPUTLAST

while true
do

	## Get command's output:
	eval "$COM" | $STRIP | $RESONREAD > $OUTPUTNOW

	## Find changes using diff and add colour to any new lines in the diff:
	diff -U0 $OUTPUTLAST $OUTPUTNOW |
	## BUG: This probably doesn't work on changed lines beginning "+", but the [^+] prevents patch errors from a "+++ " diff header being modified.
	sed 's|^+\([^+].*\)|+'`curseyellow`'\1'`cursenorm`'|' |

	## Apply colour changes to old file:
	patch $OUTPUTLAST > /dev/null
	## The pipe to /dev/null just hides patches output (which is usually +ve)
	## Pipe nowhere or to a file instead if you want to debug/check that patch is working.

	## Reduce flicker by putting clear-screen and header info right in the file:
	cat $OUTPUTLAST | $RESONWRITE | (
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
