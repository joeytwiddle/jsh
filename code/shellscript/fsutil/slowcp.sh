## See also: trickle

## Unfortunately it seems this script can still cause short blockages in the system, but it's certainly an improvement.
## Maybe if trickle didn't blast $SPEEDk and then sleep 1 second, but work a little more finely, this would improve?

## It seems that by splitting up the transfer the system does get some chances to make other accesses to the drive.
## But maybe for this application, trickle should really sleep between dd's (rather than in parallel), so that if they are slowed down (due to other hd accesses), it will pause before the next dd.

## TODO: CONSIDER: Could change -at option to -kbps, here and in trickle, to make it easier (compulsory!) for the user to remember the units.

SPEED="1024k" # 1Meg per second

if [ ! "$1" ] || [ "$1" = --help ]
then
cat << !

slowcp [ -at <kps> ] <from> <to-dir>

  allows you to copy large amounts of data across partitions without
  flooding the mem/bus and causing a bottleneck.

  uses tar and delayed dd's.

  currently has the following oddities:

    <to-dir> must be a directory
    the path to <from> will be replicated in <to-dir>

  The -at option takes bytes per second.

  Use monitorhdflow and experiment with -at to find your system's appropriate speed.
  But beware that caches, buffers and other processes will disrupt the numbers!

!
# But it even seems to work at 1000M.  Strange.
# (That was when I used bs= not count=)
#
#  will copy the file/dir(s) slowly, so as not to bottleneck your
#  HD access.  =)
#
#  (I use -at 1000 but monitorhdflow reports usage ~ 1500kbps (whilst my max ave is 3700kbps).)
#
#  These numbers are silly.  All experiments are noisy and inconclusive!  Damn that cache!
exit 1
fi

if [ "$1" = -at ]
then SPEED="$2" ; shift; shift
fi

FROM="$1"
TO="$2"
shift
shift

if [ "$1" ]
then
	error "Only two arguments <from> and <to>"
	exit 1
fi

if [ ! -d "$TO" ]
then
	error "Destination must be a directory."
fi

# FROM=`realpath "$FROM"`
# cd "$TO" || exit

export KNOWN_TOTAL_SIZE=`du -sb "$FROM" | takecols 1`
## That is so dodgy; it doesn't account for tar headers, AND it is used by trickle to know when to exit.
KNOWN_TOTAL_SIZE=`expr $KNOWN_TOTAL_SIZE + 10240`
KNOWN_TOTAL_SIZE=`expr $KNOWN_TOTAL_SIZE '*' 110 / 100`

ESTTIME=`expr $KNOWN_TOTAL_SIZE / $SPEED / 1024 / 60`
ESTTIME=`expr $ESTTIME '*' 3 / 2` ## we don't get anything like the optimum
jshinfo "$KNOWN_TOTAL_SIZE bytes at $SPEED""kps might take ~ $ESTTIME minutes."
# jshinfo "You may also like to run (separately): monitorcopy \"$FROM\" \"$TO/$FROM\""

(
	if verbosely tar c "$FROM"
	then
		jshinfo "Tar creation complete.  (You should CTRL+C once buffers have flushed.  TODO: dd doesn't tell us when it's finished!)"
	else
		error "tar creation failed"
		exit 1
		## Unfortunately this exit doesn't seem to work!
		## TODO: this is bad because any error we want to pass out to parent caller, to inform then the copy failed!
	fi
	echo ""
) |

verbosely env TRICKLE_SHOW_PROGRESS=1 trickle -at "$SPEED" |

(
	cd "$TO" || exit 1
	if verbosely tar xv
	then
		jshinfo "Tar extraction complete."
	else
		error "Tar extraction failed."
		exit 1
		## Unfortunately this exit doesn't seem to work!
		## TODO: this is bad because any error we want to pass out to parent caller, to inform then the copy failed!
	fi
)

