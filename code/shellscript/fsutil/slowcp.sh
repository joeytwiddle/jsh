## Unfortunately it seems this script can still cause short blockages in the system, but it's certainly an improvement.
## Maybe if trickle didn't blast $SPEEDk and then sleep 1 second, but work a little more finely, this would improve?

## TODO: CONSIDER: Could change -at option to -kbps, here and in trickle, to make it easier (compulsory!) for the user to remember the units.

SPEED="10240"

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

  The -at option takes kps in dd format (eg. append 'K'), default '$SPEED'.

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

jshinfo "You may also like to run (separately): monitorcopy \"$FROM\" \"$TO/$FROM\""

export KNOWN_TOTAL_SIZE=`du -sb "$FROM" | takecols 1`

(
	if ! tar c "$FROM"
	then
		error "tar creation failed"
		exit 1
		## Unfortunately this exit doesn't seem to work!
		## TODO: this is bad because any error we want to pass out to parent caller, to inform then the copy failed!
	fi
) |

trickle -at "$SPEED" |

(
	cd "$TO" || exit 1
	if ! tar xv
	then
		error "Tar extraction failed."
		exit 1
		## Unfortunately this exit doesn't seem to work!
		## TODO: this is bad because any error we want to pass out to parent caller, to inform then the copy failed!
	fi
)

