## Still getting duplicates, if process is reading file with multiple threads/PIDs:
## Use listopenfiles <whatever> | dropcols 2 | removeduplicatelines
## Make this an option defaulting to on (could call it "merge threads")

if [ ! "$1" ] || [ "$1" = --help ]
then cat << !

listopenfiles [ -allthreads | -mergethreads ] <start_of_process_name> [ <lsof_options> ]

  will list those files the process has opened for reading or writing.
  <start_of_process_name> can be a regexp, but don't try to match more than 8 chars!
	(This could be altered with lsof's +c <cols> option)

  -allthreads will show individual PIDs but may show many if a process
  is accessing the file in multiple threads.

  -mergethreads is the opposite behaviour; the default is currently undecided!

  (Reason: duplication is annoying, but PIDs are useful.)
  (We could default to showing only the first PID in each otherwise identical group.)

!
exit 1
fi

MERGE_THREADS=true
if [ "$1" = -allthreads ]
then shift; MERGE_THREADS=
fi
if [ "$1" = -mergethreads ]
then shift; MERGE_THREADS=true
fi

function column5not () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	grep -v "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

function column4not () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	grep -v "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

function column5regexp () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	echo "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

function column5is () {
	REGEXP=`column5regexp "$@"`
	grep "$REGEXP"
}

function column4regexp () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	echo "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

function column4color () {
	REGEXP=`column4regexp "$1"`
	sed "s+$REGEXP.*+$2\0`cursenorm`+"
}

PROCESS_NAME="$1"
shift

## Stuff we (could) disable:
## -n : don't convert IP address to hostname
## -S 2 : spend at max 2 seconds in kernel calls
## -l : don't convert login IDs to login names
## -P : don't convert port numbers to service names
## -V : for debugging (lists failures)

lsof -n -S 2 -V "$@" |
grep "^$PROCESS_NAME" |
# grep "^[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*r " | ## Only files opened for reading
# grep "\<REG\>" |
# grep "^[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ru] " | column5not "TCP" | column5not "sock" | ## Only files opened for reading
column4not "\(txt\|mem\)" |
# column5not "unix" |
# column5not "IPv4" |
# column5not "CHR" | ## Strip out pipes (or is it libraries?!)
# column5not "FIFO" | ## Strips fifos
# # column5is REG |
column5is "REG" |
# grep -v "/lib/" | ## Because libraries still crop up despite above (for vim at least)

if [ "$MERGE_THREADS" ]
then dropcols 2 | removeduplicatelines
else cat
fi |

if [ "$ENABLE_COLOUR" ]
then
	column4color "[0123456789]*r" "`cursegreen`" |
	column4color "[0123456789]*w" "`cursered``cursebold`" |
	column4color "[0123456789]*u" "`curseyellow`"
else
	cat
fi

