#!/bin/sh
## Still getting duplicates, if process is reading file with multiple threads/PIDs:
## Use listopenfiles <whatever> | dropcols 2 | removeduplicatelines
## Make this an option defaulting to on (could call it "merge threads")

if [ "$1" = --help ]
then cat << !

listopenfiles [ -allthreads | -mergethreads ] [ <start_of_process_name> ] [ <lsof_options> ]

  will list all files the process currently has opened for reading or writing.
  <start_of_process_name> is a regexp, but don't try to match more than 8 chars!
  (TODO: fix this with lsof's +c <cols> option)
  If no regexp is given, or "", or ., then all processes are listed, which may take longer.

  -allthreads will show every PID which is accessing a file, so may list files
    twice if more than one thread is accessing it.  Use this if you want to
    know all the PIDs, or because it is faster.

  -mergethreads will show each file only once, so some PIDs may not be listed.
    Use this if you just want to know the filenames.  (Currently the default.)

  If a process has more than one file open, its PID will be listed more than once.

  Try: export ENABLE_COLOUR=true

  (We could default to showing only the first PID in each otherwise identical group.)
  (Idk what that meant! :p We could drop all the extra info, and list each file only once,
    but with a comma-separated list of all the PIDs :)
  (listopenfiles is a friendly wrapper for lsof, which strips some but not all of lsof's
    listings, and currently still retains some of lsof's meta-info about each access,
    which it might be better to strip.)

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

column5not () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	grep -v "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

column4not () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	grep -v "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

column5regexp () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	echo "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

column5is () {
	REGEXP=`column5regexp "$@"`
	grep "$REGEXP"
}

column4regexp () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	echo "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

column4color () {
	REGEXP=`column4regexp "$1"`
	sed "s+$REGEXP.*+$2\0`cursenorm`+"
}

if [ "$1" ]
then
	PROCESS_NAME="$1"
	shift
fi

## Find the lsof executable:
if [ ! -x "$LSOF" ]
then
	LSOF=`which lsof 2>/dev/null`
	if [ ! -x "$LSOF" ]
	then
		LSOF=/usr/sbin/lsof
		if [ ! -x "$LSOF" ]
		then
			error "Couldn't find lsof."
			exit 1
		fi
	fi
fi

## Stuff we (could) disable:
## -n : don't convert IP address to hostname
## -S 2 : spend at max 2 seconds in kernel calls
## -l : don't convert login IDs to login names
## -P : don't convert port numbers to service names
## -V : for debugging (lists failures)
## -o : because we are more interested in offset than filesize XXX wanted to use this but lsof complained

"$LSOF" -n -S 2 -V "$@" |
grep "^$PROCESS_NAME" |
# grep "^[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*r " | ## Only files opened for reading
# grep "\<REG\>" |
# grep "^[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ru] " | column5not "TCP" | column5not "sock" | ## Only files opened for reading
# column4not "\(txt\|mem\)" |
# column5not "unix" |
# column5not "IPv4" |
# column5not "CHR" | ## Strip out pipes (or is it libraries?!)
# column5not "FIFO" | ## Strips fifos
# # column5is REG |
# column5is "REG" |
# grep -v "/lib/" | ## Because libraries still crop up despite above (for vim at least)

# dropcols 2 | We used to drop the PID - this was better for watching / ignoring threads which kept refreshing (apachelistuploads and monitor_disk_usage and monitorfileaccess)

if [ "$MERGE_THREADS" ]
then removeduplicatelines
else cat
fi |

## The following hide some non-files, and also unwanted stuff opened during: jwatch listopenfiles
grep -v " pipe$" |
grep -v "^lsof " |
grep -v "/new-listopenfiles\." |

if [ "$ENABLE_COLOUR" ]
then
	column4color "[0123456789]*r" "`cursegreen`" |
	column4color "[0123456789]*w" "`cursered``cursebold`" |
	column4color "[0123456789]*u" "`curseyellow`"
else
	cat
fi

